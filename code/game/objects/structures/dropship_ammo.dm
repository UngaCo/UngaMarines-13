/obj/structure/ship_ammo
	icon = 'icons/obj/structures/mainship_props.dmi'
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	coverage = 20
	interaction_flags = INTERACT_OBJ_DEFAULT|INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR
	///Time before the ammo impacts
	var/travelling_time = 10 SECONDS
	///type of equipment that accept this type of ammo.
	var/equipment_type
	var/ammo_count
	var/max_ammo_count
	var/ammo_name = "rounds" //what to call the ammo in the ammo transfering message
	var/ammo_id
	///whether the ammo inside this magazine can be transfered to another magazine.
	var/transferable_ammo = FALSE
	///sound played mere seconds before impact
	var/warning_sound = 'sound/machines/hydraulics_2.ogg'
	var/ammo_used_per_firing = 1
	var/point_cost = 0 //how many points it costs to build this with the fabricator, set to 0 if unbuildable.
	///Type of ammo
	var/ammo_type
	///How strong the explosion is
	var/explosion_power = 0
	///How much the explosion will lose power per turf
	var/explosion_falloff = 0
	///Fire radius, for incendiary weapons
	var/fire_range = 0
	///Type of CAS dot indicator effect to be used
	var/cas_effect = /obj/effect/overlay/blinking_laser
	///CAS impact prediction type used for codex. Explosive, incendiary, etc
	var/prediction_type

/obj/structure/ship_ammo/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	. = ..()
	if(.)
		return

	if(!attached_clamp.loaded || !istype(attached_clamp.loaded, type))
		return

	var/obj/structure/ship_ammo/SA = attached_clamp.loaded

	if(!SA.transferable_ammo || !SA.ammo_count) //not transferable
		return

	var/transf_amt = min(max_ammo_count - ammo_count, SA.ammo_count)
	if(!transf_amt)
		return

	ammo_count += transf_amt
	SA.ammo_count -= transf_amt
	to_chat(user, span_notice("You transfer [transf_amt] [ammo_name] to [src]."))
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	if(!SA.ammo_count)
		attached_clamp.loaded = null
		attached_clamp.update_icon()
		qdel(SA)

//what to show to the user that examines the weapon we're loaded on.
/obj/structure/ship_ammo/proc/show_loaded_desc(mob/user)
	return "It's loaded with \a [src]."

/obj/structure/ship_ammo/proc/detonate_on(turf/impact, attackdir = NORTH)
	return

//CAS impact prediction.

/// Gets the turfs this ammo type would affect. Attackdir can be left alone if the ammo type is not directional
/obj/structure/ship_ammo/proc/get_turfs_to_impact(turf/epicenter, attackdir = NORTH)
	switch(prediction_type)
		if(CAS_AMMO_EXPLOSIVE)
			return get_explosion_impact(epicenter)
		if(CAS_AMMO_INCENDIARY)
			return filled_turfs(epicenter, fire_range, "circle")

	//If it's CAS_AMMO_HARMLESS, we don't need to do anything

	return //For anything else needed, add a special version of this proc in the subtype

/// "Mini" version of explode() code, returns the tiles that *would* be hit if an explosion were to happen
/obj/structure/ship_ammo/proc/get_explosion_impact(turf/impact)
	var/turf/epicenter = get_turf(impact)
	if(!epicenter)
		return

	var/max_range = round(explosion_power / explosion_falloff)

	var/list/turfs_in_range = block(
		locate(
			max(epicenter.x - max_range, 1),
			max(epicenter.y - max_range, 1),
			epicenter.z
			),
		locate(
			min(epicenter.x + max_range, world.maxx),
			min(epicenter.y + max_range, world.maxy),
			epicenter.z
			)
		)

	var/current_exp_block = epicenter.density ? epicenter.explosion_block : 0
	for(var/obj/blocking_object in epicenter)
		if(!blocking_object.density)
			continue
		current_exp_block += ((blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(0) : blocking_object.explosion_block ) //0 is the result of get_dir between two atoms on the same tile.

	var/list/turfs_by_dist = list()
	turfs_by_dist[epicenter] = current_exp_block
	turfs_in_range[epicenter] = current_exp_block

	var/list/turfs_impacted = list(epicenter)
	var/list/outline_turfs_impacted = list()

	for(var/turf/affected_turf AS in turfs_in_range)

		var/dist = turfs_in_range[epicenter]
		var/turf/expansion_wave_loc = epicenter
		do
			var/expansion_dir = get_dir(expansion_wave_loc, affected_turf)
			if(ISDIAGONALDIR(expansion_dir)) //If diagonal we'll try to choose the easy path, even if it might be longer. Damn, we're lazy.
				var/turf/step_NS = get_step(expansion_wave_loc, expansion_dir & (NORTH|SOUTH))
				if(!turfs_in_range[step_NS])
					current_exp_block = step_NS.density ? step_NS.explosion_block : 0
					for(var/obj/blocking_object in step_NS)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_NS] = current_exp_block

				var/turf/step_EW = get_step(expansion_wave_loc, expansion_dir & (EAST|WEST))
				if(!turfs_in_range[step_EW])
					current_exp_block = step_EW.density ? step_EW.explosion_block : 0
					for(var/obj/blocking_object in step_EW)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_EW] = current_exp_block

				if(turfs_in_range[step_NS] < turfs_in_range[step_EW])
					expansion_wave_loc = step_NS
				else if(turfs_in_range[step_NS] > turfs_in_range[step_EW])
					expansion_wave_loc = step_EW
				else if(abs(expansion_wave_loc.x - affected_turf.x) < abs(expansion_wave_loc.y - affected_turf.y)) //Both directions offer the same resistance. Lets check if the direction pends towards either cardinal.
					expansion_wave_loc = step_NS
				else //Either perfect diagonal, in which case it doesn't matter, or leaning towards the X axis.
					expansion_wave_loc = step_EW
			else
				expansion_wave_loc = get_step(expansion_wave_loc, expansion_dir)

			dist++

			if(isnull(turfs_in_range[expansion_wave_loc]))
				current_exp_block = expansion_wave_loc.density ? expansion_wave_loc.explosion_block : 0
				for(var/obj/blocking_object in expansion_wave_loc)
					if(!blocking_object.density)
						continue
					current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
				turfs_in_range[expansion_wave_loc] = current_exp_block

			if(isnull(turfs_by_dist[expansion_wave_loc]))
				turfs_by_dist[expansion_wave_loc] = dist
				if(max_range > dist)
					turfs_impacted += expansion_wave_loc
				else
					outline_turfs_impacted += expansion_wave_loc
					break //Explosion ran out of gas, no use continuing.

			else if(turfs_by_dist[expansion_wave_loc] > dist)
				turfs_by_dist[expansion_wave_loc] = dist

			dist += turfs_in_range[expansion_wave_loc]

			if(dist >= max_range)
				break //Explosion ran out of gas, no use continuing.

		while(expansion_wave_loc != affected_turf)

		if(isnull(turfs_by_dist[affected_turf]))
			turfs_by_dist[affected_turf] = 9999

	return turfs_impacted

///////////////

//30mm gun

/obj/structure/ship_ammo/cas/heavygun
	name = "\improper 30mm ammo crate"
	icon_state = "30mm_crate"
	desc = "A crate full of 30mm bullets used on the dropship heavy guns. Moving this will require some sort of lifter."
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/heavygun
	travelling_time = 4 SECONDS
	ammo_count = 2000
	max_ammo_count = 2000
	transferable_ammo = TRUE
	ammo_used_per_firing = 400
	point_cost = 85
	///Radius of the square that the bullets will strafe
	var/bullet_spread_range = 2
	///Width of the square we are attacking, so you can make rectangular attacks later
	var/attack_width = 3
	ammo_type = CAS_30MM
	cas_effect = /obj/effect/overlay/blinking_laser/heavygun

/obj/structure/ship_ammo/cas/heavygun/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] round\s."

/obj/structure/ship_ammo/cas/heavygun/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] round\s."

/obj/structure/ship_ammo/cas/heavygun/get_turfs_to_impact(turf/impact, attackdir = NORTH)
	var/turf/beginning = impact
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i=0 to bullet_spread_range)
		beginning = get_step(beginning, revdir)
	var/list/strafelist = list(beginning)
	strafelist += get_step(beginning, turn(attackdir, 90))
	strafelist += get_step(beginning, turn(attackdir, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to bullet_spread_range*2)
		beginning = get_step(beginning, attackdir)
		strafelist += beginning
		strafelist += get_step(beginning, turn(attackdir, 90))
		strafelist += get_step(beginning, turn(attackdir, -90))

	return strafelist

/obj/structure/ship_ammo/cas/heavygun/detonate_on(turf/impact, attackdir = NORTH)
	playsound(impact, 'sound/effects/casplane_flyby.ogg', 40)
	strafe_turfs(get_turfs_to_impact(impact, attackdir))

///Takes the top 3 turfs and miniguns them, then repeats until none left
/obj/structure/ship_ammo/cas/heavygun/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], get_sfx("explosion"), 40, 1, 20, falloff = 3)
	for(var/i=1 to attack_width)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_LIGHT)
		new /obj/effect/temp_visual/heavyimpact(strafed)
		for(var/atom/movable/AM AS in strafed)
			if(QDELETED(AM))
				continue
			//This may seem a bit wacky as we're exploding the turf's content twice, but doing it another way would be even more wacky because of how hard it is to modify explosion damage without adding a whole other explosion type
			AM.ex_act(EXPLODE_LIGHT)

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 2)

/obj/structure/ship_ammo/cas/heavygun/highvelocity
	name = "high-velocity 30mm ammo crate"
	icon_state = "30mm_crate_hv"
	desc = "A crate full of 30mm high-velocity bullets used on the dropship heavy guns. Moving this will require some sort of lifter."
	travelling_time = 2 SECONDS
	point_cost = 175

//railgun
/obj/structure/ship_ammo/railgun
	name = "Railgun Ammo"
	desc = "This is not meant to exist. Moving this will require some sort of lifter."
	icon_state = "30mm_crate_hv"
	icon = 'icons/obj/structures/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/minirocket_pod
	ammo_count = 400
	max_ammo_count = 400
	ammo_name = "railgun"
	ammo_used_per_firing = 10
	travelling_time = 0 SECONDS
	transferable_ammo = TRUE
	point_cost = 0
	ammo_type = RAILGUN_AMMO
	explosion_power = 200
	explosion_falloff = 75
	prediction_type = CAS_AMMO_EXPLOSIVE

/obj/structure/ship_ammo/railgun/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	cell_explosion(impact, explosion_power, explosion_falloff, EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL, color = COLOR_CYAN, adminlog = FALSE)//no messaging admin, that'd spam them.
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last railgun has fired and impacted the ground.

/obj/structure/ship_ammo/railgun/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] slug\s."

/obj/structure/ship_ammo/railgun/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] slug\s."

//laser battery

/obj/structure/ship_ammo/cas/laser_battery
	name = "high-capacity laser battery"
	icon_state = "laser_battery"
	desc = "A high-capacity laser battery used to power laser beam weapons. Moving this will require some sort of lifter."
	travelling_time = 1 SECONDS
	ammo_count = 150
	max_ammo_count = 150
	ammo_used_per_firing = 50
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/laser_beam_gun
	ammo_name = "charge"
	transferable_ammo = TRUE
	warning_sound = 'sound/effects/nightvision.ogg'
	point_cost = 150
	///The length of the beam that will come out of when we fire do both ends xxxoxxx where o is where you click
	var/laze_radius = 5
	ammo_type = CAS_LASER_BATTERY
	cas_effect = /obj/effect/overlay/blinking_laser/laser

/obj/structure/ship_ammo/cas/laser_battery/examine(mob/user)
	. = ..()
	. += "It's at [round(100 * ammo_count / max_ammo_count)]% charge."

/obj/structure/ship_ammo/cas/laser_battery/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] at [round(100 * ammo_count / max_ammo_count)]% charge."

/obj/structure/ship_ammo/cas/laser_battery/get_turfs_to_impact(turf/epicenter, attackdir = NORTH)
	var/turf/beginning = epicenter
	var/turf/end = epicenter
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i = 0 to laze_radius)
		beginning = get_step(beginning, revdir)
		end = get_step(end, attackdir)
	return get_traversal_line(beginning, end)

/obj/structure/ship_ammo/cas/laser_battery/detonate_on(turf/impact, attackdir = NORTH)
	var/list/turf/lazertargets = get_turfs_to_impact(impact, attackdir)
	process_lazer(lazertargets)
	if(!ammo_count)
		QDEL_IN(src, laze_radius + 1) //deleted after last laser beam is fired and impact the ground.

///takes the top lazertarget on the stack and fires the lazer at it
/obj/structure/ship_ammo/cas/laser_battery/proc/process_lazer(list/lazertargets)
	laser_burn(lazertargets[1])
	lazertargets -= lazertargets[1]
	if(length(lazertargets))
		INVOKE_NEXT_TICK(src, PROC_REF(process_lazer), lazertargets)

///Lazer ammo acts on the turf passed in
/obj/structure/ship_ammo/cas/laser_battery/proc/laser_burn(turf/T)
	playsound(T, 'sound/effects/pred_vision.ogg', 30, 1)
	for(var/mob/living/L in T)
		L.adjust_fire_loss(120)
		L.adjust_fire_stacks(20)
		L.IgniteMob()
	T.ignite(5, 30) //short but intense

//Rockets

/obj/structure/ship_ammo/cas/rocket
	name = "abstract rocket"
	icon_state = "single"
	icon = 'icons/obj/structures/mainship_props64.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/rocket_pod
	ammo_count = 1
	max_ammo_count = 1
	ammo_name = "rocket"
	ammo_id = ""
	bound_width = 64
	bound_height = 32
	travelling_time = 4 SECONDS
	point_cost = 0
	ammo_type = CAS_MISSILE
	prediction_type = CAS_AMMO_EXPLOSIVE

/obj/structure/ship_ammo/cas/rocket/detonate_on(turf/impact, attackdir = NORTH)
	qdel(src)

//this one is air-to-air only
/obj/structure/ship_ammo/cas/rocket/widowmaker
	name = "\improper AGM-224 'Widowmaker'"
	desc = "The AGM-224 is the latest in air to ground missile technology. Earning the nickname of 'Widowmaker' from various pilots after improvements allow it to land at incredibly high speeds, at the cost of explosive payload. Well suited for ground bombardment, its high velocity making it reach its target quickly. Moving this will require some sort of lifter."
	icon_state = "single"
	travelling_time = 2 SECONDS //very weak in damage, but quick to speed.
	ammo_id = ""
	point_cost = 195
	explosion_power = 320
	explosion_falloff = 80
	cas_effect = /obj/effect/overlay/blinking_laser/widowmaker

/obj/structure/ship_ammo/cas/rocket/widowmaker/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	cell_explosion(impact, explosion_power, explosion_falloff)
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/banshee
	name = "\improper PGHM-227 'Banshee'"
	desc = "The PGHM-227 missile is a mainstay of the fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target. Useful to clear out large areas. Moving this will require some sort of lifter."
	icon_state = "banshee"
	travelling_time = 4 SECONDS
	ammo_id = "b"
	point_cost = 225
	explosion_power = 320
	explosion_falloff = 100
	fire_range = 8
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/banshee

/obj/structure/ship_ammo/cas/rocket/banshee/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	cell_explosion(impact, explosion_power, explosion_falloff) //more spread out, with flames
	flame_radius(fire_range, impact)
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/keeper
	name = "\improper AGM-67 'Keeper II'"
	desc = "The AGM-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a contract that developed its guidance system and the various uses of it during peacekeeping conflicts. Its payload is designed to devastate armored targets. Moving this will require some sort of lifter."
	icon_state = "keeper"
	travelling_time = 4 SECONDS
	ammo_id = "k"
	point_cost = 250
	explosion_power = 550
	explosion_falloff = 145
	cas_effect = /obj/effect/overlay/blinking_laser/keeper

/obj/structure/ship_ammo/cas/rocket/keeper/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	cell_explosion(impact, explosion_power, explosion_falloff) //tighter blast radius, but more devastating near center
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/fatty
	name = "\improper PHGM-17 'Fatty'"
	desc = "The PHGM-17 'Fatty' is the most devestating rocket in TGMC arsenal, only second after its big cluster brother in Orbital Cannon. These rocket are also known for highest number of Friendly-on-Friendly incidents due to secondary cluster explosions as well as range of these explosions, TGMC recommends pilots to encourage usage of signal flares or laser for 'Fatty' support. Moving this will require some sort of lifter."
	icon_state = "fatty"
	travelling_time = 5 SECONDS
	ammo_id = "f"
	point_cost = 350
	explosion_power = 450
	explosion_falloff = 120
	cas_effect = /obj/effect/overlay/blinking_laser/fatty

/obj/structure/ship_ammo/cas/rocket/fatty/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	cell_explosion(impact, explosion_power, explosion_falloff) //first explosion is small to trick xenos into thinking its a minirocket.
	addtimer(CALLBACK(src, PROC_REF(delayed_detonation), impact), 3 SECONDS)

/**
 * proc/delayed_detonation(turf/impact)
 *
 * this proc is responsable for calculation and executing explosion in cluster like fashion
 * * (turf/impact): targets impacted turf from first explosion
 */

/obj/structure/ship_ammo/cas/rocket/fatty/proc/delayed_detonation(turf/impact)
	var/list/impact_coords = list(list(-3, 3), list(0, 4), list(3,3), list(-4, 0), list(4, 0), list(-3, -3), list(0, -4), list(3, -3))
	for(var/i = 1 to 8)
		var/list/coords = impact_coords[i]
		var/turf/detonation_target = locate(impact.x + coords[1],impact.y + coords[2], impact.z)
		detonation_target.ceiling_debris_check(2)
		cell_explosion(detonation_target, explosion_power, explosion_falloff, adminlog = FALSE)
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/napalm
	name = "\improper AGM-99 'Napalm'"
	desc = "The AGM-99 'Napalm' is an incendiary rocket used to turn specific targeted areas into giant balls of fire for quite a long time, it has a smaller outer explosive payload than other AGMs, however. Moving this will require some sort of lifter."
	icon_state = "napalm"
	travelling_time = 6 SECONDS
	ammo_id = "n"
	point_cost = 285
	explosion_power = 250
	explosion_falloff = 90
	fire_range = 8
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/incendiary

/obj/structure/ship_ammo/cas/rocket/napalm/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	cell_explosion(impact, explosion_power, explosion_falloff)
	flame_radius(fire_range, impact, 30, 60) //cooking for a long time
	var/datum/effect_system/smoke_spread/phosphorus/warcrime = new
	warcrime.set_up(fire_range + 1, impact, 8)
	warcrime.start()
	qdel(src)

//unguided rockets

/obj/structure/ship_ammo/cas/unguided_rocket
	name = "RGA-13A 'Sting'"
	desc = "Old unguided rockets found in the strategic warehouses of the UPP combat airfield. Moving this will require some sort of lifter."
	icon_state = "unguided_rocket"
	icon = 'icons/obj/structures/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/unguided_rocket_pod
	ammo_count = 12
	max_ammo_count = 12
	ammo_name = "unguided_rocket"
	travelling_time = 3 SECONDS
	transferable_ammo = TRUE
	point_cost = 150
	ammo_type = CAS_UNGUIDED_ROCKET
	explosion_power = 100
	explosion_falloff = 20
	prediction_type = CAS_AMMO_EXPLOSIVE
	cas_effect = /obj/effect/overlay/blinking_laser/minirocket

/obj/structure/ship_ammo/cas/unguided_rocket/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(5)
	cell_explosion(impact, explosion_power, explosion_falloff, adminlog = FALSE)
	if(!ammo_count)
		QDEL_IN(src, travelling_time)

/obj/structure/ship_ammo/cas/unguided_rocket/show_loaded_desc(mob/user)
		return "It's loaded with \a [src] containing [ammo_count] unguided rocket\s."

/obj/structure/ship_ammo/cas/unguided_rocket/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] unguided rocket\s."

//minirockets

/obj/structure/ship_ammo/cas/minirocket
	name = "MGA-112A 'Candies'"
	desc = "A pack of explosive mini-rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket"
	icon = 'icons/obj/structures/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/minirocket_pod
	ammo_count = 6
	max_ammo_count = 6
	ammo_name = "minirocket"
	travelling_time = 2 SECONDS
	transferable_ammo = TRUE
	point_cost = 125
	ammo_type = CAS_MINI_ROCKET
	explosion_power = 180
	explosion_falloff = 40
	prediction_type = CAS_AMMO_EXPLOSIVE
	cas_effect = /obj/effect/overlay/blinking_laser/minirocket

/obj/structure/ship_ammo/cas/minirocket/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(4)
	cell_explosion(impact, explosion_power, explosion_falloff, adminlog = FALSE)//no messaging admin, that'd spam them.
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/cas/minirocket/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] minirocket\s."

/obj/structure/ship_ammo/cas/minirocket/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] minirocket\s."

/obj/structure/ship_ammo/cas/minirocket/incendiary
	name = "MGA-110B incendiary"
	desc = "A pack of incendiary mini-rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket_inc"
	point_cost = 175
	travelling_time = 3 SECONDS
	fire_range = 4 //Fire range should be the same as the explosion range. Explosion should leave fire, not vice versa
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/incendiary

/obj/structure/ship_ammo/cas/minirocket/incendiary/detonate_on(turf/impact, attackdir = NORTH)
	. = ..()
	flame_radius(fire_range, impact)

/obj/structure/ship_ammo/cas/minirocket/phosphorus
	name = "MGA-110B phosphorus"
	desc = "A pack of incendiary phosphorus mini-rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket_inc_phos"
	point_cost = 350
	travelling_time = 4 SECONDS
	fire_range = 4
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/phosphorus // Enemies must know that something serious is coming at them
	var/datum/effect_system/smoke_spread/phosphorus/smoke

/obj/structure/ship_ammo/cas/minirocket/phosphorus/detonate_on(turf/impact, attackdir = NORTH)
	. = ..()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, impact, 7)
	smoke.start()
	flame_radius(fire_range, impact, burn_intensity = 75, burn_duration = 45, burn_damage = 15, fire_stacks = 75, colour = "blue")

/obj/structure/ship_ammo/cas/minirocket/smoke
	name = "MGA-108C smoke"
	desc = "A pack of screening smoke mini-rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket_smoke"
	point_cost = 35
	travelling_time = 2 SECONDS
	cas_effect = /obj/effect/overlay/blinking_laser/smoke
	explosion_power = 30
	explosion_falloff = 15

/obj/structure/ship_ammo/cas/minirocket/smoke/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	cell_explosion(impact, explosion_power, explosion_falloff, adminlog = FALSE)//no messaging admin, that'd spam them.
	var/datum/effect_system/smoke_spread/tactical/S = new
	S.set_up(12, impact)// Large radius, but dissipates quickly
	S.start()

/obj/structure/ship_ammo/cas/minirocket/tangle
	name = "MGA-106D tangle"
	desc = "A pack of mini-rockets loaded with plasma-draining Tanglefoot gas. Moving this will require some sort of lifter."
	icon_state = "minirocket_tfoot"
	point_cost = 150
	travelling_time = 6 SECONDS
	explosion_power = 30
	explosion_falloff = 15
	cas_effect = /obj/effect/overlay/blinking_laser/tfoot

/obj/structure/ship_ammo/cas/minirocket/tangle/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	cell_explosion(impact, explosion_power, explosion_falloff, adminlog = FALSE)//no messaging admin, that'd spam them.
	var/datum/effect_system/smoke_spread/plasmaloss/S = new
	S.set_up(10, impact, 10)// Between grenade and mortar
	S.start()

/obj/structure/ship_ammo/cas/minirocket/illumination
	name = "MGA-104I illuminant"
	desc = "A pack of mini-rockets, each loaded with a payload of white-star illuminant and a parachute, while extremely ineffective at damaging the enemy, it is very effective at lighting the battlefield so marines can damage the enemy. Moving this will require some sort of lifter."
	icon_state = "minirocket_ilm"
	point_cost = 25 // Not a real rocket, so its cheap
	travelling_time = 2 SECONDS
	cas_effect = /obj/effect/overlay/blinking_laser/flare
	explosion_power = 0
	explosion_falloff = 0
	prediction_type = CAS_AMMO_HARMLESS

/obj/structure/ship_ammo/cas/minirocket/illumination/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	addtimer(CALLBACK(src, PROC_REF(drop_cas_flare), impact), 1.5 SECONDS)
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/cas/minirocket/illumination/proc/drop_cas_flare(turf/impact)
	new /obj/effect/temp_visual/above_flare(impact)
