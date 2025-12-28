/datum/xeno_caste/defender
	caste_name = "Defender"
	display_name = "Defender"
	upgrade_name = ""
	caste_desc = "An alien with an armored crest. It looks very tough."

	caste_type_path = /mob/living/carbon/xenomorph/defender

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "defender" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 410

	// *** Evolution *** //
	evolution_threshold = 100

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 40, BOMB = 20, BIO = 30, FIRE = 10, ACID = 30)
	hard_armor = list(MELEE = 0, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "defender"

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 55

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/activable/xeno/charge/forward_charge,
		/datum/action/ability/xeno_action/tail_sweep,
	)

/datum/xeno_caste/defender/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/defender/steel_crest/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/defender/primordial
	upgrade_name = "Primordial"
	caste_desc = "Alien with an incredibly tough and armored head crest able to endure even the strongest hits."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "We are the aegis of the hive. Let nothing pierce our guard."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/activable/xeno/charge/forward_charge,
		/datum/action/ability/xeno_action/tail_sweep,
		/datum/action/ability/xeno_action/centrifugal_force,
	)

/datum/xeno_caste/defender/steel_crest
	caste_type_path = /mob/living/carbon/xenomorph/defender/steel_crest
	base_caste_type_path = /mob/living/carbon/xenomorph/defender
	upgrade_name = ""
	caste_name = "Defender"
	display_name = "Steel crest"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "An alien with an armored crest. It looks very tough."

	// *** Speed *** //
	speed = -0.4

	// *** Defender Abilities *** //
	crest_defense_armor = 30
	crest_defense_slowdown = 0.8
	fortify_armor = 40

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/fortify/steel_crest,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/activable/xeno/headbutt,
		/datum/action/ability/xeno_action/soak,
	)

/datum/xeno_caste/defender/steel_crest/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "Alien with an incredibly tough and armored head crest able to endure even the strongest hits."
