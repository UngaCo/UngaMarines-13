///Returns if unconscious
/mob/living/proc/IsUnconscious()
	return has_status_effect(STATUS_EFFECT_UNCONSCIOUS)

///Returns remaining unconscious duration
/mob/living/proc/AmountUnconscious()
	var/datum/status_effect/incapacitating/unconscious/current_unconscious = has_status_effect(STATUS_EFFECT_UNCONSCIOUS)
	return current_unconscious ? current_unconscious.duration - world.time : 0

///Applies unconscious from current world time unless existing duration is higher
/mob/living/proc/Unconscious(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/unconscious/current_unconscious = has_status_effect(STATUS_EFFECT_UNCONSCIOUS)
	if(current_unconscious)
		current_unconscious.duration = max(world.time + amount, current_unconscious.duration)
	else if(amount > 0)
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious

///Used to set unconscious to a set amount, commonly to remove it
/mob/living/proc/SetUnconscious(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/unconscious/current_unconscious = has_status_effect(STATUS_EFFECT_UNCONSCIOUS)
	if(amount <= 0)
		if(current_unconscious)
			qdel(current_unconscious)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_unconscious)
		current_unconscious.duration = world.time + amount
	else
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious

///Applies unconscious or adds to existing duration
/mob/living/proc/AdjustUnconscious(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANUNCONSCIOUS) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/unconscious/current_unconscious = has_status_effect(STATUS_EFFECT_UNCONSCIOUS)
	if(current_unconscious)
		current_unconscious.duration += amount
	else if(amount > 0)
		current_unconscious = apply_status_effect(STATUS_EFFECT_UNCONSCIOUS, amount)

	return current_unconscious
