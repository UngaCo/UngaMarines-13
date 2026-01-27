/mob/living/carbon/xenomorph/spitter
	caste_base_type = /datum/xeno_caste/spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/castes/spitter/basic.dmi'
	icon_state = "Spitter Walking"
	effects_icon = 'icons/Xeno/castes/spitter/effects.dmi'
	bubble_icon = "alienroyal"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	pixel_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/spitter/globadier
	caste_base_type = /datum/xeno_caste/spitter/globadier
	icon = 'icons/Xeno/castes/spitter/globadier.dmi'
	skins = null

/mob/living/carbon/xenomorph/spitter/primordial
	upgrade = XENO_UPGRADE_PRIMO

/mob/living/carbon/xenomorph/spitter/globadier
	upgrade = XENO_UPGRADE_NORMAL

/mob/living/carbon/xenomorph/spitter/globadier/primordial
	upgrade = XENO_UPGRADE_PRIMO

/mob/living/carbon/xenomorph/spitter/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/spitter/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/spitter/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/spitter/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/spitter/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/spitter/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN
