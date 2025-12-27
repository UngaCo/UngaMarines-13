///Returns if stunned
/mob/living/proc/IsStun()
	return has_status_effect(STATUS_EFFECT_STUN)

///Returns remaining stun duration
/mob/living/proc/AmountStun()
	var/datum/status_effect/incapacitating/stun/current_stun = has_status_effect(STATUS_EFFECT_STUN)
	return current_stun ? current_stun.duration - world.time : 0

///Applies stun from current world time unless existing duration is higher
/mob/living/proc/Stun(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stun/current_stun = has_status_effect(STATUS_EFFECT_STUN)
	if(current_stun)
		current_stun.duration = max(world.time + amount, current_stun.duration)
	else if(amount > 0)
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun

///Used to set stun to a set amount, commonly to remove it
/mob/living/proc/SetStun(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/stun/current_stun = has_status_effect(STATUS_EFFECT_STUN)
	if(amount <= 0)
		if(current_stun)
			qdel(current_stun)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_stun)
		current_stun.duration = world.time + amount
	else
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun

///Applies stun or adds to existing duration
/mob/living/proc/AdjustStun(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_STUN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/stun/current_stun = has_status_effect(STATUS_EFFECT_STUN)
	if(current_stun)
		current_stun.duration += amount
	else if(amount > 0)
		current_stun = apply_status_effect(STATUS_EFFECT_STUN, amount)

	return current_stun
