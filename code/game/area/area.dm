/area
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = AREA_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	minimap_color = null

	/// List of all turfs currently inside this area as nested lists indexed by zlevel.
	/// Acts as a filtered version of area.contents For faster lookup
	/// (area.contents is actually a filtered loop over world)
	/// Semi fragile, but it prevents stupid so I think it's worth it
	var/list/list/turf/turfs_by_zlevel = list() // TODO someone needs to go through and check that this is being used properly when it shoudld be

	/// turfs_by_z_level can hold MASSIVE lists, so rather then adding/removing from it each time we have a problem turf
	/// We should instead store a list of turfs to REMOVE from it, then hook into a getter for it
	/// There is a risk of this and contained_turfs leaking, so a subsystem will run it down to 0 incrementally if it gets too large
	/// This uses the same nested list format as turfs_by_zlevel
	var/list/list/turf/turfs_to_uncontain_by_zlevel = list()

	///Does the area has fire alarm?
	var/fire_alarm = FALSE

	var/unique = TRUE

	var/requires_power = TRUE
	var/always_unpowered = FALSE

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/used_equip = FALSE
	var/used_light = FALSE
	var/used_environ = FALSE

	var/global/global_uid = 0
	var/uid

	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE

	var/temperature = T20C

	var/parallax_movedir = 0

	///the material the ceiling is made of. Used for debris from airstrikes and orbital beacons in ceiling_debris()
	var/ceiling = CEILING_NONE
	///Used in designating the "level" of maps pretending to be multi-z one Z
	var/fake_zlevel
	///Is this area considered inside or outside
	var/outside = TRUE

	var/area_flags = NONE
	///Cameras in this area
	var/list/cameras
	var/list/ambience = list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', \
		'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg', 'sound/ambience/ambigen8.ogg',\
		'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambigen12.ogg',\
		'sound/ambience/ambigen14.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 40 SECONDS
	///Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 120 SECONDS

	///Boolean to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
	var/area_limited_icon_smoothing = FALSE

/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if(unique)
		GLOB.areas_by_type[type] = src
	GLOB.areas += src
	return ..()

/area/Initialize(mapload, ...)
	icon_state = "" //Used to reset the icon overlay, I assume.
	uid = ++global_uid

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

	. = ..()

	if(!static_lighting)
		blend_mode = BLEND_MULTIPLY
	reg_in_areas_in_z()
	update_base_lighting()
	return INITIALIZE_HINT_LATELOAD

/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon

/area/Destroy() // todo this doesnt clean up everything it should
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	//this is not initialized until get_sorted_areas() is called so we have to do a null check
	if(!isnull(GLOB.sorted_areas))
		GLOB.sorted_areas -= src
	//just for sanity sake cause why not
	if(!isnull(GLOB.areas))
		GLOB.areas -= src
	STOP_PROCESSING(SSobj, src)
	//turf cleanup
	turfs_by_zlevel = null
	turfs_to_uncontain_by_zlevel = null
	return ..()

/area/Entered(atom/movable/arrived, atom/old_loc)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_loc)
	SEND_SIGNAL(arrived, COMSIG_ENTER_AREA, src, old_loc,) //The atom that enters the area

/area/Exited(atom/movable/leaver, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, leaver, direction)
	SEND_SIGNAL(leaver, COMSIG_EXIT_AREA, src, direction) //The atom that exits the area

/// Returns the highest zlevel that this area contains turfs for
/area/proc/get_highest_zlevel()
	for(var/area_zlevel in length(turfs_by_zlevel) to 1 step -1)
		if(length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if(length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return area_zlevel
		else
			if(length(turfs_by_zlevel[area_zlevel]))
				return area_zlevel
	return 0

/// Returns a nested list of lists with all turfs split by zlevel.
/// only zlevels with turfs are returned. The order of the list is not guaranteed.
/area/proc/get_zlevel_turf_lists()
	if(length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs()

	var/list/zlevel_turf_lists = list()

	for(var/list/zlevel_turfs as anything in turfs_by_zlevel)
		if(length(zlevel_turfs))
			zlevel_turf_lists += list(zlevel_turfs)

	return zlevel_turf_lists

/// Returns a list with all turfs in this zlevel.
/area/proc/get_turfs_by_zlevel(zlevel)
	if(length(turfs_to_uncontain_by_zlevel) >= zlevel && length(turfs_to_uncontain_by_zlevel[zlevel]))
		cannonize_contained_turfs_by_zlevel(zlevel)

	if(length(turfs_by_zlevel) < zlevel)
		return list()

	return turfs_by_zlevel[zlevel]

/// Merges a list containing all of the turfs zlevel lists from get_zlevel_turf_lists inside one list. Use get_zlevel_turf_lists() or get_turfs_by_zlevel() unless you need all the turfs in one list to avoid generating large lists
/area/proc/get_turfs_from_all_zlevels()
	. = list()
	for (var/list/zlevel_turfs as anything in get_zlevel_turf_lists())
		. += zlevel_turfs

/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs_by_zlevel(zlevel_to_clean, _autoclean = TRUE)
	// This is massively suboptimal for LARGE removal lists
	// Try and keep the mass removal as low as you can. We'll do this by ensuring
	// We only actually add to contained turfs after large changes (Also the management subsystem)
	// Do your damndest to keep turfs out of /area/space as a stepping stone
	// That sucker gets HUGE and will make this take actual seconds
	if(zlevel_to_clean <= length(turfs_by_zlevel) && zlevel_to_clean <= length(turfs_to_uncontain_by_zlevel))
		turfs_by_zlevel[zlevel_to_clean] -= turfs_to_uncontain_by_zlevel[zlevel_to_clean]

	if(!_autoclean) // Removes empty lists from the end of this list
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()
		return

	var/new_length = length(turfs_to_uncontain_by_zlevel)
	// Walk backwards thru the list
	for (var/i in length(turfs_to_uncontain_by_zlevel) to 0 step -1)
		if (i && length(turfs_to_uncontain_by_zlevel[i]))
			break // Stop the moment we find a useful list
		new_length = i

	if (new_length < length(turfs_to_uncontain_by_zlevel))
		turfs_to_uncontain_by_zlevel.len = new_length

	if (new_length >= zlevel_to_clean)
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()

/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs()
	for(var/area_zlevel in 1 to length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs_by_zlevel(area_zlevel, _autoclean = FALSE)

	turfs_to_uncontain_by_zlevel = list()

/// Returns TRUE if we have contained turfs, FALSE otherwise
/area/proc/has_contained_turfs()
	for(var/area_zlevel in 1 to length(turfs_by_zlevel))
		if(length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if(length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return TRUE
		else
			if(length(turfs_by_zlevel[area_zlevel]))
				return TRUE
	return FALSE

/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!has_contained_turfs())
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] |= src

// A hook so areas can modify the incoming args
/area/proc/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags

/area/proc/power_alert(state, obj/source)
	if(state == poweralm)
		return

	poweralm = state

	for(var/obj/machinery/computer/station_alert/alert_computer as anything in GLOB.alert_consoles)
		if(alert_computer.z != source.z)
			continue
		if(state == 1)
			alert_computer.cancelAlarm("Power", src, source)
		else
			alert_computer.triggerAlarm("Power", src, null, source)

/area/proc/fire_alert()
	if(name == "Space") //no fire alarms in space
		return
	if(fire_alarm)
		return
	fire_alarm = TRUE
	var/list/cameras = list() // what does it even do?
	for(var/obj/machinery/computer/station_alert/alert_computer as anything in GLOB.alert_consoles)
		alert_computer.triggerAlarm("Fire", src, cameras, src)
	SEND_SIGNAL(src, COMSIG_AREA_FIRE_ALARM_SET, TRUE)

/area/proc/fire_reset()
	if(!fire_alarm)
		return
	fire_alarm = FALSE

	for(var/obj/machinery/computer/station_alert/alert_computer as anything in GLOB.alert_consoles)
		alert_computer.cancelAlarm("Fire", src, src)
	SEND_SIGNAL(src, COMSIG_AREA_FIRE_ALARM_SET, FALSE)

/area/proc/powered(chan)
	if(!requires_power)
		return TRUE

	if(always_unpowered)
		return FALSE

	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ
	return FALSE

/area/proc/power_change()
	for(var/obj/machinery/M in src)
		M.power_change()
	update_icon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
	return used

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(amount, chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount
