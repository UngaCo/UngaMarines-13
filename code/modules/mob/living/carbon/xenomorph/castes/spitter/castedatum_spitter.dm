/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = ""
	caste_desc = "Gotta dodge!"
	caste_type_path = /mob/living/carbon/xenomorph/spitter
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "spitter" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 50

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	evolution_threshold = 225

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_ACID_BLOOD
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 10, ENERGY = 35, BOMB = 0, BIO = 20, FIRE = 10, ACID = 20)

	// *** Minimap Icon *** //
	minimap_icon = "spitter"

	// *** Ranged Attack *** //
	spit_delay = 0.5 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium/passthrough) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

	acid_spray_duration = 10 SECONDS
	acid_spray_damage_on_hit = 35
	acid_spray_damage = 16
	acid_spray_structure_damage = 45

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/activable/xeno/spray_acid/line,
	)

/datum/xeno_caste/spitter/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/spitter/primordial
	upgrade_name = "Primordial"
	caste_desc = "Master of ranged combat, this xeno knows no equal."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "Our suppression is unmatched! Let nothing show its head!"
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_ACID_BLOOD

	spit_delay = 0.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium/passthrough, /datum/ammo/xeno/acid/auto)

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/activable/xeno/spray_acid/line,
		/datum/action/ability/activable/xeno/toxic_grenade/sticky,
	)

/datum/xeno_caste/spitter/globadier
	caste_type_path = /mob/living/carbon/xenomorph/spitter/globadier
	base_caste_type_path = /mob/living/carbon/xenomorph/spitter
	upgrade_name = ""
	caste_name = "Spitter"
	display_name = "Globadier"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A mutated variant of a spitter. It carries round globs of acid on its back"

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -0.8

	// *** Health *** //
	max_health = 320

	// *** Ablities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/toss_grenade,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/xeno_action/acid_mine/gas_mine,
	)

/datum/xeno_caste/spitter/globadier/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/spitter/globadier/primordial
	upgrade_name = "Primordial"
	caste_desc = "A master of area control, covered in strange globulets."
	primordial_message = "Let no cover guard our enemies."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/toss_grenade,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/xeno_action/acid_mine/gas_mine,
		/datum/action/ability/activable/xeno/acid_rocket,
	)
