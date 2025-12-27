#define STATUS_EFFECT_UPFRONT_EVASION /datum/status_effect/runner/upfront_evasion
#define STATUS_EFFECT_PASSING_GLANCE /datum/status_effect/runner/passing_glance
#define STATUS_EFFECT_INGRAINED_EVASION /datum/status_effect/runner/ingrained_evasion
#define STATUS_EFFECT_HEADSLAM /datum/status_effect/runner/headslam

/datum/xeno_mutation/runner
	category = "Enhancement"
	caste_restrictions = list("runner")

/datum/status_effect/runner
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	/// The xenomorph that owns this status effect.
	var/mob/living/carbon/xenomorph/xenomorph_owner

/datum/xeno_mutation/runner/upfront_evasion
	name = "Upfront Evasion"
	desc = "Evasion длится на 3 секунды больше, но не может быть автоматическим"
	cost = 7.5
	icon_state = "runner_upfront_evasion"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_UPFRONT_EVASION
	buff_desc = "+ 3 seconds longer Evasion, but no longer auto-refresh."

/atom/movable/screen/alert/status_effect/runner/upfront_evasion
	name = "Upfront Evasion"
	desc = "+ 3 seconds longer Evasion, but no longer auto-refresh."
	icon_state = "xenobuff_attack"

/datum/status_effect/runner/upfront_evasion
	id = "upgrade_upfront_evasion"
	alert_type = /atom/movable/screen/alert/status_effect/runner/upfront_evasion

	/// Amount of seconds that is added to Evasion's starting duration.
	var/evasion_extra_time = 3

/datum/status_effect/runner/upfront_evasion/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.auto_evasion_togglable = FALSE
	evasion.evasion_starting_duration += evasion_extra_time
	if(evasion.auto_evasion) // Turning it off and giving them the notification it happened.
		evasion.alternate_action_activate()
	return TRUE

/datum/status_effect/runner/upfront_evasion/on_remove()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.auto_evasion_togglable = initial(evasion.auto_evasion_togglable)
	evasion.evasion_starting_duration = initial(evasion.evasion_starting_duration)
	if(!evasion.auto_evasion) // Turning it on (since most Runners like auto-evasion) and giving them the notification it happened.
		evasion.alternate_action_activate()
	return ..()

//
//
//

/datum/xeno_mutation/runner/passing_glance
	name = "Passing Glance"
	desc = "Пока активен Evasion, контакт дизориентирует врага на 4 секунды."
	cost = 5
	icon_state = "runner_passing_glance"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_PASSING_GLANCE
	buff_desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 4 seconds"

/atom/movable/screen/alert/status_effect/runner/passing_glance
	name = "Passing Glance"
	desc = "While Evasion is on, moving onto the same location as a standing human will confuse them for 4 seconds"
	icon_state = "xenobuff_attack"

/datum/status_effect/runner/passing_glance
	id = "upgrade_passing_glance"
	alert_type = /atom/movable/screen/alert/status_effect/runner/passing_glance

	/// For the first structure, the amount of deciseconds that Evasion will confuse humans who are passed through.
	var/duration_initial = 4 SECONDS

/datum/status_effect/runner/passing_glance/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.evasion_passthrough = TRUE
	evasion.passthrough_confusion_length += get_duration(0)
	return TRUE

/datum/status_effect/runner/passing_glance/on_remove()
	var/datum/action/ability/xeno_action/evasion/evasion = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(!evasion)
		return
	evasion.evasion_passthrough = FALSE
	evasion.passthrough_confusion_length -= get_duration(0)
	return ..()

/// Returns the amount of deciseconds that Evasion will confuse humans who are passed through.
/datum/status_effect/runner/passing_glance/proc/get_duration(structure_count, include_initial = TRUE)
	return (include_initial ? duration_initial : 0)

//
//
//

/datum/xeno_mutation/runner/ingrained_evasion
	name = "Ingrained Evasion"
	desc = "Удаляет способность Evasion, но даёт пассивный 50% шанс уворота. Особо точные выстрелы уменьшают данный шанс."
	cost = 5
	icon_state = "runner_ingrained_evasion"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_INGRAINED_EVASION
	buff_desc = "You lose the ability, Evasion. You have a 50% to dodge projectiles with similar conditions as Evasion. Highly accurate projectiles will reduce your dodge chance."

/atom/movable/screen/alert/status_effect/runner/ingrained_evasion
	name = "Ingrained Evasion"
	desc = "You have a 50% to dodge projectiles with similar conditions as Evasion"
	icon_state = "xenobuff_attack"

/datum/status_effect/runner/ingrained_evasion
	id = "upgrade_ingrained_evasion"
	alert_type = /atom/movable/screen/alert/status_effect/runner/ingrained_evasion

	/// After this amount of time since their last move, they will no longer dodge projectiles.
	var/movement_leniency = 0.5 SECONDS
	/// Chance of dodging a projectile or thrown object.
	var/chance_initial = 50
	/// If a projectile's accuracy is above this value, then the dodge chance is decreased by each point above it.
	var/accuracy_reduction_threshold = 75

/datum/status_effect/runner/ingrained_evasion/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/evasion/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/evasion]
	if(ability)
		ability.remove_action(xenomorph_owner)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(dodge_projectile))
	RegisterSignal(xenomorph_owner, COMSIG_PRE_MOVABLE_IMPACT, PROC_REF(dodge_thrown_item))
	return TRUE

/datum/status_effect/runner/ingrained_evasion/on_remove()
	var/datum/action/ability/xeno_action/evasion/ability = new()
	ability.give_action(xenomorph_owner)
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT, COMSIG_PRE_MOVABLE_IMPACT))
	return ..()

// Checks if they can dodge at all.
/datum/status_effect/runner/ingrained_evasion/proc/can_dodge()
	if(xenomorph_owner.IsStun())
		return FALSE
	if(xenomorph_owner.IsKnockdown())
		return FALSE
	if(xenomorph_owner.IsParalyzed())
		return FALSE
	if(xenomorph_owner.IsUnconscious())
		return FALSE
	if(xenomorph_owner.IsSleeping())
		return FALSE
	if(xenomorph_owner.IsStaggered())
		return FALSE
	if(xenomorph_owner.on_fire)
		return FALSE
	if((xenomorph_owner.last_move_time < (world.time - movement_leniency)))
		return FALSE
	return TRUE

/// Checks if they can dodge a projectile. If they can, they do so.
/datum/status_effect/runner/ingrained_evasion/proc/dodge_projectile(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(!can_dodge())
		return FALSE
	if(xenomorph_owner.issamexenohive(proj.firer))
		return COMPONENT_PROJECTILE_DODGE
	if(proj.ammo.ammo_behavior_flags & AMMO_FLAME) // We can't dodge literal fire.
		return FALSE
	if(proj.original_target == xenomorph_owner && proj.distance_travelled < 2) // Pointblank shot.
		return FALSE
	if(prob(get_chance(TRUE, proj.accuracy ? -max(0, proj.accuracy - accuracy_reduction_threshold) : 0)))
		dodge_fx(proj)
		return COMPONENT_PROJECTILE_DODGE
	return FALSE

/// Checks if they can dodge a thrown object. If they can, they do so.
/datum/status_effect/runner/ingrained_evasion/proc/dodge_thrown_item(datum/source, atom/movable/thrown_atom)
	SIGNAL_HANDLER
	if(!isobj(thrown_atom) || !can_dodge())
		return FALSE
	if(prob(get_chance()))
		dodge_fx(thrown_atom)
		return COMPONENT_PRE_MOVABLE_IMPACT_DODGED
	return FALSE

/// Handles dodge effects and visuals.
/datum/status_effect/runner/ingrained_evasion/proc/dodge_fx(atom/movable/proj)
	xenomorph_owner.visible_message(span_warning("[xenomorph_owner] effortlessly dodges the [proj.name]!"), span_xenodanger("We effortlessly dodge the [proj.name]!"))
	xenomorph_owner.add_filter("ingrained_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(xenomorph_owner, TYPE_PROC_REF(/datum, remove_filter), "ingrained_evasion"), 0.5 SECONDS)
	xenomorph_owner.do_jitter_animation(4000)
	var/turf/current_turf = get_turf(xenomorph_owner)
	playsound(current_turf, pick('sound/effects/throw.ogg','sound/effects/alien/tail_swipe1.ogg', 'sound/effects/alien/tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/after_image/after_image
	for(var/i = 0 to 2)
		after_image = new /obj/effect/temp_visual/after_image(current_turf, xenomorph_owner)
		after_image.pixel_x = pick(randfloat(xenomorph_owner.pixel_x * 3, xenomorph_owner.pixel_x * 1.5), rand(0, xenomorph_owner.pixel_x * -1))

/// Returns the chance of dodging a projectile or thrown object. Will never be negative.
/datum/status_effect/runner/ingrained_evasion/proc/get_chance(include_initial = TRUE, additional_chance = 0)
	return max(0, (include_initial ? chance_initial : 0) + additional_chance)

//
//
//

/datum/xeno_mutation/runner/headslam
	name = "Head Slam"
	desc = "Стан от Pounce уменьшен в 4 раза, но дизориентирует и слепит врага на 3 секунды."
	cost = 5
	icon_state = "runner_headslam"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_HEADSLAM
	buff_desc = "Pounce stuns only for 25% as long. It now confuses and blurs your target's vision for 3 seconds."

/atom/movable/screen/alert/status_effect/runner/headslam
	name = "Head Slam"
	desc = "Pounce stuns only for 25% as long. It now confuses and blurs your target's vision for 1/2/3 seconds."
	icon_state = "xenobuff_attack"

/datum/status_effect/runner/headslam
	id = "upgrade_headslam"
	alert_type = /atom/movable/screen/alert/status_effect/runner/headslam

	/// The amount to multiply all stun and immobilize duration by.
	var/stun_duration_multiplier = 0.25
	/// Amount of deciseconds to confuse and the potency of blur by (divided by 5).
	var/debuff_duration = 3 SECONDS

/datum/status_effect/runner/headslam/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.stun_duration -= initial(pounce.stun_duration) * (1 - stun_duration_multiplier)
	pounce.self_immobilize_duration -= initial(pounce.self_immobilize_duration) * (1 - stun_duration_multiplier)
	pounce.savage_debuff_amount += debuff_duration
	return TRUE

/datum/status_effect/runner/headslam/on_remove()
	var/datum/action/ability/activable/xeno/pounce/runner/pounce = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/pounce/runner]
	if(!pounce)
		return
	pounce.stun_duration += initial(pounce.stun_duration) / (1 - stun_duration_multiplier)
	pounce.self_immobilize_duration += initial(pounce.self_immobilize_duration) * (1 - stun_duration_multiplier)
	pounce.savage_debuff_amount -= debuff_duration
	return ..()
