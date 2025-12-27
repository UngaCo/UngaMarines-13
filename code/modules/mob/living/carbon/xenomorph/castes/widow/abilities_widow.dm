// ***************************************
// *********** Leash Ball
// ***************************************

/datum/action/ability/activable/xeno/leash_ball
	name = "Leash Ball"
	desc = "Spit a huge web ball that snares groups of targets for a brief while."
	action_icon_state = "leash_ball"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	ability_cost = 75
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LEASH_BALL,
	)

/datum/action/ability/activable/xeno/leash_ball/use_ability(atom/A)
	var/turf/target = get_turf(A)
	xeno_owner.face_atom(target)
	if(!do_after(xeno_owner, 0.5 SECONDS, IGNORE_LOC_CHANGE, xeno_owner, BUSY_ICON_DANGER))
		return fail_activate()
	var/datum/ammo/xeno/leash_ball = GLOB.ammo_list[/datum/ammo/xeno/leash_ball]
	leash_ball.hivenumber = xeno_owner.hivenumber
	var/atom/movable/projectile/newspit = new (get_turf(xeno_owner))

	newspit.generate_bullet(leash_ball)
	newspit.fire_at(target, xeno_owner, xeno_owner, newspit.ammo.max_range)
	succeed_activate()
	add_cooldown()

/obj/structure/xeno/aoe_leash
	name = "Snaring Web"
	desc = "Sticky and icky. Destroy it when you are stuck!"
	icon_state = "aoe_leash"
	icon = 'icons/Xeno/Effects.dmi'
	destroy_sound = 'sound/effects/alien/resin_break1.ogg'
	max_integrity = 150
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	allow_pass_flags = NONE
	density = FALSE
	obj_flags = CAN_BE_HIT | PROJ_IGNORE_DENSITY
	/// How long the leash ball lasts untill it dies
	var/leash_life = 10 SECONDS
	/// Radius for how far the leash should affect humans and how far away they may walk
	var/leash_radius = 3
	/// List of beams to be removed on obj_destruction
	var/list/obj/effect/ebeam/beams = list()
	/// List of victims to unregister aoe_leash is destroyed
	var/list/mob/living/carbon/human/leash_victims = list()

/// Humans caught get beamed and registered for proc/check_dist, aoe_leash also gains increased integrity for each caught human
/obj/structure/xeno/aoe_leash/Initialize(mapload, _hivenumber)
	. = ..()
	for(var/mob/living/carbon/human/victim in GLOB.humans_by_zlevel["[z]"])
		if(get_dist(src, victim) > leash_radius)
			continue
		if(victim.stat == DEAD) /// Add || CONSCIOUS after testing
			continue
		if(HAS_TRAIT(victim, TRAIT_LEASHED))
			continue
		if(check_path(src, victim, pass_flags_checked = PASS_PROJECTILE) != get_turf(victim))
			continue
		leash_victims += victim
	for(var/mob/living/carbon/human/snared_victim AS in leash_victims)
		ADD_TRAIT(snared_victim, TRAIT_LEASHED, src)
		beams += beam(snared_victim, "beam_web", 'icons/effects/beam.dmi', INFINITY, INFINITY)
		RegisterSignal(snared_victim, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_dist))
	if(!length(beams))
		return INITIALIZE_HINT_QDEL
	QDEL_IN(src, leash_life)

/// To remove beams after the leash_ball is destroyed and also unregister all victims
/obj/structure/xeno/aoe_leash/Destroy()
	for(var/mob/living/carbon/human/victim AS in leash_victims)
		UnregisterSignal(victim, COMSIG_MOVABLE_PRE_MOVE)
		REMOVE_TRAIT(victim, TRAIT_LEASHED, src)
	leash_victims = null
	QDEL_LIST(beams)
	return ..()

/// Humans caught in the aoe_leash will be pulled back if they leave it's radius
/obj/structure/xeno/aoe_leash/proc/check_dist(datum/leash_victim, atom/newloc)
	SIGNAL_HANDLER
	if(get_dist(newloc, src) >= leash_radius)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// This is so that xenos can remove leash balls
/obj/structure/xeno/aoe_leash/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	xeno_attacker.visible_message(span_xenonotice("\The [xeno_attacker] starts tearing down \the [src]!"), \
	span_xenonotice("We start to tear down \the [src]."))
	if(!do_after(xeno_attacker, 1 SECONDS, NONE, xeno_attacker, BUSY_ICON_GENERIC) || QDELETED(src))
		return
	xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	xeno_attacker.visible_message(span_xenonotice("\The [xeno_attacker] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, destroy_sound, 25)
	take_damage(max_integrity)

// ***************************************
// *********** Spiderling Section
// ***************************************

/datum/action/ability/xeno_action/create_spiderling
	name = "Birth Spiderling"
	desc = "Give birth to a spiderling after a short charge-up. The spiderlings will follow you until death. You can only deploy 5 spiderlings at one time."
	action_icon_state = "spawn_spiderling"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	ability_cost = 80
	cooldown_duration = 15 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_IGNORE_COOLDOWN
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_SPIDERLING,
	)
	var/current_charges = 5
	/// List of all our spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/spiderlings = list()

/datum/action/ability/xeno_action/create_spiderling/give_action(mob/living/L)
	. = ..()
	var/max_spiderlings = xeno_owner?.xeno_caste.max_spiderlings ? xeno_owner.xeno_caste.max_spiderlings : 5
	desc = "Give birth to a spiderling after a short charge-up. The spiderlings will follow you until death. You can only deploy [max_spiderlings] spiderlings at one time."

	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_charges]/[initial(current_charges)]")
	visual_references[VREF_MUTABLE_SPIDERLING_CHARGES] = counter_maptext

/datum/action/ability/xeno_action/create_spiderling/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_SPIDERLING_CHARGES])
	visual_references[VREF_MUTABLE_SPIDERLING_CHARGES] = null

/datum/action/ability/xeno_action/create_spiderling/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_SPIDERLING_CHARGES])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_SPIDERLING_CHARGES]
	number?.maptext = MAPTEXT("[current_charges]/[initial(current_charges)]")
	visual_references[VREF_MUTABLE_SPIDERLING_CHARGES] = number
	button.add_overlay(visual_references[VREF_MUTABLE_SPIDERLING_CHARGES])
	return ..()

/datum/action/ability/xeno_action/create_spiderling/on_cooldown_finish()
	current_charges = clamp(current_charges+1, 0, initial(current_charges))
	update_button_icon()
	if(current_charges < initial(current_charges))
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish)), cooldown_duration, TIMER_STOPPABLE)
		return
	return ..()

/datum/action/ability/xeno_action/create_spiderling/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(cooldown_timer && current_charges)
		return TRUE

/// The action to create spiderlings
/datum/action/ability/xeno_action/create_spiderling/action_activate()
	. = ..()

	if(owner.do_actions)
		return fail_activate()

	if(current_charges <= 0)
		return fail_activate()

	if(length(spiderlings) >= xeno_owner.xeno_caste.max_spiderlings)
		xeno_owner.balloon_alert(xeno_owner, "Max Spiderlings")
		return fail_activate()

	if(!do_after(owner, 0.5 SECONDS, IGNORE_LOC_CHANGE, owner, BUSY_ICON_DANGER))
		return fail_activate()

	current_charges--
	add_spiderling()
	succeed_activate()
	add_cooldown()

/// Adds spiderlings to spiderling list and registers them for death so we can remove them later
/datum/action/ability/xeno_action/create_spiderling/proc/add_spiderling()
	/// This creates and stores the spiderling so we can reassign the owner for spider swarm and cap how many spiderlings you can have at once
	var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new(owner.loc, owner, owner)
	RegisterSignals(new_spiderling, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(remove_spiderling))
	spiderlings += new_spiderling
	new_spiderling.pixel_x = rand(-8, 8)
	new_spiderling.pixel_y = rand(-8, 8)
	return TRUE

/// Removes spiderling from spiderling list and unregisters death signal
/datum/action/ability/xeno_action/create_spiderling/proc/remove_spiderling(datum/source)
	SIGNAL_HANDLER
	spiderlings -= source
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_QDELETING))

// ***************************************
// *********** Burrow
// ***************************************

/datum/action/ability/xeno_action/burrow
	name = "Burrow"
	desc = "Burrow into the ground, allowing you and your active spiderlings to hide in plain sight. You cannot use abilities, attack nor move while burrowed. Use the ability again to unburrow if you're already burrowed."
	action_icon_state = "burrow"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	ability_cost = 0
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BURROW,
	)
	use_state_flags = ABILITY_USE_BURROWED

/datum/action/ability/xeno_action/burrow/action_activate()
	. = ..()
	/// We need the list of spiderlings so that we can burrow them
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	/// Here we make every single spiderling that we have also burrow and assign a signal so that they unburrow too
	for(var/mob/living/carbon/xenomorph/spiderling/spiderling AS in create_spiderling_action?.spiderlings)
		/// Here we trigger the burrow proc, the registering happens there
		var/datum/action/ability/xeno_action/burrow/spiderling_burrow = spiderling.actions_by_path[/datum/action/ability/xeno_action/burrow]
		spiderling_burrow.xeno_burrow()
	xeno_burrow()
	succeed_activate()

/// Burrow code for xenomorphs
/datum/action/ability/xeno_action/burrow/proc/xeno_burrow()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(xeno_owner, TRAIT_BURROWED))
		to_chat(xeno_owner, span_xenowarning("We start burrowing into the ground..."))
		INVOKE_ASYNC(src, PROC_REF(xeno_burrow_doafter))
		return
	UnregisterSignal(xeno_owner, COMSIG_XENOMORPH_TAKING_DAMAGE)
	REMOVE_TRAIT(xeno_owner, TRAIT_NON_FLAMMABLE, initial(name))
	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyRating(fire = -100)
	xeno_owner.hard_armor = xeno_owner.hard_armor.modifyRating(fire = -100)
	xeno_owner.mouse_opacity = initial(xeno_owner.mouse_opacity)
	xeno_owner.density = TRUE
	xeno_owner.allow_pass_flags &= ~PASSABLE
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	xeno_owner.update_icons()
	add_cooldown()
	owner.unbuckle_all_mobs(TRUE)

/// Called by xeno_burrow only when burrowing
/datum/action/ability/xeno_action/burrow/proc/xeno_burrow_doafter()
	if(!do_after(owner, 3 SECONDS, NONE, null, BUSY_ICON_DANGER))
		return
	to_chat(owner, span_xenowarning("We are now burrowed, hidden in plain sight and ready to strike."))
	// This part here actually burrows the xeno
	owner.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	owner.density = FALSE
	owner.allow_pass_flags |= PASSABLE
	// Here we prevent the xeno from moving or attacking or using abilities until they unburrow by clicking the ability
	ADD_TRAIT(owner, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(owner, TRAIT_BURROWED, WIDOW_ABILITY_TRAIT)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, WIDOW_ABILITY_TRAIT)
	// We register for movement so that we unburrow if bombed
	ADD_TRAIT(xeno_owner, TRAIT_NON_FLAMMABLE, initial(name))
	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyRating(fire = 100)
	xeno_owner.hard_armor = xeno_owner.hard_armor.modifyRating(fire = 100)
	// Update here without waiting for life
	xeno_owner.update_icons()
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(xeno_burrow))

// ***************************************
// *********** Attach Spiderlings
// ***************************************
/datum/action/ability/xeno_action/attach_spiderlings
	name = "Attach Spiderlings"
	desc = "Attach your current spiderlings to you "
	action_icon_state = "attach_spiderling"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	ability_cost = 0
	cooldown_duration = 0 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ATTACH_SPIDERLINGS,
	)
	///the attached spiderlings
	var/list/mob/living/carbon/xenomorph/spiderling/attached_spiderlings = list()
	///how many times we attempt to attach adjacent spiderligns
	var/attach_attempts = 5

/datum/action/ability/xeno_action/attach_spiderlings/action_activate()
	. = ..()
	if(owner.buckled_mobs)
		/// yeet off all spiderlings if we are carrying any
		owner.unbuckle_all_mobs(TRUE)
		return
	var/datum/action/ability/xeno_action/create_spiderling/create_spiderling_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/create_spiderling]
	if(!(length(create_spiderling_action.spiderlings)))
		xeno_owner.balloon_alert(xeno_owner, "No spiderlings")
		return fail_activate()
	var/list/mob/living/carbon/xenomorph/spiderling/remaining_spiderlings = create_spiderling_action.spiderlings.Copy()
	// First make the spiderlings stop what they are doing and return to the widow
	for(var/mob/spider in remaining_spiderlings)
		var/datum/component/ai_controller/AI = spider.GetComponent(/datum/component/ai_controller)
		AI?.ai_behavior.change_action(ESCORTING_ATOM, AI.ai_behavior.escorted_atom)
	grab_spiderlings(remaining_spiderlings, attach_attempts)
	succeed_activate()

/// this proc scoops up adjacent spiderlings and then calls ride_widow on them
/datum/action/ability/xeno_action/attach_spiderlings/proc/grab_spiderlings(list/mob/living/carbon/xenomorph/spiderling/remaining_list, number_of_attempts_left)
	if(number_of_attempts_left <= 0)
		return
	for(var/mob/living/carbon/xenomorph/spiderling/remaining_spiderling AS in remaining_list)
		SEND_SIGNAL(owner, COMSIG_SPIDERLING_CHANGE_ALL_ORDER, SPIDERLING_RECALL) //So spiderlings move towards the buckle
		if(!owner.Adjacent(remaining_spiderling))
			continue
		remaining_list -= remaining_spiderling
		owner.buckle_mob(remaining_spiderling, TRUE, TRUE, 90, FALSE, FALSE)
		ADD_TRAIT(remaining_spiderling, TRAIT_IMMOBILE, WIDOW_ABILITY_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(grab_spiderlings), remaining_list, number_of_attempts_left - 1), 1)

// ***************************************
// *********** Web Spit
// ***************************************

/datum/action/ability/activable/xeno/web_spit
	name = "Web Spit"
	desc = "Stun and blind the target with a web projectile"
	action_icon_state = "web_projectile"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	ability_cost = 100
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WEB_SPIT,
	)

/datum/action/ability/activable/xeno/web_spit/use_ability(atom/target)
	var/datum/ammo/xeno/web_projectile/web = GLOB.ammo_list[/datum/ammo/xeno/web_projectile]
	var/atom/movable/projectile/newspit = new /atom/movable/projectile(get_turf(xeno_owner))

	newspit.generate_bullet(web)
	newspit.def_zone = xeno_owner.get_limbzone_target()

	newspit.fire_at(target, xeno_owner, xeno_owner, newspit.ammo.max_range)
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/create_hugger
	name = "Create Hugger"
	desc = "Create a facehugger."
	action_icon_state = "larval hugger"
	action_icon = 'icons/Xeno/actions/carrier.dmi'
	ability_cost = 60
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_HUGGER,
	)

/datum/action/ability/xeno_action/create_hugger/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			owner.balloon_alert(owner, "Need empty hands")
		return FALSE

/datum/action/ability/xeno_action/create_hugger/action_activate()
	if(!do_after(owner, 1 SECONDS, IGNORE_LOC_CHANGE, owner, BUSY_ICON_HOSTILE))
		return FALSE
	var/obj/item/clothing/mask/facehugger/hugger = new(owner.loc)
	hugger.hivenumber = owner.get_xeno_hivenumber()
	owner.put_in_hands(hugger)
	add_cooldown()
	succeed_activate()

// ***************************************
// *********** Unleash spiderlings
// ***************************************
/datum/action/ability/xeno_action/widow_unleash
	name = "Unleash Spiderlings"
	desc = "Send out your spiderlings to attack nearby humans"
	action_icon_state = "unleash"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_UNLEASH_SPIDERLINGS,
	)

/datum/action/ability/xeno_action/widow_unleash/action_activate(mob/living/victim)
	if(SEND_SIGNAL(owner, COMSIG_SPIDERLING_CHANGE_ALL_ORDER, SPIDERLING_ATTACK))
		owner.balloon_alert(owner, "attacking")
	else
		owner.balloon_alert(owner, "fail")

// ***************************************
// *********** Recall spiderlings
// ***************************************
/datum/action/ability/xeno_action/widow_recall
	name = "Recall Spiderlings"
	desc = "Recall your siderlings to follow you once more"
	action_icon_state = "recall"
	action_icon = 'icons/Xeno/actions/widow.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RECALL_SPIDERLINGS,
	)

/datum/action/ability/xeno_action/widow_recall/action_activate(mob/living/victim)
	if(SEND_SIGNAL(owner, COMSIG_SPIDERLING_CHANGE_ALL_ORDER, SPIDERLING_RECALL))
		owner.balloon_alert(owner, "recalling")
	else
		owner.balloon_alert(owner, "fail")

/datum/action/ability/xeno_action/spider_venom
	name = "Widow's Poison"
	desc = "Poison your target with incapacitating venom"
	ability_cost = 0
	cooldown_duration = 0
	keybind_flags = ABILITY_USE_STAGGERED | ABILITY_IGNORE_SELECTED_ABILITY
	hidden = TRUE

/datum/action/ability/xeno_action/spider_venom/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_bite))

/datum/action/ability/xeno_action/spider_venom/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING)

/datum/action/ability/xeno_action/spider_venom/proc/on_bite(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	if(!ishuman(target))
		return
	target.apply_status_effect(STATUS_EFFECT_SPIDER_VENOM)
