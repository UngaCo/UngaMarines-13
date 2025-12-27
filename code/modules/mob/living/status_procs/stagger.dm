///Returns if staggered
/mob/living/proc/IsStaggered()
	return has_status_effect(STATUS_EFFECT_STAGGER)

///Returns remaining stagger duration
/mob/living/proc/AmountStaggered()
	var/datum/status_effect/incapacitating/stagger/current_stagger = has_status_effect(STATUS_EFFECT_STAGGER)
	return current_stagger ? current_stagger.duration - world.time : 0

///Applies stagger from current world time unless existing duration is higher
/mob/living/proc/Stagger(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stagger/current_stagger = has_status_effect(STATUS_EFFECT_STAGGER)
	if(current_stagger)
		current_stagger.duration = max(world.time + amount, current_stagger.duration)
	else if(amount > 0)
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger

///Used to set stagger to a set amount, commonly to remove it
/mob/living/proc/set_stagger(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/stagger/current_stagger = has_status_effect(STATUS_EFFECT_STAGGER)
	if(amount <= 0)
		if(current_stagger)
			qdel(current_stagger)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_stagger)
		current_stagger.duration = world.time + amount
	else
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger

///Applies stagger or adds to existing duration
/mob/living/proc/adjust_stagger(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STAGGERIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STAGGER, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stagger/current_stagger = has_status_effect(STATUS_EFFECT_STAGGER)
	if(current_stagger)
		current_stagger.duration += amount
	else if(amount > 0)
		current_stagger = apply_status_effect(STATUS_EFFECT_STAGGER, amount)

	return current_stagger
