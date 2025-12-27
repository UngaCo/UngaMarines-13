/mob/living/carbon/xenomorph/scorpion
	caste_base_type = /datum/xeno_caste/scorpion
	name = "Scorpion"
	desc = "An eerie, four-legged alien with a hollow tail. A green, jelly-like texture characterizes its eyes and underbelly."
	icon = 'icons/Xeno/castes/scorpion/basic.dmi'
	icon_state = "Scorpion Walking"
	effects_icon = 'icons/Xeno/castes/scorpion/effects.dmi'
	skins = list(
		/datum/xenomorph_skin/scorpion,
		/datum/xenomorph_skin/scorpion/crab,
	)
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2
	life_value = 0
	default_honor_value = 0

/mob/living/carbon/xenomorph/scorpion/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/scorpion/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/scorpion/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/scorpion/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/scorpion/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/scorpion/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN
