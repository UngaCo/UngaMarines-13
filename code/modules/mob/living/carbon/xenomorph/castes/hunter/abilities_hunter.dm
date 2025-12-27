#define DISGUISE_SLOWDOWN 2

// ***************************************
// *********** Stealth
// ***************************************
/datum/action/ability/xeno_action/stealth
	name = "Toggle Stealth"
	desc = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	action_icon_state = "hunter_invisibility"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	ability_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_STEALTH,
	)
	cooldown_duration = HUNTER_STEALTH_COOLDOWN
	var/last_stealth = null
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	var/stealth_alpha_multiplier = 1

/datum/action/ability/xeno_action/stealth/remove_action()
	if(stealth)
		cancel_stealth()
	return ..()

/datum/action/ability/xeno_action/stealth/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(xeno_owner.on_fire)
		if(!silent)
			owner.balloon_alert(xeno_owner, "Cannot enter Stealth!")
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/stealth/on_cooldown_finish()
	owner.balloon_alert(owner, "Stealth ready.")
	playsound(owner, 'sound/effects/alien/newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/stealth/action_activate()
	if(stealth)
		cancel_stealth()
		return TRUE
	if(HAS_TRAIT(owner, TRAIT_STEALTH))   // stops stealth and disguise from stacking
		owner.balloon_alert(owner, "Already in a form of stealth!")
		return
	succeed_activate()
	owner.balloon_alert(owner, "We vanish into the shadows.")
	last_stealth = world.time
	stealth = TRUE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(handle_stealth_move))
	RegisterSignal(owner, COMSIG_XENOMORPH_POUNCE_END, PROC_REF(sneak_attack_pounce))
	RegisterSignal(owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignals(owner, list(COMSIG_XENOMORPH_ATTACK_LIVING, COMSIG_XENOMORPH_DISARM_HUMAN), PROC_REF(sneak_attack_slash))
	RegisterSignal(owner, COMSIG_XENOMORPH_ZONE_SELECT, PROC_REF(sneak_attack_zone))
	RegisterSignal(owner, COMSIG_XENOMORPH_PLASMA_REGEN, PROC_REF(plasma_regen))

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignals(owner, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_HANDLE_VENTCRAWL), PROC_REF(cancel_stealth))

	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(on_obj_attack))

	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_ADDTRAIT(TRAIT_FLOORED)), PROC_REF(cancel_stealth))

	RegisterSignal(owner, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(damage_taken))

	ADD_TRAIT(owner, TRAIT_STEALTH, TRAIT_STEALTH)

	handle_stealth()
	addtimer(CALLBACK(src, PROC_REF(sneak_attack_cooldown)), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.
	START_PROCESSING(SSprocessing, src)

/datum/action/ability/xeno_action/stealth/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	SIGNAL_HANDLER
	add_cooldown()
	owner.balloon_alert(owner, "We emerge from the shadows.")

	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_XENOMORPH_POUNCE_END,
		COMSIG_XENOMORPH_LEAP_BUMP,
		COMSIG_XENO_LIVING_THROW_HIT,
		COMSIG_XENOMORPH_ATTACK_LIVING,
		COMSIG_XENOMORPH_DISARM_HUMAN,
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_OBJ,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_HANDLE_VENTCRAWL,
		SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
		SIGNAL_ADDTRAIT(TRAIT_FLOORED),
		COMSIG_XENOMORPH_ZONE_SELECT,
		COMSIG_XENOMORPH_PLASMA_REGEN,
		COMSIG_XENOMORPH_TAKING_DAMAGE,))

	stealth = FALSE
	can_sneak_attack = FALSE
	REMOVE_TRAIT(owner, TRAIT_STEALTH, TRAIT_STEALTH)
	animate(owner, 1 SECONDS, alpha = 255) //no transparency/translucency

///Signal wrapper to verify that an object is damageable before breaking stealth
/datum/action/ability/xeno_action/stealth/proc/on_obj_attack(datum/source, obj/attacked)
	SIGNAL_HANDLER
	if(attacked.resistance_flags & XENO_DAMAGEABLE)
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_cooldown()
	if(!stealth || can_sneak_attack)
		return
	can_sneak_attack = TRUE
	xeno_owner.balloon_alert(xeno_owner, "Sneak Attack ready.")
	playsound(xeno_owner, 'sound/effects/alien/newlarva.ogg', 25, 0, 1)

/datum/action/ability/xeno_action/stealth/process()
	if(!stealth)
		return PROCESS_KILL
	handle_stealth()

///Handles moving while in stealth
/datum/action/ability/xeno_action/stealth/proc/handle_stealth_move()
	SIGNAL_HANDLER
	if(xeno_owner.m_intent == MOVE_INTENT_WALK)
		handle_plasma_usage(xeno_owner, HUNTER_STEALTH_WALK_PLASMADRAIN)
		animate(xeno_owner, 0.5 SECONDS, alpha = HUNTER_STEALTH_WALK_ALPHA * stealth_alpha_multiplier)
	else
		handle_plasma_usage(xeno_owner, HUNTER_STEALTH_RUN_PLASMADRAIN)
		animate(xeno_owner, 0.5 SECONDS, alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier)
	if(!xeno_owner.plasma_stored)
		to_chat(xeno_owner, span_xenodanger("We lack sufficient plasma to remain camouflaged."))
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/handle_stealth()
	SIGNAL_HANDLER
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY)
		animate(xeno_owner, 1.5 SECONDS, alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier)
		return
	if(xeno_owner.last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY)
		animate(xeno_owner, 0.5 SECONDS, alpha = HUNTER_STEALTH_STILL_ALPHA * stealth_alpha_multiplier)
	if(!xeno_owner.plasma_stored)
		to_chat(xeno_owner, span_xenodanger("We lack sufficient plasma to remain camouflaged."))
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/handle_plasma_usage(mob/user, amount)
	if(ispath(xeno_owner.loc_weeds_type, /obj/alien/weeds))
		return
	xeno_owner.use_plasma(amount)

/// Callback listening for a xeno_owner using the pounce ability
/datum/action/ability/xeno_action/stealth/proc/sneak_attack_pounce()
	SIGNAL_HANDLER
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent(MOVE_INTENT_RUN)
		if(owner.hud_used?.move_intent)
			owner.hud_used.move_intent.icon_state = "running"
		owner.update_icons()

	cancel_stealth()

/// Callback for when a mob gets hit as part of a pounce
/datum/action/ability/xeno_action/stealth/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	if(living_target.stat || isxeno(living_target))
		return
	if(!can_sneak_attack)
		return

	var/damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier

	living_target.adjust_stagger(3 SECONDS)
	living_target.add_slowdown(1)
	living_target.apply_damage(damage, BRUTE, xeno_owner.zone_selected, MELEE, , penetration = HUNTER_SNEAK_SLASH_ARMOR_PEN) // additional damage
	to_chat(xeno_owner, span_xenodanger("Pouncing from the shadows, we stagger our victim."))

	cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	if(!can_sneak_attack)
		return

	damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier

	owner.visible_message(span_danger("\The [owner] strikes [target] with vicious precision!"), \
	span_danger("We strike [target] with vicious precision!"))
	target.adjust_stagger(2 SECONDS)
	target.add_slowdown(1)
	target.ParalyzeNoChain(1 SECONDS)
	target.apply_damage(damage, BRUTE, xeno_owner.zone_selected, MELEE, , penetration = HUNTER_SNEAK_SLASH_ARMOR_PEN) // additional damage

	cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/plasma_regen(datum/source, list/plasma_mod)
	SIGNAL_HANDLER
	if(owner.last_move_intent < world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod[1] *= 0.5
	else
		plasma_mod[1] = 0

/datum/action/ability/xeno_action/stealth/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	if(damage_taken > xeno_owner.xeno_caste.stealth_break_threshold)
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_zone()
	SIGNAL_HANDLER
	if(!can_sneak_attack)
		return
	return COMSIG_ACCURATE_ZONE

/datum/action/ability/activable/xeno/hunter_blink
	name = "Hunter's Blink"
	desc = "Teleport to the selected target, gaining a short bonus to attack speed."
	action_icon_state = "blink"
	action_icon = 'icons/Xeno/actions/chimera.dmi'
	target_flags = ABILITY_MOB_TARGET
	use_state_flags = ABILITY_USE_BUCKLED
	ability_cost = 50
	cooldown_duration = 8 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_BLINK,
	)

/datum/action/ability/activable/xeno/hunter_blink/use_ability(atom/A)
	. = ..()
	if(!isliving(A))
		return fail_activate()
	if(get_dist(owner, A) > 7 || owner.z != A.z)
		owner.balloon_alert(owner, "We are too far away!")
		return fail_activate()

	var/turf/target_turf = get_turf(A)
	var/turf/origin_turf = get_turf(xeno_owner)

	new /obj/effect/temp_visual/blink_portal(origin_turf)
	new /obj/effect/temp_visual/blink_portal(target_turf)
	new /obj/effect/particle_effect/sparks(origin_turf)
	new /obj/effect/particle_effect/sparks(target_turf)
	playsound(target_turf, 'sound/effects/EMPulse.ogg', 25, TRUE)

	xeno_owner.forceMove(target_turf)
	xeno_owner.apply_status_effect(/datum/status_effect/hunt)

	succeed_activate()
	add_cooldown()

	var/datum/action/ability/activable/xeno/hunter_pounce = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce]
	if(hunter_pounce)
		hunter_pounce.add_cooldown(3 SECONDS)

/datum/action/ability/activable/xeno/hunter_blink/on_cooldown_finish()
	owner.balloon_alert(owner, "Blink ready")
	owner.playsound_local(owner, 'sound/effects/alien/newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Hunter's Pounce
// ***************************************
#define HUNTER_POUNCE_RANGE 7 // in tiles
#define XENO_POUNCE_SPEED 2
#define XENO_POUNCE_STUN_DURATION 2 SECONDS
#define XENO_POUNCE_STANDBY_DURATION 0.5 SECONDS
#define XENO_POUNCE_SHIELD_STUN_DURATION 6 SECONDS

/datum/action/ability/activable/xeno/pounce
	name = "Pounce"
	desc = "Leap at your target, tackling and disarming them."
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	ability_cost = 20
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_POUNCE,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	/// The range of this ability.
	var/pounce_range = HUNTER_POUNCE_RANGE
	///pass_flags given when leaping
	var/leap_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_XENO
	/// The stun duration (inflicted to mob) on successful tackle.
	var/stun_duration = XENO_POUNCE_STUN_DURATION
	/// The immobilize duration (inflicted to self) on successful tackle.
	var/self_immobilize_duration = XENO_POUNCE_STANDBY_DURATION

/datum/action/ability/activable/xeno/pounce/on_cooldown_finish()
	owner.balloon_alert(owner, "Pounce ready")
	owner.playsound_local(owner, 'sound/effects/alien/newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	if(!A)
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/pounce/use_ability(atom/A)
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	RegisterSignal(owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(object_hit))
	RegisterSignal(owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE)
	xeno_owner.xeno_flags |= XENO_LEAPING
	xeno_owner.add_pass_flags(leap_pass_flags, type)
	xeno_owner.throw_at(A, pounce_range, XENO_POUNCE_SPEED, xeno_owner)
	succeed_activate()
	add_cooldown()
	var/datum/action/ability/activable/xeno/hunter_blink = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/hunter_blink]
	if(hunter_blink)
		hunter_blink.add_cooldown(3 SECONDS)

/datum/action/ability/activable/xeno/pounce/proc/movement_fx()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/after_image(get_turf(owner), owner) //Create the after image.

/datum/action/ability/activable/xeno/pounce/proc/object_hit(datum/source, obj/object_target, speed)
	SIGNAL_HANDLER
	object_target.hitby(owner, speed)
	pounce_complete()

/datum/action/ability/activable/xeno/pounce/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	. = TRUE
	if(living_target.stat || isxeno(living_target)) //we leap past xenos
		return

	if(ishuman(living_target) && (angle_to_dir(Get_Angle(xeno_owner.throw_source, living_target)) in reverse_nearby_direction(living_target.dir)))
		var/mob/living/carbon/human/human_target = living_target
		if(!human_target.check_shields(COMBAT_TOUCH_ATTACK, 30, MELEE))
			xeno_owner.Paralyze(XENO_POUNCE_SHIELD_STUN_DURATION)
			xeno_owner.set_throwing(FALSE)
			playsound(xeno_owner, 'sound/machines/bonk.ogg', 50, FALSE)
			return
	trigger_pounce_effect(living_target)
	pounce_complete()

///Triggers the effect of a successful pounce on the target.
/datum/action/ability/activable/xeno/pounce/proc/trigger_pounce_effect(mob/living/living_target)
	playsound(get_turf(living_target), 'sound/voice/alien/pounce.ogg', 25, TRUE)
	xeno_owner.Immobilize(self_immobilize_duration)
	xeno_owner.set_throwing(FALSE)
	xeno_owner.forceMove(get_turf(living_target))
	living_target.Knockdown(stun_duration)

/datum/action/ability/activable/xeno/pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENOMORPH_LEAP_BUMP, COMSIG_MOVABLE_POST_THROW))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)
	xeno_owner.set_throwing(FALSE)
	xeno_owner.xeno_flags &= ~XENO_LEAPING
	xeno_owner.remove_pass_flags(leap_pass_flags, type)

/datum/action/ability/activable/xeno/pounce/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, pounce_range))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/pounce/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, pounce_range))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Hunter's Mark
// ***************************************
/datum/action/ability/activable/xeno/hunter_mark
	name = "Hunter's Mark"
	desc = "Psychically mark a creature you have line of sight to, allowing you to sense its direction, distance and location with Psychic Trace."
	action_icon_state = "hunter_mark"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_MARK,
	)
	cooldown_duration = 5 SECONDS
	///the target marked
	var/atom/movable/marked_target

/datum/action/ability/activable/xeno/hunter_mark/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!isliving(A) && (xeno_owner.xeno_caste.upgrade != XENO_UPGRADE_PRIMO) || !ismovable(A))
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("We cannot psychically mark this target!"))
		return FALSE

	if(A == marked_target)
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("This is already our target!"))
		return FALSE

	if(A == xeno_owner)
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("Why would we target ourselves?"))
		return FALSE

	if(!line_of_sight(xeno_owner, A)) //Need line of sight.
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("We require line of sight to mark them!"))
		return FALSE

	return TRUE

/datum/action/ability/activable/xeno/hunter_mark/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We are able to impose our psychic mark again.</b>"))
	owner.playsound_local(owner, 'sound/effects/alien/newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/hunter_mark/use_ability(atom/A)
	xeno_owner.face_atom(A) //Face towards the target so we don't look silly

	if(!line_of_sight(xeno_owner, A)) //Need line of sight.
		to_chat(xeno_owner, span_xenowarning("We lost line of sight to the target!"))
		return fail_activate()

	if(marked_target)
		UnregisterSignal(marked_target, COMSIG_QDELETING)

	marked_target = A

	RegisterSignal(marked_target, COMSIG_QDELETING, PROC_REF(unset_target)) //For var clean up

	to_chat(xeno_owner, span_xenodanger("We psychically mark [A] as our quarry."))
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/ghost.ogg', 25, 0, 1)

	succeed_activate()

	GLOB.round_statistics.hunter_marks++
	SSblackbox.record_feedback(FEEDBACK_TALLY, "round_statistics", 1, "hunter_marks")
	add_cooldown()

///Nulls the target of our hunter's mark
/datum/action/ability/activable/xeno/hunter_mark/proc/unset_target()
	SIGNAL_HANDLER
	UnregisterSignal(marked_target, COMSIG_QDELETING)
	marked_target = null //Nullify hunter's mark target and clear the var

// ***************************************
// *********** Psychic Trace
// ***************************************
/datum/action/ability/xeno_action/psychic_trace
	name = "Psychic Trace"
	desc = "Psychically ping the creature you marked, letting you know its direction, distance and location, and general condition."
	action_icon_state = "toggle_queen_zoom"
	action_icon = 'icons/Xeno/actions/queen.dmi'
	ability_cost = 1 //Token amount
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_TRACE,
	)
	cooldown_duration = HUNTER_PSYCHIC_TRACE_COOLDOWN

/datum/action/ability/xeno_action/psychic_trace/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/datum/action/ability/activable/xeno/hunter_mark/mark = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]

	if(!mark.marked_target)
		if(!silent)
			to_chat(owner, span_xenowarning("We have no target we can trace!"))
		return FALSE

	if(mark.marked_target.z != owner.z)
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away, and is beyond our senses!"))
		return FALSE

/datum/action/ability/xeno_action/psychic_trace/action_activate()
	var/datum/action/ability/activable/xeno/hunter_mark/mark = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]
	to_chat(xeno_owner, span_xenodanger("We sense our quarry <b>[mark.marked_target]</b> is currently located in <b>[AREACOORD_NO_Z(mark.marked_target)]</b> and is <b>[get_dist(xeno_owner, mark.marked_target)]</b> tiles away. It is <b>[calculate_mark_health(mark.marked_target)]</b> and <b>[mark.marked_target.status_flags & XENO_HOST ? "impregnated" : "barren"]</b>."))
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/ghost2.ogg', 10, 0, 1)

	var/atom/movable/screen/arrow/hunter_mark_arrow/arrow_hud = new
	//Prepare the tracker object and set its parameters
	arrow_hud.add_hud(xeno_owner, mark.marked_target) //set the tracker parameters
	arrow_hud.process() //Update immediately

	add_cooldown()

	return succeed_activate()

///Where we calculate the approximate health of our trace target
/datum/action/ability/xeno_action/psychic_trace/proc/calculate_mark_health(mob/living/target)
	if(!isliving(target))
		return "not living"

	if(target.stat == DEAD)
		return "deceased"

	var/percentage = round(target.health * 100 / target.maxHealth)
	switch(percentage)
		if(100 to INFINITY)
			return "in perfect health"
		if(76 to 99)
			return "slightly injured"
		if(51 to 75)
			return "moderately injured"
		if(26 to 50)
			return "badly injured"
		if(1 to 25)
			return "severely injured"
		if(-51 to 0)
			return "critically injured"
		if(-99 to -50)
			return "on the verge of death"
		else
			return "deceased"

/datum/action/ability/xeno_action/mirage
	name = "Mirage"
	desc = "Create mirror images of ourselves. Reactivate to swap with an illusion."
	action_icon_state = "mirror_image"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_MIRAGE,
	)
	cooldown_duration = 15 SECONDS
	///How long will the illusions live
	var/illusion_life_time = 10 SECONDS
	///How many illusions are created
	var/illusion_count = 3
	/// List of illusions
	var/list/mob/illusion/illusions = list()
	/// If swap has been used during the current set of illusions
	var/swap_used = FALSE

/datum/action/ability/xeno_action/mirage/remove_action()
	illusions = list() //the actual illusions fade on their own, and the cooldown object may be qdel'd
	return ..()

/datum/action/ability/xeno_action/mirage/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(swap_used)
		if(!silent)
			to_chat(owner, span_xenowarning("We already swapped with an illusion!"))
		return FALSE

/datum/action/ability/xeno_action/mirage/action_activate()
	succeed_activate()
	if(!length(illusions))
		spawn_illusions()
	else
		swap()

/// Spawns a set of illusions around the hunter
/datum/action/ability/xeno_action/mirage/proc/spawn_illusions()
	var/mob/illusion/xeno/center_illusion = new (owner.loc, owner, owner, illusion_life_time)
	for(var/i in 1 to (illusion_count - 1))
		illusions += new /mob/illusion/xeno(owner.loc, owner, center_illusion, illusion_life_time)
	illusions += center_illusion
	addtimer(CALLBACK(src, PROC_REF(clean_illusions)), illusion_life_time)

/// Clean up the illusions list
/datum/action/ability/xeno_action/mirage/proc/clean_illusions()
	illusions = list()
	add_cooldown()
	swap_used = FALSE

/// Swap places of hunter and an illusion
/datum/action/ability/xeno_action/mirage/proc/swap()
	swap_used = TRUE
	if(!length(illusions))
		to_chat(xeno_owner, span_xenowarning("We have no illusions to swap with!"))
		return

	owner.drop_all_held_items()
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/swap.ogg', 10, 0, 1)
	var/turf/current_turf = get_turf(xeno_owner)

	var/mob/selected_illusion = illusions[1]
	xeno_owner.forceMove(get_turf(selected_illusion.loc))
	selected_illusion.forceMove(current_turf)

// ***************************************
// *********** One Hunter Army
// ***************************************
#define ILUSSION_CHANCE 70
#define ILLUSION_LIFETIME 5 SECONDS

/datum/action/ability/xeno_action/hunter_army
	name = "One Hunter Army"
	desc = ""
	ability_cost = 0
	cooldown_duration = 0
	keybind_flags = ABILITY_USE_STAGGERED | ABILITY_IGNORE_SELECTED_ABILITY
	hidden = TRUE

/datum/action/ability/xeno_action/hunter_army/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_attack))

/datum/action/ability/xeno_action/hunter_army/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING)

/datum/action/ability/xeno_action/hunter_army/proc/on_attack(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	if(!isliving(target))
		return

	var/target_turf = get_step_rand(target.loc)

	if(prob(ILUSSION_CHANCE))
		new /mob/illusion/xeno(target_turf, xeno_owner, xeno_owner, ILLUSION_LIFETIME)

// ***************************************
// *********** Crippling strike
// ***************************************

/datum/action/ability/xeno_action/crippling_strike/hunter
	additional_damage = 1
	heal_amount = 12
	plasma_gain = 20
	decay_time = 15 SECONDS

#undef ILUSSION_CHANCE
#undef ILLUSION_LIFETIME
