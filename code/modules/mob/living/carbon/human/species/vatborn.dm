/datum/species/human/vatborn
	name = "Vatborn"
	icobase = 'icons/mob/human_races/r_vatborn.dmi'
	namepool = /datum/namepool/vatborn
	limb_type = SPECIES_LIMB_CLONE

/datum/species/human/vatborn/prefs_name(datum/preferences/prefs)
	return prefs.real_name
