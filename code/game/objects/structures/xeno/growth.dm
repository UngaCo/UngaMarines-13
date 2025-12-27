/obj/alien/resin/resin_growth
	name = GROWTH_WALL
	desc = "Some sort of resin growth. Looks incredibly fragile"
	icon_state = "growth_wall"
	density = FALSE
	opacity = FALSE
	max_integrity = 5
	layer = BELOW_OBJ_LAYER
	hit_sound = SFX_ALIEN_RESIN_MOVE
	var/growth_time = 300 SECONDS
	var/structure = "wall"

/obj/alien/resin/resin_growth/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(on_growth)), growth_time, TIMER_DELETE_ME)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(trample_plant)
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/alien/resin/resin_growth/proc/trample_plant(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ismob(O) || isxeno(O))
		return
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	deconstruct(TRUE)

/obj/alien/resin/resin_growth/proc/on_growth()
	playsound(src, SFX_ALIEN_RESIN_BUILD, 25)
	var/turf/T = get_turf(src)
	switch(structure)
		if("wall")
			var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
			baseturfs |= T.type
			T.change_turf(/turf/closed/wall/resin/regenerating, baseturfs)
		if("door")
			new /obj/structure/mineral_door/resin(T)
	deconstruct(TRUE)

/obj/alien/resin/resin_growth/door
	name = GROWTH_DOOR
	structure = "door"
	icon_state = "growth_door"
