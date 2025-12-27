/// Controls how many quickbuilds each xenomorph gets.
#define QUICKBUILD_STRUCTURES_PER_XENO 600

SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE
	/// A list used to count how many buildings were built by player ckey , counter[ckey] = [build_count]
	var/list/xeno_builds_counter = list()
	/// Counter for quickbuild points, as long as this is above 0 building is instant.
	var/list/quickbuild_points_by_hive = list()
	/// Counter for total structures built
	var/total_structures_built = 0
	/// Counter for total refunds of structures
	var/total_structures_refunded = 0
	/// Whether or not quickbuild is enabled. Set to FALSE when the game starts.
	var/active = TRUE
	/// Track biomass gained from quickbuild per player (max 15)
	var/list/quickbuild_biomass_gained = list()

/datum/controller/subsystem/resinshaping/stat_entry()
	if(SSticker.mode?.round_type_flags & MODE_ALLOW_XENO_QUICKBUILD)
		var/total_quickbuild_biomass = 0
		for(var/player_key in quickbuild_biomass_gained)
			total_quickbuild_biomass += quickbuild_biomass_gained[player_key]
		return "BUILT=[total_structures_built] REFUNDED=[total_structures_refunded] BIOMASS=[total_quickbuild_biomass]"
	return "OFFLINE"

/datum/controller/subsystem/resinshaping/proc/toggle_off()
	SIGNAL_HANDLER
	active = FALSE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED,COMSIG_GLOB_CANTERBURRY_LANDING))

/datum/controller/subsystem/resinshaping/Initialize()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,COMSIG_GLOB_DROPPOD_LANDED,COMSIG_GLOB_CANTERBURRY_LANDING), PROC_REF(toggle_off))
	for(var/hivenumber in GLOB.hive_datums)
		quickbuild_points_by_hive[hivenumber] = SSmapping.configs[GROUND_MAP].quickbuilds
	return SS_INIT_SUCCESS

/// Retrieves a mob's building points using their ckey. Only works for mobs with clients.
/datum/controller/subsystem/resinshaping/proc/get_building_points(mob/living/carbon/xenomorph/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	return QUICKBUILD_STRUCTURES_PER_XENO - xeno_builds_counter[player_key]

/// Increments a mob buildings count , using their ckey.
/datum/controller/subsystem/resinshaping/proc/increment_build_counter(mob/living/carbon/xenomorph/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return

	// Check if we should give biomass (before incrementing counter)
	var/should_give_biomass = active && CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && get_building_points(the_builder) > 0

	xeno_builds_counter[player_key]++
	total_structures_built++

	// Give biomass for quickbuild structures (only while quickbuild is active and had points)
	if(should_give_biomass)
		// Check if player hasn't reached the quickbuild biomass limit (15 max)
		var/current_quickbuild_biomass = quickbuild_biomass_gained[player_key] || 0
		if(current_quickbuild_biomass < 15)
			var/biomass_to_give = min(0.025, 15 - current_quickbuild_biomass)
			the_builder.biomass = min(the_builder.biomass + biomass_to_give, 50)
			quickbuild_biomass_gained[player_key] = current_quickbuild_biomass + biomass_to_give

/// Decrements a mob buildings count , using their ckey.
/datum/controller/subsystem/resinshaping/proc/decrement_build_counter(mob/living/carbon/xenomorph/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	xeno_builds_counter[player_key]--
	total_structures_refunded++
	total_structures_built--

/// Returns a TRUE if a structure should be refunded and instant deconstructed , or false if not
/datum/controller/subsystem/resinshaping/proc/should_refund(atom/structure, mob/living/carbon/xenomorph/the_demolisher)
	var/player_key = "[the_demolisher.client?.ckey]"
	// could be a AI mob thats demolishing without a player key.
	if(!player_key || !active)
		return FALSE
	if(istype(structure, /obj/alien/resin/sticky) && !istype(structure,/obj/alien/resin/sticky/thin))
		return TRUE
	if(istype(structure, /turf/closed/wall/resin))
		return TRUE
	if(istype(structure, /obj/structure/mineral_door/resin))
		return TRUE
	if(istype(structure, /obj/structure/bed/nest))
		return TRUE
	return FALSE

#undef QUICKBUILD_STRUCTURES_PER_XENO

