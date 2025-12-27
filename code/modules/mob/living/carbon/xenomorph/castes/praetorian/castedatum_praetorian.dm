/datum/xeno_caste/praetorian
	caste_name = "Praetorian"
	display_name = "Praetorian"
	upgrade_name = ""
	caste_desc = "A giant ranged monster. It looks pretty strong."
	caste_type_path = /mob/living/carbon/xenomorph/praetorian
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "praetorian" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 80

	// *** Health *** //
	max_health = 570

	// *** Flags *** //
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_HOLD_JELLY
	caste_traits = null
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_ACID_BLOOD

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 25, LASER = 15, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 20, ACID = 40)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/heavy/passthrough)
	acid_spray_duration = 6 SECONDS
	acid_spray_damage = 8
	acid_spray_duration = 10 SECONDS
	acid_spray_range = 5
	acid_spray_damage = 16
	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Minimap Icon *** //
	minimap_icon = "praetorian"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/scatter_spit/praetorian,
		/datum/action/ability/activable/xeno/spray_acid/line/short,
		/datum/action/ability/activable/xeno/charge/dash,
	)

/datum/xeno_caste/praetorian/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/praetorian/primordial
	upgrade_name = "Primordial"
	caste_desc = "An aberrant creature extremely proficient with acid, keep your distance if you don't wish to be burned."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "The strongest of acids flows through our veins, let's reduce them to dust."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/scatter_spit/praetorian,
		/datum/action/ability/activable/xeno/spray_acid/line/short,
		/datum/action/ability/activable/xeno/spray_acid/cone,
		/datum/action/ability/activable/xeno/charge/dash,
	)

/datum/xeno_caste/praetorian/dancer
	caste_type_path = /mob/living/carbon/xenomorph/praetorian/dancer
	base_caste_type_path = /mob/living/carbon/xenomorph/praetorian
	upgrade_name = ""
	caste_name = "Praetorian"
	display_name = "Dancer"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A giant melee monster. It looks pretty strong."

	// +2 melee damage
	melee_damage = 25

	// Loses some common armor (-5) for more speed (-0.3).
	speed = -0.8
	soft_armor = list(MELEE = 40, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 10, BIO = 40, FIRE = 15, ACID = 40)

	// Loses ranged spit abilities for close combat combo abilities.
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/dodge,
		/datum/action/ability/activable/xeno/impale,
		/datum/action/ability/activable/xeno/tail_hook,
		/datum/action/ability/activable/xeno/tail_trip,
	)

/datum/xeno_caste/praetorian/dancer/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/praetorian/dancer/primordial
	upgrade_name = "Primordial"
	caste_desc = "An aberrant creature extremely proficient with its body and tail. Keep your distance if you don't wish to be finessed."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "With a flick of our tail, we dance through the shadows, striking with lethal precision."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/dodge,
		/datum/action/ability/activable/xeno/impale,
		/datum/action/ability/activable/xeno/tail_hook,
		/datum/action/ability/activable/xeno/tail_trip,
		/datum/action/ability/activable/xeno/charge/acid_dash,
		/datum/action/ability/activable/xeno/baton_pass,
	)
