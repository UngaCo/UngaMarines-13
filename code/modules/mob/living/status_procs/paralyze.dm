///Returns if paralyzed
/mob/living/proc/IsParalyzed()
	return has_status_effect(STATUS_EFFECT_PARALYZED)

///Returns remaining paralyzed duration
/mob/living/proc/AmountParalyzed()
	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = has_status_effect(STATUS_EFFECT_PARALYZED)
	return current_paralyzed ? current_paralyzed.duration - world.time : 0

///Applies paralyze only if not currently applied
/mob/living/proc/ParalyzeNoChain(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if(has_status_effect(STATUS_EFFECT_PARALYZED))
		return 0
	return Paralyze(amount, ignore_canstun)

///Applies paralyze from current world time unless existing duration is higher
/mob/living/proc/Paralyze(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = has_status_effect(STATUS_EFFECT_PARALYZED)
	if(current_paralyzed)
		current_paralyzed.duration = max(world.time + amount, current_paralyzed.duration)
	else if(amount > 0)
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed

/mob/living/carbon/Paralyze(amount, ignore_canstun)
	if(species?.species_flags & PARALYSE_RESISTANT)
		if(amount > MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT * 4)
			amount = MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT
			return ..()
		amount *= 0.25
	return ..()

///Used to set paralyzed to a set amount, commonly to remove it
/mob/living/proc/SetParalyzed(amount, ignore_canstun = FALSE)
	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = has_status_effect(STATUS_EFFECT_PARALYZED)
	if(amount <= 0)
		if(current_paralyzed)
			qdel(current_paralyzed)
		return
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	if(current_paralyzed)
		current_paralyzed.duration = world.time + amount
	else
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed

///Applies paralyzed or adds to existing duration
/mob/living/proc/AdjustParalyzed(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	if((!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)) && !ignore_canstun)
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_PARALYZE, amount, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(absorb_stun(amount, ignore_canstun))
		return

	var/datum/status_effect/incapacitating/paralyzed/current_paralyzed = has_status_effect(STATUS_EFFECT_PARALYZED)
	if(current_paralyzed)
		current_paralyzed.duration += amount
	else if(amount > 0)
		current_paralyzed = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)

	return current_paralyzed
