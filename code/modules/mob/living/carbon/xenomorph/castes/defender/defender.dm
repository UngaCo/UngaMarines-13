/mob/living/carbon/xenomorph/defender
	caste_base_type = /datum/xeno_caste/defender
	name = "Defender"
	desc = "An alien with an armored head crest."
	icon = 'icons/Xeno/castes/defender/basic.dmi'
	icon_state = "Defender Walking"
	effects_icon = 'icons/Xeno/castes/defender/effects.dmi'
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pull_speed = -2

	skins = list(
		/datum/xenomorph_skin/defender,
		/datum/xenomorph_skin/defender/rouny,
	)

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/defender/handle_special_state()
	if(fortify)
		icon_state = "[xeno_caste.caste_name] Fortify"
		return TRUE
	if(crest_defense)
		icon_state = "[xeno_caste.caste_name] Crest"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/defender/handle_special_wound_states(severity)
	. = ..()
	if(fortify)
		return "wounded_fortify_[severity]" // we don't have the icons, but still
	if(crest_defense)
		return "wounded_crest_[severity]"

// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/defender/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/throw_parry)

// ***************************************
// *********** Steel crest
// ***************************************

/mob/living/carbon/xenomorph/defender/steel_crest
	icon = 'icons/Xeno/castes/defender/steel_crest.dmi'
	caste_base_type = /datum/xeno_caste/defender/steel_crest

// ***************************************
// *********** Front Armor
// ***************************************

/mob/living/carbon/xenomorph/defender/steel_crest/projectile_hit(atom/movable/projectile/proj, cardinal_move, uncrossing)
	if(SEND_SIGNAL(src, COMSIG_XENO_PROJECTILE_HIT, proj, cardinal_move, uncrossing) & COMPONENT_PROJECTILE_DODGE)
		return FALSE
	if(proj.ammo.ammo_behavior_flags & AMMO_SKIPS_ALIENS)
		return FALSE
	if((cardinal_move & REVERSE_DIR(dir)))
		proj.damage -= proj.damage * (0.2 * get_sunder())
	return ..()

/mob/living/carbon/xenomorph/defender/primordial
	upgrade = XENO_UPGRADE_PRIMO

/mob/living/carbon/xenomorph/defender/steel_crest/primordial
	upgrade = XENO_UPGRADE_PRIMO

/mob/living/carbon/xenomorph/defender/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/defender/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/defender/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/defender/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/defender/admeme
	hivenumber = XENO_HIVE_ADMEME

/mob/living/carbon/xenomorph/defender/Corrupted/fallen
	hivenumber = XENO_HIVE_FALLEN
