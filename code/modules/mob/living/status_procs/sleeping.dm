///Returns if sleeping
/mob/living/proc/IsSleeping()
	return has_status_effect(STATUS_EFFECT_SLEEPING)

///Returns remaining sleeping duration
/mob/living/proc/AmountSleeping()
	var/datum/status_effect/incapacitating/sleeping/current_sleeping = has_status_effect(STATUS_EFFECT_SLEEPING)
	return current_sleeping ? current_sleeping.duration - world.time : 0

///Applies sleeping from current world time unless existing duration is higher
/mob/living/proc/Sleeping(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/sleeping/current_sleeping = has_status_effect(STATUS_EFFECT_SLEEPING)
	if(current_sleeping)
		current_sleeping.duration = max(world.time + amount, current_sleeping.duration)
	else if(amount > 0)
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

///Used to set sleeping to a set amount, commonly to remove it
/mob/living/proc/SetSleeping(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/sleeping/current_sleeping = has_status_effect(STATUS_EFFECT_SLEEPING)
	if(amount <= 0)
		if(current_sleeping)
			qdel(current_sleeping)
		return
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_sleeping)
		current_sleeping.duration = world.time + amount
	else
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

///Applies sleeping or adds to existing duration
/mob/living/proc/AdjustSleeping(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_STUNIMMUNE) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_SLEEP, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/sleeping/current_sleeping = has_status_effect(STATUS_EFFECT_SLEEPING)
	if(current_sleeping)
		current_sleeping.duration += amount
	else if(amount > 0)
		current_sleeping = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)

	return current_sleeping

/mob/living/proc/IsAdminSleeping()
	return has_status_effect(STATUS_EFFECT_ADMINSLEEP)

/mob/living/proc/ToggleAdminSleep()
	var/datum/status_effect/incapacitating/adminsleep/S = IsAdminSleeping()
	if(S)
		qdel(S)
	else
		S = apply_status_effect(STATUS_EFFECT_ADMINSLEEP)
	return S

/mob/living/proc/SetAdminSleep(remove = FALSE)
	var/datum/status_effect/incapacitating/adminsleep/S = IsAdminSleeping()
	if(remove)
		qdel(S)
	else
		S = apply_status_effect(STATUS_EFFECT_ADMINSLEEP)
	return S
