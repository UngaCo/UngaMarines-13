/datum/xeno_caste/chimera
	caste_name = "Chimera"
	display_name = "Chimera"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/chimera
	caste_desc = "A slim, deadly alien creature. It has two additional arms with mantis blades."
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "chimera" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25
	attack_delay = 7

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 25

	// *** Health *** //
	max_health = 400

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 50, FIRE = 0, ACID = 50)

	blink_drag_nonfriendly_living_multiplier = 20
	blink_drag_friendly_multiplier = 4
	blink_range = 5

	minimap_icon = "chimera"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
		/datum/action/ability/activable/xeno/pounce/abduction,
		/datum/action/ability/activable/xeno/body_swap,
		/datum/action/ability/xeno_action/warp_blast,
		/datum/action/ability/xeno_action/crippling_strike,
	)

/datum/xeno_caste/chimera/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/chimera/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/blink,
		/datum/action/ability/xeno_action/phantom,
		/datum/action/ability/activable/xeno/pounce/abduction,
		/datum/action/ability/activable/xeno/body_swap,
		/datum/action/ability/xeno_action/warp_blast,
		/datum/action/ability/xeno_action/crippling_strike,
	)

/datum/xeno_caste/chimera/phantom
	caste_type_path = /mob/living/carbon/xenomorph/chimera/phantom
	caste_flags = CASTE_DO_NOT_ALERT_LOW_LIFE|CASTE_IS_A_MINION|CASTE_DO_NOT_ANNOUNCE_DEATH|CASTE_EXCLUDE_STRAINS
	can_flags = CASTE_CAN_BE_QUEEN_HEALED
	caste_traits = null

	melee_damage = 20

	minimap_icon = "xenominion"

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE

	max_health = 200

	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	actions = null
