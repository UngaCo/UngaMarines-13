/// Datum for handling the xenomorph mutation menu TGUI
/datum/mutation_menu
	/// The xenomorph using this menu
	var/mob/living/carbon/xenomorph/xeno_owner

/datum/mutation_menu/New(mob/living/carbon/xenomorph/xeno)
	. = ..()
	xeno_owner = xeno

/datum/mutation_menu/ui_interact(mob/user, datum/tgui/ui)
	// Xeno only screen
	if(!isxeno(user))
		return

	// Minions can't access mutations
	var/mob/living/carbon/xenomorph/xeno = user
	if(xeno.xeno_caste.caste_flags & CASTE_IS_A_MINION)
		to_chat(user, span_warning("We are too primitive to understand mutations."))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MutationMenu")
		ui.open()

/// Checks for xeno access and prevents unconscious / dead xenos from interacting.
/datum/mutation_menu/ui_state(mob/user)
	return GLOB.xeno_state

/// Assets for the UI
/datum/mutation_menu/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/mutationmenu)

/// Static data provided once when the ui is opened
/datum/mutation_menu/ui_static_data(mob/living/carbon/xenomorph/xeno)
	. = list()
	.["categories"] = list("Survival", "Offensive", "Specialized", "Enhancement")

/// Dynamic data that updates every tick
/datum/mutation_menu/ui_data(mob/living/carbon/xenomorph/xeno)
	. = list()

	// Minions don't have biomass or mutations
	if(xeno.xeno_caste.caste_flags & CASTE_IS_A_MINION)
		.["biomass"] = 0
		.["max_biomass"] = 0
		.["mutations"] = list()
		.["passive_biomass_gain"] = 0
		return

	.["biomass"] = xeno.biomass
	.["max_biomass"] = xeno.biomass > 50 ? xeno.biomass : 50
	.["mutations"] = get_mutations_data(xeno)
	.["current_caste"] = lowertext(xeno.xeno_caste.caste_name)

	.["passive_biomass_gain"] = xeno.get_passive_biomass_gain_rate()

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

/datum/mutation_menu/proc/get_mutations_data(mob/living/carbon/xenomorph/xeno)
	var/list/mutations = list()
	initialize_xeno_mutations()

	//Конверт всего в лист для тгуи
	for(var/datum/xeno_mutation/mutation in GLOB.xeno_mutations)
		if(mutation.is_available(xeno))
			mutations += list(mutation.to_list(xeno))

	return mutations

/datum/mutation_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("purchase_mutation")
			var/mutation_name = params["mutation_name"]
			purchase_mutation(mutation_name)
			return TRUE

/datum/mutation_menu/proc/purchase_mutation(mutation_name)
	var/datum/xeno_mutation/mutation_datum = get_xeno_mutation_by_name(mutation_name)

	if(!xeno_owner)
		to_chat(usr, span_warning("Invalid xenomorph reference!"))
		return

	if(xeno_owner.incapacitated(TRUE))
		to_chat(usr, span_warning("Can't do that right now!"))
		return

	if(xeno_owner.fortify)
		to_chat(usr, span_warning("You cannot buy mutations while fortified!"))
		return

	if(xeno_owner.stat == DEAD)
		to_chat(usr, span_warning("You're dead!"))
		return

	if(!mutation_datum)
		to_chat(usr, span_warning("Invalid mutation name!"))
		return

	if(!mutation_datum.is_available(xeno_owner))
		to_chat(usr, span_warning("This mutation is not available for your caste!"))
		return

	if(!mutation_datum.is_unlocked(xeno_owner))
		to_chat(usr, span_warning("This mutation is not unlocked yet!"))
		return

	var/mutation_cost = get_mutation_cost_for_caste(mutation_datum, xeno_owner.xeno_caste.caste_name)

	if(xeno_owner.biomass < mutation_cost)
		to_chat(usr, span_warning("You don't have enough biomass! You need [mutation_cost] biomass, but you only have [xeno_owner.biomass]."))
		return

	var/upgrade = locate(mutation_datum.status_effect_type) in xeno_owner.status_effects
	if(upgrade)
		to_chat(usr, span_xenonotice("Existing mutation chosen. No biomass spent."))
		return

	//Remove parent mutations if purchasing higher tier
	var/datum/status_effect/parent_to_remove
	if(mutation_datum.parent_name)
		var/datum/xeno_mutation/parent_mutation = get_xeno_mutation_by_name(mutation_datum.parent_name)
		if(parent_mutation && parent_mutation.status_effect_type)
			parent_to_remove = locate(parent_mutation.status_effect_type) in xeno_owner.status_effects

	if(parent_to_remove)
		xeno_owner.remove_status_effect(parent_to_remove)

	// Remove parent abilities if purchasing higher tier
	if(mutation_datum.parent_name)
		var/datum/xeno_mutation/parent_mutation = get_xeno_mutation_by_name(mutation_datum.parent_name)
		if(parent_mutation && parent_mutation.ability_type)
			for(var/datum/action/ability/xeno_action/mutation/ability in xeno_owner.actions)
				if(istype(ability, parent_mutation.ability_type))
					ability.remove_action(xeno_owner)
					xeno_owner.upgrades_holder.Remove(parent_mutation.ability_type)

	xeno_owner.biomass -= mutation_cost
	to_chat(usr, span_xenonotice("[mutation_name] mutation gained."))

	//Add to purchase history
	xeno_owner.purchased_mutations += mutation_name

	// Update enhancement HUD immediately after adding mutation to purchased_mutations
	if(mutation_datum.category == "Enhancement")
		xeno_owner.hud_set_enhancement()

	//Remove conflicting mutations (only the specific one being replaced)
	var/datum/status_effect/conflicting_upgrade = locate(mutation_datum.status_effect_type) in xeno_owner.status_effects
	if(conflicting_upgrade)
		xeno_owner.remove_status_effect(conflicting_upgrade)
		xeno_owner.upgrades_holder.Remove(conflicting_upgrade.type)

	// Remove conflicting abilities
	if(mutation_datum.ability_type)
		for(var/datum/action/ability/xeno_action/mutation/ability in xeno_owner.actions)
			if(istype(ability, mutation_datum.ability_type))
				ability.remove_action(xeno_owner)
				xeno_owner.upgrades_holder.Remove(mutation_datum.ability_type)

	xeno_owner.do_jitter_animation(500)

	// Apply status effect if mutation has one
	if(mutation_datum.status_effect_type)
		xeno_owner.apply_status_effect(mutation_datum.status_effect_type)
		xeno_owner.upgrades_holder.Add(mutation_datum.status_effect_type)

	// Add ability if mutation has one
	if(mutation_datum.ability_type)
		var/datum/action/ability/ability = new mutation_datum.ability_type()
		// Check if it's a mutation ability and call set_mutation_power
		if(istype(ability, /datum/action/ability/xeno_action/mutation))
			var/datum/action/ability/xeno_action/mutation/mutation_ability = ability
			mutation_ability.set_mutation_power(mutation_datum.tier)
		ability.give_action(xeno_owner)
		xeno_owner.upgrades_holder.Add(mutation_datum.ability_type)

	// Update enhancement HUD after any mutation changes
	xeno_owner.hud_set_enhancement()

	SStgui.update_uis(src)
