/mob/living/carbon/xenomorph/spiderling
	caste_base_type = /datum/xeno_caste/spiderling
	name = "Spiderling"
	desc = "A widow spawn, it chitters angrily without any sense of self-preservation, only to obey the widow's will."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "Spiderling Running"
	health = 90
	maxHealth = 90
	plasma_stored = 200
	mob_size = MOB_SIZE_HUMAN
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2
	allow_pass_flags = PASS_XENO
	pass_flags = PASS_XENO|PASS_LOW_STRUCTURE
	density = FALSE
	/// The widow that this spiderling belongs to
	var/mob/living/carbon/xenomorph/spidermother

/mob/living/carbon/xenomorph/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/mother)
	. = ..()
	spidermother = mother
	if(spidermother)
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, spidermother)
		transfer_to_hive(spidermother.get_xeno_hivenumber())
	else
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/spiderling/on_death()
	//We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, TIME_TO_DISSOLVE)
	spidermother = null
	return ..()

/mob/living/carbon/xenomorph/spiderling/Destroy()
	spidermother = null
	return ..()

///If we're covering our widow, any clicks should be transferred to them
/mob/living/carbon/xenomorph/spiderling/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, isrightclick = FALSE)
	if(!get_dist(src, spidermother) && isxeno(x))
		spidermother.attack_alien(xeno_attacker, damage_amount, damage_type, armor_type, effects, isrightclick)
		return
	return ..()

/mob/living/carbon/xenomorph/spiderling/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!spidermother)
		return
	if(get_dist(src, spidermother) > SPIDERLING_WITHER_RANGE)
		adjust_brute_loss(25)

/mob/living/carbon/xenomorph/spiderling/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/spiderling/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/spiderling/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/spiderling/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/spiderling/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/spiderling/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN
