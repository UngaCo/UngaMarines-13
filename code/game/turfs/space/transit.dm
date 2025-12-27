/turf/open/space/transit
	name = "\proper hyperspace"
	icon_state = "black"
	dir = SOUTH
	baseturfs = /turf/open/space/transit
	explosion_block = INFINITY
	///The number of icon state available
	var/available_icon_state_amounts = 15

/turf/open/space/transit/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, GLOBAL_PROC_REF(dump_in_space))

/turf/open/space/transit/Destroy()
	//Signals are NOT removed from turfs upon replacement, and we get replaced ALOT, so unregister our signal
	UnregisterSignal(src, COMSIG_ATOM_ENTERED)
	return ..()

/turf/open/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if(plane != FLOOR_PLANE) // snowflake behaviour e.g clouds
		underlay_appearance.icon_state = "speedspace_ns_[get_transit_state(asking_turf)]"
		underlay_appearance.transform = turn(matrix(), get_transit_angle(asking_turf))

/turf/open/space/transit/atmos
	name = "\proper high atmosphere"
	baseturfs = /turf/open/space/transit/atmos
	available_icon_state_amounts = 8
	plane = FLOOR_PLANE

//Overwrite because we dont want people building rods in space.
/turf/open/space/transit/attackby(obj/item/I, mob/user, params)
	return

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/proc/dump_in_space(datum/source, atom/movable/crosser, oldloc, oldlocs)
	if(isspaceturf(oldloc))
		return
	if(!isobj(crosser) && !isliving(crosser))
		return
	if(isxenohivemind(crosser))
		return

	var/throw_direction = pick(GLOB.alldirs)
	if(crosser.dir == REVERSE_DIR(throw_direction)) // if mobs step in the reversed from transit turf direction, they will otherwise get smacked 2 times in a row.
		throw_direction = crosser.dir
	var/turf/projected = get_ranged_target_turf(crosser.loc, throw_direction, 10)
	INVOKE_ASYNC(crosser, TYPE_PROC_REF(/atom/movable, throw_at), projected, 5, 2, null, TRUE, TRUE, TRUE)
	addtimer(CALLBACK(crosser, GLOBAL_PROC_REF(handle_crosser), crosser), 0.5 SECONDS, TIMER_UNIQUE)

/proc/handle_crosser(atom/movable/crosser)
	//find a random spot to drop them
	var/list/area/potential_areas = shuffle(SSmapping.areas_in_z["[SSmapping.levels_by_trait(ZTRAIT_GROUND)[1]]"])
	for(var/area/potential_area as anything in potential_areas)
		if(potential_area.area_flags & NO_DROPPOD || !potential_area.outside) // no dropping inside the caves and etc.
			continue
		if(isspacearea(potential_area)) // make sure its not space, just in case
			continue

		var/turf/open/possible_turf
		var/list/area_turfs = get_area_turfs(potential_area)
		for(var/i in 1 to 10)
			possible_turf = pick_n_take(area_turfs)
			// we're looking for an open, non-dense, and non-space turf.
			if(!istype(possible_turf) || is_blocked_turf(possible_turf) || isspaceturf(possible_turf))
				continue

		if(!istype(possible_turf) || is_blocked_turf(possible_turf) || isspaceturf(possible_turf))
			continue // couldn't find one in 10 loops, check another area

		// we found a good turf, lets drop em
		INVOKE_ASYNC(crosser, TYPE_PROC_REF(/atom/movable, handle_airdrop), possible_turf)
		return
	stack_trace("[crosser] has failed to find potential_area for dropping from space and was qdeleted.")
	return qdel(crosser)

/atom/movable/proc/handle_airdrop(turf/target_turf)
	pixel_z = 360
	forceMove(target_turf)
	if(isliving(src))
		var/mob/living/mob = src
		mob.Knockdown(0.6 SECONDS) // so the falling mobs are horizontal for the animation
	animation_spin(0.5 SECONDS, 1, dir == WEST ? FALSE : TRUE)
	animate(src, 0.6 SECONDS, pixel_z = 0, flags = ANIMATION_PARALLEL)
	target_turf.ceiling_debris(2 SECONDS)
	sleep(0.6 SECONDS) // so we do stuff like dealing damage and deconstructing only after the animation end

/obj/handle_airdrop(turf/target)
	. = ..()
	if(!CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) && prob(30)) // throwing objects from the air is not always a good idea
		visible_message(span_danger("[src] falls out of the sky and mangles into the uselessness by the impact!"))
		playsound(src, 'sound/effects/metal_crash.ogg', 35, 1)
		deconstruct(FALSE)

/obj/vehicle/sealed/armored/multitile/handle_airdrop(turf/target)
	. = ..()
	ex_act(2000) //Destroy it
	cell_explosion(target, 300, 100)
	flame_radius(6, target)

/obj/structure/closet/handle_airdrop(turf/target_turf) // good idea but no
	if(!opened)
		for(var/atom/movable/content in src)
			INVOKE_ASYNC(content, TYPE_PROC_REF(/atom/movable, handle_airdrop), get_step(target_turf, rand(1, 8)))
		break_open()
	return ..()

/obj/item/handle_airdrop(turf/target_turf)
	. = ..()
	if(QDELETED(src))
		return
	if(!CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE) && w_class < WEIGHT_CLASS_NORMAL) //tiny and small items will be lost, good riddance
		visible_message(span_danger("[src] falls out of the sky and mangles into the uselessness by the impact!"))
		playsound(src, 'sound/effects/metal_crash.ogg', 35, 1)
		deconstruct(FALSE)
		return
	explosion_throw(200) // give it a bit of a kick
	playsound(loc, 'sound/weapons/smash.ogg', 35, 1)

/mob/living/handle_airdrop(turf/target_turf)
	. = ..()
	remove_status_effect(/datum/status_effect/spacefreeze)

	var/drop_sound = pick('sound/effects/bang.ogg', 'sound/effects/meteorimpact.ogg')
	var/mob/living/carbon/human/human = src
	if(prob(1) || human?.species?.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS) && prob(25))
		drop_sound = 'sound/effects/lead_pipe_drop.ogg'

	playsound(target_turf, drop_sound, 75, TRUE)
	playsound(target_turf, SFX_BONE_BREAK, 75, TRUE)

	Knockdown(10 SECONDS)
	Stun(3 SECONDS)
	take_overall_damage(300, BRUTE, BOMB, updating_health = TRUE)
	take_overall_damage(300, BRUTE, MELEE, updating_health = TRUE)
	spawn_gibs()
	visible_message(span_warning("[src] falls out of the sky."), span_userdanger("As you fall out of the sky, you plummet towards the ground."))

/mob/living/carbon/human/handle_airdrop(turf/target_turf)
	. = ..()
	if(istype(wear_suit, /obj/item/clothing/suit/storage/marine/boomvest))
		var/obj/item/clothing/suit/storage/marine/boomvest/vest = wear_suit
		vest.boom(src)

/turf/open/space/transit/update_icon()
	. = ..()
	transform = turn(matrix(), get_transit_angle(src))

/turf/open/space/transit/update_icon_state()
	. = ..()
	icon_state = "speedspace_ns_[get_transit_state(src, available_icon_state_amounts)]"

/turf/open/space/transit/atmos/update_icon_state()
	. = ..()
	icon_state = "Cloud_[get_transit_state(src, available_icon_state_amounts)]"

/proc/get_transit_state(turf/T, available_icon_state_amounts)
	var/p = round(available_icon_state_amounts * 0.5)
	. = 1
	switch(T.dir)
		if(NORTH)
			. = ((-p*T.x+T.y) % available_icon_state_amounts) + 1
			if(. < 1)
				. += available_icon_state_amounts
		if(EAST)
			. = ((T.x+p*T.y) % available_icon_state_amounts) + 1
		if(WEST)
			. = ((T.x-p*T.y) % available_icon_state_amounts) + 1
			if(. < 1)
				. += available_icon_state_amounts
		else
			. = ((p*T.x+T.y) % available_icon_state_amounts) + 1

/proc/get_transit_angle(turf/T)
	. = 0
	switch(T.dir)
		if(NORTH)
			. = 180
		if(EAST)
			. = 90
		if(WEST)
			. = -90
