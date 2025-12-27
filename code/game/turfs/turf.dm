/*
/turf

	/open - all turfs with density = FALSE are turf/open

		/floor - floors are constructed floor as opposed to natural grounds

		/space

		/shuttle - shuttle floors are separated from real floors because they're magic

		/snow - snow is one type of non-floor open turf

	/closed - all turfs with density = TRUE are turf/closed

		/wall - walls are constructed walls as opposed to natural solid turfs

			/r_wall

		/shuttle - shuttle walls are separated from real walls because they're magic, and don't smoothes with walls.

		/ice_rock - ice_rock is one type of non-wall closed turf
*/

/turf
	icon = 'icons/turf/floors.dmi'
	luminosity = TRUE
	var/intact_tile = 1 //used by floors to distinguish floor with/without a floortile(e.g. plating).
	var/can_bloody = TRUE //Can blood spawn on this turf?
	// baseturfs can be either a list or a single turf type.
	// In class definition like here it should always be a single type.
	// A list will be created in initialization that figures out the baseturf's baseturf etc.
	// In the case of a list it is sorted from bottom layer to top.
	// This shouldn't be modified directly, use the helper procs.
	var/list/baseturfs = /turf/baseturf_bottom
	var/changing_turf = FALSE
	/// %-reduction-based armor.
	var/datum/armor/soft_armor
	/// Flat-damage-reduction-based armor.
	var/datum/armor/hard_armor
	///Lumcount added by sources other than lighting datum objects, such as the overlay lighting component.
	var/dynamic_lumcount = 0
	///List of light sources affecting this turf.
	///Which directions does this turf block the vision of, taking into account both the turf's opacity and the movable opacity_sources.
	var/directional_opacity = NONE
	///Lazylist of movable atoms providing opacity sources.
	var/list/atom/movable/opacity_sources
	///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
	var/list/fixed_underlay = null
	var/list/datum/automata_cell/autocells
	///what /mob/oranges_ear instance is already assigned to us as there should only ever be one.
	///used for guaranteeing there is only one oranges_ear per turf when assigned, speeds up view() iteration
	var/mob/oranges_ear/assigned_oranges_ear
	/// The flags we give our turf
	var/turf_flags = NONE

/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE) // anti laggies
	if(atom_flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	ENABLE_BITFIELD(atom_flags, INITIALIZED)

	/// We do NOT use the shortcut here, because this is faster
	if(SSmapping.max_plane_offset)
		if(!SSmapping.plane_offset_blacklist["[plane]"])
			plane = plane - (PLANE_RANGE * SSmapping.z_level_to_plane_offset[z])

		var/turf/T = GET_TURF_ABOVE(src)
		if(T)
			T.multiz_turf_new(src, DOWN)
		T = GET_TURF_BELOW(src)
		if(T)
			T.multiz_turf_new(src, UP)

	// by default, vis_contents is inherited from the turf that was here before.
	// Checking length(vis_contents) in a proc this hot has huge wins for performance.
	if(length(vis_contents))
		vis_contents.Cut()

	assemble_baseturfs()
	levelupdate()
	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

	if(light_power && light_range)
		update_light()

	if(opacity)
		directional_opacity = ALL_CARDINALS

	if(islist(soft_armor))
		soft_armor = getArmor(arglist(soft_armor))
	else if (!soft_armor)
		soft_armor = getArmor()
	else if (!istype(soft_armor, /datum/armor))
		stack_trace("Invalid type [soft_armor.type] found in .soft_armor during /turf Initialize()")

	if(islist(hard_armor))
		hard_armor = getArmor(arglist(hard_armor))
	else if (!hard_armor)
		hard_armor = getArmor()
	else if (!istype(hard_armor, /datum/armor))
		stack_trace("Invalid type [hard_armor.type] found in .hard_armor during /turf Initialize()")

	if (length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if (length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

	return INITIALIZE_HINT_NORMAL

/turf/Destroy(force)
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	if(force)
		. = ..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		for(var/I in B.vars)
			B.vars[I] = null
		return QDEL_HINT_IWILLGC
	visibilityChanged()
	DISABLE_BITFIELD(atom_flags, INITIALIZED)
	soft_armor = null
	hard_armor = null
	. = ..()
	return QDEL_HINT_IWILLGC

/// WARNING WARNING
/// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
/// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
/// We do it because moving signals over was needlessly expensive, and bloated a very commonly used bit of code
/turf/clear_signal_refs()
	return

/turf/Enter(atom/movable/mover, direction)
	// Do not call ..()
	// Byond's default turf/Enter() doesn't have the behaviour we want with Bump()
	// By default byond will call Bump() on the first dense object in contents
	//Then, check the turf itself
	if(!CanPass(mover, src))
		switch(SEND_SIGNAL(mover, COMSIG_MOVABLE_PREBUMP_TURF, src))
			if(COMPONENT_MOVABLE_PREBUMP_STOPPED)
				return FALSE //No need for a bump, already procesed.
			if(COMPONENT_MOVABLE_PREBUMP_PLOWED)
				EMPTY_BLOCK_GUARD
			else
				mover.Bump(src)
				return FALSE
	var/atom/firstbump
	for(var/i in contents)
		if(QDELETED(mover))
			return FALSE //We were deleted, do not attempt to proceed with movement.
		if(i == mover || i == mover.loc) // Multi tile objects and moving out of other objects
			continue
		var/atom/movable/thing = i
		if(CHECK_MULTIPLE_BITFIELDS(thing.pass_flags, HOVERING))
			continue
		if(thing.status_flags & INCORPOREAL)
			continue
		if(thing.Cross(mover))
			continue
		var/signalreturn = SEND_SIGNAL(mover, COMSIG_MOVABLE_PREBUMP_MOVABLE, thing)
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_STOPPED)
			return FALSE //Stopped, bump no longer necessary.
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_PLOWED)
			continue //We've plowed through.
		if(signalreturn & COMPONENT_MOVABLE_PREBUMP_ENTANGLED)
			return TRUE //We've entered the tile and gotten entangled inside it.
		if(QDELETED(mover)) //Mover deleted from Cross/CanPass, do not proceed.
			return FALSE
		else if(!firstbump || ((thing.layer > firstbump.layer || thing.atom_flags & ON_BORDER) && !(firstbump.atom_flags & ON_BORDER)))
			firstbump = thing
	if(QDELETED(mover)) //Mover deleted from Cross/CanPass/Bump, do not proceed.
		return FALSE
	if(firstbump)
		return mover.Bump(firstbump)
	return TRUE

/turf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(ismob(arrived))
		var/mob/M = arrived
		if(!M.lastarea)
			M.lastarea = get_area(M.loc)

		if(!isspaceturf(src))
			M.inertia_dir = 0
	for(var/datum/automata_cell/explosion/our_explosion as anything in autocells) //Let explosions know that the atom entered
		if(!istype(arrived))
			break
		our_explosion.on_turf_entered(arrived)
	return ..()

/turf/proc/get_cell(type)
	for(var/datum/automata_cell/our_cell as anything in autocells)
		if(!istype(our_cell, type))
			continue
		return our_cell
	return null

/turf/ex_act()
	return

/turf/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, VAPOR, S.fraction)

/turf/get_soft_armor(armor_type, proj_def_zone)
	return soft_armor.getRating(armor_type)

/turf/get_hard_armor(armor_type, proj_def_zone)
	return hard_armor.getRating(armor_type)

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.atom_flags & INITIALIZED)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, intact_tile)

// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/change_turf(path, list/new_baseturfs, flags)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
			if(!ispath(path))
				path = text2path(path)
				if(!ispath(path))
					warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/open/space
		if(/turf/open/space/basic)
			// basic doesn't initialize and this will cause issues
			// no warning though because this can happen naturaly as a result of it being built on top of
			path = /turf/open/space

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP) && (baseturfs == new_baseturfs)) // Don't no-op if the map loader requires it to be reconstructed
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	//static lighting
	var/old_lighting_object = static_lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	//hybrid lighting
	var/list/old_hybrid_lights_affecting = hybrid_lights_affecting?.Copy()
	var/old_directional_opacity = directional_opacity
	var/list/old_baseturfs = baseturfs

	var/list/post_change_callbacks = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, post_change_callbacks)

	changing_turf = TRUE
	qdel(src)	//Just get the side effects and call Destroy
	//We do this here so anything that doesn't want to persist can clear itself
	var/list/old__listen_lookup = _listen_lookup?.Copy()
	var/list/old_signal_procs = _signal_procs?.Copy()
	var/turf/W = new path(src)

	// WARNING WARNING
	// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
	// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
	if(old__listen_lookup)
		LAZYOR(W._listen_lookup, old__listen_lookup)
	if(old_signal_procs)
		LAZYOR(W._signal_procs, old_signal_procs)

	for(var/datum/callback/callback AS in post_change_callbacks)
		callback.InvokeAsync(W)

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.hybrid_lights_affecting = old_hybrid_lights_affecting
	W.dynamic_lumcount = dynamic_lumcount

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	var/area/thisarea = get_area(W)
	//static Update
	if(SSlighting.initialized)
		recalculate_directional_opacity()

		if(thisarea.static_lighting)
			W.static_lighting_object = old_lighting_object || new /datum/static_lighting_object(src)
		else
			W.static_lighting_object = null
			if(old_lighting_object)
				qdel(old_lighting_object, TRUE)

		if(static_lighting_object && !static_lighting_object.needs_update)
			static_lighting_object.update()

	//Since the old turf was removed from hybrid_lights_affecting, readd the new turf here
	if(W.hybrid_lights_affecting)
		for(var/atom/movable/lighting_mask/mask AS in W.hybrid_lights_affecting)
			LAZYADD(mask.affecting_turfs, W)

	if(W.directional_opacity != old_directional_opacity)
		W.reconsider_lights()

	// We will only run this logic if the tile is not on the prime z layer, since we use area overlays to cover that
	if(SSmapping.z_level_to_plane_offset[z])
		var/area/our_area = W.loc
		if(our_area.lighting_effects)
			W.add_overlay(our_area.lighting_effects[SSmapping.z_level_to_plane_offset[z] + 1])

	if(!W.smoothing_behavior == NO_SMOOTHING)
		return W
	for(var/dirn in GLOB.alldirs)
		var/turf/D = get_step(W, dirn)
		if(isnull(D))
			continue
		QUEUE_SMOOTH(D)
		QUEUE_SMOOTH_NEIGHBORS(D)
	return W

/turf/proc/empty(turf_type = /turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except  landmarks, docking ports, ai nodes
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /obj/effect/ai_node))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to length(allowed_contents))
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		change_turf(turf_type, baseturf_type, flags)
		//var/turf/newT = change_turf(turf_type, baseturf_type, flags)

/turf/proc/ReplaceWithLattice()
	src.change_turf(/turf/open/space)
	new /obj/structure/lattice( locate(src.x, src.y, src.z) )

/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/AdjacentTurfsSpace()
	var/list/L = list()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L

/turf/proc/multiz_turf_del(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_DEL, T, dir)

/turf/proc/multiz_turf_new(turf/T, dir)
	SEND_SIGNAL(src, COMSIG_TURF_MULTIZ_NEW, T, dir)

/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		return cost
	else
		return get_dist(src,t)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return FALSE
	return abs(x - T.x) + abs(y - T.y)

//Blood stuff------------
/turf/proc/AddTracks(typepath,bloodDNA,comingdir,goingdir,bloodcolor)
	if(!can_bloody)
		return
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

//Cables laying helpers
/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact_tile

/turf/proc/burn_tile()
	return

/turf/proc/ceiling_debris_check(size = 1)
	return

/turf/proc/ceiling_debris(size = 1) //debris falling in response to airstrikes, etc
	var/area/A = get_area(src)
	if(!A.ceiling) return
	var/spread = round(sqrt(size) * 1.5)

	var/list/turfs = list()
	for(var/turf/open/floor/F in range(src, spread))
		turfs += F

	var/drop_message
	var/list/debris_list
	switch(A.ceiling)
		if(CEILING_NONE)
			return
		if(CEILING_GLASS)
			playsound(src, 'sound/effects/glassbr1.ogg', 60, 1)
			drop_message = "Shards of glass rain down from above!"
			debris_list = list(/obj/item/shard, /obj/item/shard)
		if(CEILING_METAL, CEILING_OBSTRUCTED)
			playsound(src, 'sound/effects/metal_crash.ogg', 30, 1)
			drop_message = "Pieces of metal crash down from above!"
			debris_list = list(/obj/item/stack/sheet/metal)
		if(CEILING_UNDERGROUND, CEILING_DEEP_UNDERGROUND)
			playsound(src, 'sound/effects/meteorimpact.ogg', 60, 1)
			drop_message = "Chunks of rock crash down from above!"
			debris_list = list(/obj/item/ore, /obj/item/ore)
		if(CEILING_UNDERGROUND_METAL, CEILING_DEEP_UNDERGROUND_METAL)
			playsound(src, 'sound/effects/metal_crash.ogg', 60, 1)
			debris_list = list(/obj/item/stack/sheet/metal, /obj/item/ore)
	addtimer(CALLBACK(src, PROC_REF(drop_ceiling_debris), debris_list, size, drop_message, turfs), 0.8 SECONDS)

/// Drop amount of listed stuff in listed turfs, with a message if amount is more than 1
/turf/proc/drop_ceiling_debris(list/stuff_to_drop, amount, drop_message, list/turfs)
	if(amount > 1 && drop_message)
		visible_message(span_boldnotice(drop_message))
	for(var/i = 1, i <= amount, i++)
		for(var/item_to_drop AS in stuff_to_drop)
			new item_to_drop(pick(turfs))

/turf/proc/ceiling_desc()
	var/area/A = get_area(src)
	switch(A.ceiling)
		if(CEILING_NONE)
			return "It is in the open."
		if(CEILING_GLASS)
			return "The ceiling above is glass."
		if(CEILING_METAL)
			return "The ceiling above is metal."
		if(CEILING_OBSTRUCTED)
			return "The ceiling above is metal. Nothing could land here."
		if(CEILING_UNDERGROUND)
			return "It is underground. The cavern roof lies above."
		if(CEILING_UNDERGROUND_METAL)
			return "It is underground. The ceiling above is metal."
		if(CEILING_DEEP_UNDERGROUND)
			return "It is deep underground. The cavern roof lies above."
		if(CEILING_DEEP_UNDERGROUND_METAL)
			return "It is deep underground. The ceiling above is metal."

/turf/proc/wet_floor()
	return

//////////////////////////////////////////////////////////

//Check if you can plant weeds on that turf.
//Does NOT return a message, just a 0 or 1.
/turf/proc/is_weedable()
	return !density

/turf/closed/wall/is_weedable()
	return TRUE

/turf/closed/wall/resin/is_weedable()
	return TRUE

/turf/open/space/is_weedable()
	return FALSE

/turf/open/ground/grass/is_weedable()
	return TRUE

/turf/open/floor/plating/ground/dirtgrassborder/is_weedable()
	return TRUE

/turf/open/ground/coast/is_weedable()
	return FALSE

/**
 * Checks for whether we can build advanced xeno structures here
 * Returns TRUE if present, FALSE otherwise
 */
/turf/proc/check_disallow_alien_fortification(mob/living/builder, silent = FALSE)
	var/area/ourarea = loc
	if(ourarea.area_flags & DISALLOW_WEEDING)
		if(!silent)
			to_chat(builder, span_warning("We cannot build in this area before the talls are out!"))
		return FALSE
	return TRUE

/**
 * Check if alien abilities can construct structure on the turf
 * Return TRUE if allowed, FALSE otherwise
 */
/turf/proc/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	var/has_obstacle
	for(var/obj/O in contents)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			var/obj/item/clothing/mask/facehugger/hugger_check = O
			if(hugger_check.stat != DEAD) //We don't care about dead huggers.
				if(!silent)
					to_chat(builder, span_warning("There is a little one here already. Best move it."))
				return FALSE
		if(istype(O, /obj/alien/egg))
			if(!silent)
				to_chat(builder, span_warning("There's already an egg here."))
			return FALSE
		if(istype(O, /obj/structure/xeno))
			if(!silent)
				to_chat(builder, span_warning("There's already a resin structure here!"))
			return FALSE
		if(istype(O, /obj/structure/xeno/plant))
			if(!silent)
				to_chat(builder, span_warning("There is a plant growing here, destroying it would be a waste to the hive."))
			return FALSE
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/structure/ladder) || istype(O, /obj/alien/resin))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/bed))
			if(istype(O, /obj/structure/bed/chair/dropship/passenger))
				var/obj/structure/bed/chair/dropship/passenger/P = O
				if(P.chair_state != DROPSHIP_CHAIR_BROKEN)
					has_obstacle = TRUE
					break
			if(istype(O, /obj/structure/bed/chair/dropship/doublewide))
				has_obstacle = TRUE
				break
			else if(istype(O, /obj/structure/bed/nest)) //We don't care about other beds/chairs/whatever the fuck.
				has_obstacle = TRUE
				break
		if(istype(O, /obj/structure/xeno/hivemindcore))
			has_obstacle = TRUE
			break

		if(istype(O, /obj/structure/cocoon))
			has_obstacle = TRUE
			break

		if(O.density && !(O.atom_flags & ON_BORDER))
			has_obstacle = TRUE
			break

	if(density || has_obstacle)
		if(!silent)
			to_chat(builder, span_warning("There's something built here already."))
		return FALSE
	return TRUE

/turf/closed/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	if(!silent)
		to_chat(builder, span_warning("There's something built here already."))
	return FALSE

/turf/proc/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/can_dig_xeno_tunnel()
	return TRUE

/turf/open/liquid/water/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/plating/ground/snow/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/plating/ground/ice/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/can_dig_xeno_tunnel()
	return TRUE

/turf/open/floor/mainship/research/containment/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/can_dig_xeno_tunnel()
	return TRUE

/turf/open/ground/jungle/impenetrable/can_dig_xeno_tunnel()
	return FALSE

/turf/open/ground/jungle/water/can_dig_xeno_tunnel()
	return FALSE

/turf/open/floor/prison/can_dig_xeno_tunnel()
	return TRUE

/turf/open/lavaland/basalt/can_dig_xeno_tunnel()
	return TRUE

//what dirt type you can dig from this turf if any.
/turf/proc/get_dirt_type()
	return NO_DIRT

/turf/open/ground/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/open/floor/plating/ground/get_dirt_type()
	return DIRT_TYPE_GROUND

/turf/open/floor/plating/ground/mars/get_dirt_type()
	return DIRT_TYPE_MARS

/turf/open/floor/plating/ground/snow/get_dirt_type()
	return DIRT_TYPE_SNOW

/turf/open/lavaland/basalt/get_dirt_type()
	return DIRT_TYPE_LAVALAND

/turf/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!target)
		return FALSE

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		T.change_turf(type)
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T

//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in change_turf()
	levelupdate()
	//CalculateAdjacentTurfs() // linda

	//update firedoor adjacency
//	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
//	for(var/I in turfs_to_check)
//		var/turf/T = I
//		for(var/obj/machinery/door/firedoor/FD in T)
//			FD.CalculateAffectingAreas()

//	queue_smooth_neighbors(src)

	HandleTurfChange(src)

/turf/open/AfterChange(flags)
	. = ..()
	RemoveLattice()

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && (L.atom_flags & INITIALIZED))
		qdel(L)

/// A proc in case it needs to be recreated or badmins want to change the baseturfs
/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	var/static/list/created_baseturf_lists = list()
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type)) // We were given a list, just apply it and move on
			baseturfs = fake_baseturf_type
			return
		current_target = fake_baseturf_type
	else
		if(length(baseturfs))
			return // No replacement baseturf has been given and the current baseturfs value is already a list/assembled
		if(!baseturfs)
			current_target = initial(baseturfs) || type // This should never happen but just in case...
			stack_trace("baseturfs var was null for [type]. Failsafe activated and it has been given a new baseturfs value of [current_target].")
		else
			current_target = baseturfs

	// If we've made the output before we don't need to regenerate it
	if(created_baseturf_lists[current_target])
		var/list/premade_baseturfs = created_baseturf_lists[current_target]
		if(length(premade_baseturfs))
			baseturfs = premade_baseturfs.Copy()
		else
			baseturfs = premade_baseturfs
		return baseturfs

	var/turf/next_target = initial(current_target.baseturfs)
	//Most things only have 1 baseturf so this loop won't run in most cases
	if(current_target == next_target)
		baseturfs = current_target
		created_baseturf_lists[current_target] = current_target
		return current_target
	var/list/new_baseturfs = list(current_target)
	for(var/i=0;current_target != next_target;i++)
		if(i > 100)
			// A baseturfs list over 100 members long is silly
			// Because of how this is all structured it will only runtime/message once per type
			stack_trace("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			message_admins("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			break
		new_baseturfs.Insert(1, next_target)
		current_target = next_target
		next_target = initial(current_target.baseturfs)

	baseturfs = new_baseturfs
	created_baseturf_lists[new_baseturfs[length(new_baseturfs)]] = new_baseturfs.Copy()
	return new_baseturfs

/turf/baseturf_bottom
	name = "Z-level baseturf placeholder"
	desc = "Marker for z-level baseturf, usually resolves to space."
	baseturfs = /turf/baseturf_bottom

/turf/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0)
	var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)

	// Make toxins vomit look different
	if(toxvomit)
		this.icon_state = "vomittox_[pick(1,4)]"

/turf/proc/visibilityChanged()
	for(var/datum/cameranet/net AS in list(GLOB.cameranet, GLOB.som_cameranet))
		net.updateVisibility(src)

/turf/AllowDrop()
	return TRUE

/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	return ..()

/turf/balloon_alert_perform(mob/viewer, text)
	// Balloon alerts occuring on turf objects result in mass spam of alerts.
	// Thus, no more balloon alerts for turfs.
	return

///cleans any cleanable decals from the turf
/turf/wash()
	. = ..()
	for(var/obj/effect/decal/cleanable/filth in src)
		qdel(filth) //dirty, filthy floor

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

///Are we able to teleport to this turf using in game teleport mechanics
/turf/proc/can_teleport_here()
	if(density)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_TURF_TELEPORT_CHECK))
		return FALSE
	return TRUE

///Returns the number that represents how submerged an AM is by a turf and its contents
/turf/proc/get_submerge_height(turf_only = FALSE)
	. = 0
	if(turf_only)
		return
	var/list/submerge_list = list()
	SEND_SIGNAL(src, COMSIG_TURF_SUBMERGE_CHECK, submerge_list)
	for(var/i in submerge_list)
		. += i

///Returns the number that shows how far an AM is offset when submerged in this turf
/turf/proc/get_submerge_depth()
	return 0
