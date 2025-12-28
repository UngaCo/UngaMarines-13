/datum/xeno_caste/behemoth
	caste_name = "Behemoth"
	display_name = "Behemoth"
	upgrade_name = ""
	caste_desc = "Behemoths are known to like rocks. Perhaps we should give them one!"
	caste_type_path = /mob/living/carbon/xenomorph/behemoth
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "behemoth"

	// *** Melee Attacks *** //
	melee_damage = 26

	// *** Speed *** //
	speed = -0.5
	weeds_speed_mod = -0.2

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 20

	// *** Health *** //
	max_health = 750

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_IS_STRONG|CASTE_STAGGER_RESISTANT
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 20, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 50, BIO = 50, FIRE = 20, ACID = 50)
	hard_armor = list(MELEE = 0, BULLET = 12, LASER = 6, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

	// *** Minimap Icon *** //
	minimap_icon = "behemoth"

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/behemoth_roll,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/seismic_fracture,
	)

/datum/xeno_caste/behemoth/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/behemoth/primordial
	upgrade_name = "Primordial"
	primordial_message = "In the ancient embrace of the earth, we have honed our art to perfection. Our might will crush the feeble pleas of our enemies before they can escape their lips."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Wrath *** //
	wrath_max = 750

	// *** Abilities *** ///
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/mutation_menu,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/ready_charge/behemoth_roll,
		/datum/action/ability/activable/xeno/landslide,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/seismic_fracture,
		/datum/action/ability/xeno_action/primal_wrath,
	)

/datum/xeno_caste/behemoth/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/crusher) // we use the same riding element as crusher
	xenomorph.RegisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK, TYPE_PROC_REF(/mob/living/carbon/xenomorph, grabbed_self_attack))

/datum/xeno_caste/behemoth/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK)
