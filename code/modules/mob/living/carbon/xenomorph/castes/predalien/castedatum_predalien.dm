/datum/xeno_caste/predalien
	caste_name = "Predalien"
	display_name = "Abomination"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/predalien
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "Predalien"

	// *** Melee Attacks *** //
	melee_damage = 60

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 5

	soft_armor = list(MELEE = 60, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 60, FIRE = 30, ACID = 60)

	// *** Health *** //
	max_health = 650

	// *** Minimap Icon *** //
	minimap_icon = "predalien"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/pounce/predalien,
		/datum/action/ability/activable/xeno/predalien_roar,
		/datum/action/ability/activable/xeno/smash,
		/datum/action/ability/activable/xeno/devastate,
	)


/datum/xeno_caste/predalien/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/predalien/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO

