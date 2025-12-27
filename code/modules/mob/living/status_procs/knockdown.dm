///Returns if knockeddown
/mob/living/proc/IsKnockdown()
	return has_status_effect(STATUS_EFFECT_KNOCKDOWN)

///Returns remaining knockdown duration
/mob/living/proc/AmountKnockdown()
	var/datum/status_effect/incapacitating/knockdown/current_knockdown = has_status_effect(STATUS_EFFECT_KNOCKDOWN)
	return current_knockdown ? current_knockdown.duration - world.time : 0

///Applies knockdown only if not currently applied
/mob/living/proc/KnockdownNoChain(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(has_status_effect(STATUS_EFFECT_KNOCKDOWN))
		return 0
	return Knockdown(amount, ignore_canstun)

///Applies knockdown from current world time unless existing duration is higher
/mob/living/proc/Knockdown(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/knockdown/current_knockdown = has_status_effect(STATUS_EFFECT_KNOCKDOWN)
	if(current_knockdown)
		current_knockdown.duration = max(world.time + amount, current_knockdown.duration)
	else if(amount > 0)
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown

///Used to set knockdown to a set amount, commonly to remove it
/mob/living/proc/SetKnockdown(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/knockdown/current_knockdown = has_status_effect(STATUS_EFFECT_KNOCKDOWN)
	if(amount <= 0)
		if(current_knockdown)
			qdel(current_knockdown)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_knockdown)
		current_knockdown.duration = world.time + amount
	else
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown

///Applies knockdown or adds to existing duration
/mob/living/proc/AdjustKnockdown(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANSTUN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_KNOCKDOWN, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/knockdown/current_knockdown = has_status_effect(STATUS_EFFECT_KNOCKDOWN)
	if(current_knockdown)
		current_knockdown.duration += amount
	else if(amount > 0)
		current_knockdown = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount)

	return current_knockdown
