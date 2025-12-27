/obj/structure/xeno/silo
	name = "Resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -24
	max_integrity = 1000
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PLASMACUTTER_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|CRITICAL_STRUCTURE|XENO_STRUCT_WARNING_RADIUS|XENO_STRUCT_DAMAGE_ALERT
	layer = ABOVE_WEEDS_LAYER
	plane = FLOOR_PLANE
	///How many larva points one silo produce in one minute
	var/larva_spawn_rate = 0.5
	var/number_silo
	///Strength of pheromones given by silo.
	var/aura_strength = 4
	///Radius (in tiles) of the pheromones given by silo.
	var/aura_radius = 30
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)

/obj/structure/xeno/silo/Initialize(mapload, _hivenumber)
	if(CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_SILO_NO_LARVA))
		xeno_structure_flags &= ~CRITICAL_STRUCTURE
	. = ..()

	if(SSticker.mode?.round_type_flags & MODE_SILOS_SPAWN_MINIONS)
		SSspawning.registerspawner(src, INFINITY, GLOB.xeno_ai_spawnable, 0, 1, CALLBACK(src, PROC_REF(on_spawn)), list(COMSIG_QDELETING, COMSIG_MOB_DEATH))
		SSspawning.spawnerdata[src].required_increment = 2 * max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER)/SSspawning.wait
		SSspawning.spawnerdata[src].max_allowed_mobs = max(1, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count * 0.5)
	update_minimap_icon()
	SSaura.add_emitter(src, AURA_XENO_RECOVERY, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	SSaura.add_emitter(src, AURA_XENO_WARDING, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	SSaura.add_emitter(src, AURA_XENO_FRENZY, aura_radius, aura_strength, -1, FACTION_XENO, hivenumber)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/xeno/silo/LateInitialize()
	. = ..()
	if(!(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN))
		QDEL_NULL(proximity_monitor)
	var/siloprefix = GLOB.hive_datums[hivenumber].name
	number_silo = length(GLOB.xeno_resin_silos_by_hive[hivenumber]) + 1
	name = "[siloprefix == "Normal" ? "" : "[siloprefix] "][name] [number_silo]"
	LAZYADDASSOC(GLOB.xeno_resin_silos_by_hive, hivenumber, src)

	if(!locate(/obj/alien/weeds) in loc)
		new /obj/alien/weeds/node(loc)
	if(GLOB.hive_datums[hivenumber])
		RegisterSignals(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), PROC_REF(is_burrowed_larva_host))
		if(length(GLOB.xeno_resin_silos_by_hive[hivenumber]) == 1)
			GLOB.hive_datums[hivenumber].give_larva_to_next_in_queue()
	var/turf/tunnel_turf = get_step(src, NORTH)
	if(tunnel_turf.can_dig_xeno_tunnel())
		var/obj/structure/xeno/tunnel/newt = new(tunnel_turf, hivenumber)
		newt.tunnel_desc = "[AREACOORD_NO_Z(newt)]"
		newt.name += " [name]"
	if(GLOB.hive_datums[hivenumber])
		SSticker.mode.update_silo_death_timer(GLOB.hive_datums[hivenumber])

/obj/structure/xeno/silo/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if(GLOB.hive_datums[hivenumber])
		INVOKE_NEXT_TICK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, update_silo_death_timer), GLOB.hive_datums[hivenumber]) // checks all silos next tick after this one is gone
		UnregisterSignal(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		GLOB.hive_datums[hivenumber].xeno_message("A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, FALSE, loc, 'sound/voice/alien/help2.ogg',FALSE , null, /atom/movable/screen/arrow/silo_damaged_arrow)
		notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)
		playsound(loc,'sound/effects/alien/egg_burst.ogg', 75)
	return ..()

/obj/structure/xeno/silo/Destroy()
	GLOB.xeno_resin_silos_by_hive[hivenumber] -= src

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(src, pick(CARDINAL_ALL_DIRS)))

	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			. += span_warning("It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.")
		if(20 to 40)
			. += span_warning("It looks severely damaged, its movements slow.")
		if(40 to 60)
			. += span_warning("It's quite beat up, but it seems alive.")
		if(60 to 80)
			. += span_warning("It's slightly damaged, but still seems healthy.")
		if(80 to 100)
			. += span_info("It appears in good shape, pulsating healthily.")

/obj/structure/xeno/silo/take_damage(damage_amount, damage_type, damage_flag = null, effects = TRUE, attack_dir, armour_penetration, mob/living/blame_mob)
	. = ..()
	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/silo/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "silo[threat_warning ? "_warn" : "_passive"]", MINIMAP_LABELS_LAYER))

/obj/structure/xeno/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec

/obj/structure/xeno/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(GLOB.hive_datums[hivenumber])
		silos += src

/// Transfers the spawned minion to the silo's hivenumber.
/obj/structure/xeno/silo/proc/on_spawn(list/newly_spawned_things)
	for(var/mob/living/carbon/xenomorph/spawned_minion AS in newly_spawned_things)
		spawned_minion.transfer_to_hive(hivenumber)

/obj/structure/xeno/silo/crash
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PLASMACUTTER_IMMUNE | INDESTRUCTIBLE
