/datum/action/ability/xeno_action/mutation/proc/set_mutation_power(tier)
	return

// Mutation-based pheromones ability
/datum/action/ability/xeno_action/mutation/pheromones
	name = "Emit Pheromones (Mutation)"
	desc = "Opens your pheromone options. Power depends on mutation tier."
	action_icon_state = "emit_pheromones"
	action_icon = 'icons/Xeno/actions/general.dmi'
	ability_cost = 0
	use_state_flags = ABILITY_USE_STAGGERED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_LYING|ABILITY_USE_BUCKLED
	var/phero_power = 0.5
	var/phero_power_base = 1
	var/datum/aura_bearer/mutation_aura // Separate aura for mutations

/datum/action/ability/xeno_action/mutation/pheromones/set_mutation_power(tier)
	set_pheromone_power(tier)

/datum/action/ability/xeno_action/mutation/pheromones/proc/set_pheromone_power(tier)
	switch(tier)
		if(1)
			phero_power = 0.5
			phero_power_base = 1
		if(2)
			phero_power = 1
			phero_power_base = 2
		if(3)
			phero_power = 1.5
			phero_power_base = 3

/datum/action/ability/xeno_action/mutation/pheromones/proc/apply_pheromones(phero_choice)
	if(mutation_aura && mutation_aura.aura_types[1] == phero_choice)
		xeno_owner.balloon_alert(xeno_owner, "Stop emitting mutation pheromones")
		QDEL_NULL(mutation_aura)
		return fail_activate()

	QDEL_NULL(mutation_aura)

	mutation_aura = SSaura.add_emitter(xeno_owner, phero_choice, 6 + phero_power * 2, phero_power_base + phero_power, -1, xeno_owner.faction, xeno_owner.hivenumber)
	xeno_owner.balloon_alert(xeno_owner, "[phero_choice] (Mutation)")
	playsound(xeno_owner.loc, SFX_ALIEN_DROOL, 25)

	xeno_owner.hud_set_pheromone()
	succeed_activate()

/datum/action/ability/xeno_action/mutation/pheromones/action_activate()
	var/phero_choice = show_radial_menu(owner, owner, GLOB.pheromone_images_list, radius = 35)
	if(!phero_choice)
		return fail_activate()
	apply_pheromones(phero_choice)

/datum/action/ability/xeno_action/mutation/pheromones/remove_action(mob/living/carbon/xenomorph/target)
	if(mutation_aura)
		mutation_aura.stop_emitting()
		QDEL_NULL(mutation_aura)
	return ..()

// Mutation-based toxin ability
/datum/action/ability/xeno_action/mutation/toxin
	name = "Select Toxin (Mutation)"
	desc = "Selects which toxin to inject with your attacks. Power depends on mutation tier."
	action_icon_state = "select_reagent0"
	action_icon = 'icons/Xeno/actions/general.dmi'
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	var/toxin_amount = 0.5
	var/datum/reagent/toxin/injected_reagent = /datum/reagent/toxin/xeno_transvitox
	var/list/selectable_reagents = list(
		/datum/reagent/toxin/xeno_ozelomelyn,
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
	)

/datum/action/ability/xeno_action/mutation/toxin/set_mutation_power(tier)
	set_toxin_power(tier)

/datum/action/ability/xeno_action/mutation/toxin/proc/set_toxin_power(tier)
	switch(tier)
		if(1)
			toxin_amount = 0.5
			selectable_reagents = list(
				/datum/reagent/toxin/xeno_ozelomelyn,
				/datum/reagent/toxin/xeno_hemodile,
				/datum/reagent/toxin/xeno_transvitox,
			)
		if(2)
			toxin_amount = 1
			selectable_reagents = list(
				/datum/reagent/toxin/xeno_ozelomelyn,
				/datum/reagent/toxin/xeno_hemodile,
				/datum/reagent/toxin/xeno_transvitox,
				/datum/reagent/toxin/xeno_sanguinal
			)

/datum/action/ability/xeno_action/mutation/toxin/give_action(mob/living/L)
	. = ..()
	xeno_owner.mutation_toxin_reagent = injected_reagent // Use separate variable to avoid conflicts

/datum/action/ability/xeno_action/mutation/toxin/update_button_icon()
	var/atom/A = xeno_owner.mutation_toxin_reagent
	action_icon_state = initial(A.name)
	return ..()

/datum/action/ability/xeno_action/mutation/toxin/action_activate()
	var/static/list/toxin_images_list = list(
		REAGENT_OZELOMELYN = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_OZELOMELYN),
		REAGENT_HEMODILE = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_HEMODILE),
		REAGENT_TRANSVITOX = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_TRANSVITOX),
	)
	var/static/list/toxin_images_list_tier2 = list(
		REAGENT_OZELOMELYN = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_OZELOMELYN),
		REAGENT_HEMODILE = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_HEMODILE),
		REAGENT_TRANSVITOX = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_TRANSVITOX),
		REAGENT_SANGUINAL = image('icons/Xeno/actions/general.dmi', icon_state = REAGENT_SANGUINAL)
	)

	var/toxin_choice = show_radial_menu(owner, owner, toxin_amount != 1 ? toxin_images_list : toxin_images_list_tier2, radius = 35)
	if(!toxin_choice)
		return fail_activate()

	for(var/toxin in selectable_reagents)
		var/datum/reagent/R = GLOB.chemical_reagents_list[toxin]
		if(R.name == toxin_choice)
			xeno_owner.mutation_toxin_reagent = R.type
			break

	xeno_owner.balloon_alert(xeno_owner, "[toxin_choice] (Mutation)")
	update_button_icon()
	return succeed_activate()

// Mutation-based trail ability
/datum/action/ability/xeno_action/mutation/trail
	name = "Select Trail (Mutation)"
	desc = "Selects which trail to leave behind when moving. Power depends on mutation tier."
	action_icon_state = "trail"
	action_icon = 'icons/Xeno/actions/general.dmi'
	use_state_flags = ABILITY_USE_BUSY|ABILITY_USE_LYING
	var/obj/selected_trail = /obj/effect/xenomorph/spray
	var/base_chance = 25
	var/chance = 25
	var/list/selectable_trails = list(
		/obj/effect/xenomorph/spray,
		/obj/alien/resin/sticky/thin/temporary,
	)

/datum/action/ability/xeno_action/mutation/trail/set_mutation_power(tier)
	set_trail_power(tier)

/datum/action/ability/xeno_action/mutation/trail/proc/set_trail_power(tier)
	switch(tier)
		if(1)
			chance = 25
		if(2)
			chance = 50
		if(3)
			chance = 75

/datum/action/ability/xeno_action/mutation/trail/give_action(mob/living/L)
	. = ..()
	xeno_owner.mutation_trail_type = selected_trail // Use separate variable to avoid conflicts
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(do_trail))

/datum/action/ability/xeno_action/mutation/trail/remove_action(mob/living/carbon/xenomorph/target)
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/action/ability/xeno_action/mutation/trail/action_activate()
	var/i = selectable_trails.Find(selected_trail)
	if(length(selectable_trails) == i)
		selected_trail = selectable_trails[1]
	else
		selected_trail = selectable_trails[i+1]

	xeno_owner.mutation_trail_type = selected_trail
	xeno_owner.balloon_alert(xeno_owner, "[selected_trail.name] (Mutation)")
	return succeed_activate()

/datum/action/ability/xeno_action/mutation/trail/proc/do_trail()
	SIGNAL_HANDLER
	if(xeno_owner.incapacitated(TRUE) || xeno_owner.status_flags & INCORPOREAL || HAS_TRAIT(xeno_owner, TRAIT_MOVE_VENTCRAWLING))
		return
	if(prob(base_chance + chance))
		var/turf/T = get_turf(xeno_owner)
		if(T.density || isspaceturf(T))
			return
		for(var/obj/O in T.contents)
			if(is_type_in_typecache(O, GLOB.no_sticky_resin))
				return
		if(selected_trail == /obj/effect/xenomorph/spray)
			new selected_trail(T, rand(2 SECONDS, 5 SECONDS))
			for(var/obj/O in T)
				O.acid_spray_act(xeno_owner)
		else
			new selected_trail(T)

// Handle mutation toxin injection on slash attacks
/mob/living/carbon/xenomorph/proc/handle_mutation_toxin_attack(mob/living/target)
	if(!mutation_toxin_reagent)
		return

	var/datum/action/ability/xeno_action/mutation/toxin/toxin_ability
	for(var/datum/action/ability/xeno_action/mutation/toxin/ability in actions)
		if(istype(ability, /datum/action/ability/xeno_action/mutation/toxin))
			toxin_ability = ability
			break

	if(!toxin_ability)
		return

	var/datum/reagent/toxin/selected_toxin = GLOB.chemical_reagents_list[mutation_toxin_reagent]
	if(!selected_toxin)
		return

	var/toxin_amount = toxin_ability.toxin_amount

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(mutation_toxin_reagent, toxin_amount)
		to_chat(src, span_xenonotice("We inject [toxin_amount] units of [initial(selected_toxin.name)] into [target]."))
	else
		to_chat(src, span_xenonotice("We attempt to inject [initial(selected_toxin.name)] into [target]."))

/mob/living/carbon/xenomorph/Initialize(mapload, do_not_set_as_ruler)
	. = ..()
	RegisterSignal(src, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_mutation_attack_living))

/mob/living/carbon/xenomorph/proc/on_mutation_attack_living(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	handle_mutation_toxin_attack(target)
