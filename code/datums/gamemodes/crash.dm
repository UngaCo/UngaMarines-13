/datum/game_mode/infestation/crash
	name = "Crash"
	config_tag = "Crash"
	required_players = 2
	round_type_flags = MODE_INFESTATION|MODE_XENO_SPAWN_PROTECT|MODE_DEAD_GRAB_FORBIDDEN|MODE_DISALLOW_RAILGUN|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_SILOS_SPAWN_MINIONS|MODE_ALLOW_XENO_QUICKBUILD|MODE_HAS_MINERS
	xeno_abilities_flags = ABILITY_CRASH
	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/robot = -1,
		/datum/job/terragov/squad/engineer = 1,
		/datum/job/terragov/squad/corpsman = 1,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/xenomorph = FREE_XENO_AT_START
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 20,
		/datum/job/terragov/squad/corpsman = 5,
		/datum/job/terragov/squad/engineer = 5,
		/datum/job/xenomorph = CRASH_LARVA_POINTS_NEEDED,
	)
	blacklist_ground_maps = list(MAP_BIG_RED, MAP_DELTA_STATION, MAP_PRISON_STATION, MAP_LV_624, MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_LAST_STAND)

	restricted_castes = list(/datum/xeno_caste/ravager, /datum/xeno_caste/hivemind, /datum/xeno_caste/chimera)

	bioscan_interval = 0
	// Round end conditions
	var/shuttle_landed = FALSE
	var/marines_evac = CRASH_EVAC_NONE

	// Shuttle details
	var/shuttle_id = SHUTTLE_CANTERBURY
	var/obj/docking_port/mobile/crashmode/shuttle

	///How long between two larva check
	var/larva_check_interval = 1 MINUTES
	///Last time larva balance was checked
	var/last_larva_check

/datum/game_mode/infestation/crash/pre_setup()
	. = ..()

	// Spawn the ship
	if(TGS_CLIENT_COUNT >= 25)
		shuttle_id = SHUTTLE_BIGBURY
	if(!SSmapping.shuttle_templates[shuttle_id])
		message_admins("Gamemode: couldn't find a valid shuttle template for [shuttle_id]")
		CRASH("Shuttle [shuttle_id] wasn't found and can't be loaded")

	var/datum/map_template/shuttle/ST = SSmapping.shuttle_templates[shuttle_id]
	shuttle = SSshuttle.load_template_to_transit(ST)

	// Redefine the relevant spawnpoints after spawning the ship.
	for(var/job_type in shuttle.spawns_by_job)
		GLOB.spawns_by_job[job_type] = shuttle.spawns_by_job[job_type]

	GLOB.start_squad_landmarks_list = null
	GLOB.latejoin_squad_landmarks_list = null

	GLOB.latejoin = shuttle.latejoins
	GLOB.latejoin_cryo = shuttle.latejoins
	GLOB.latejoin_gateway = shuttle.latejoins
	// Launch shuttle
	var/list/valid_docks = list()
	for(var/obj/docking_port/stationary/crashmode/potential_crash_site in SSshuttle.stationary_docking_ports)
		if(!shuttle.check_dock(potential_crash_site, silent = TRUE))
			continue
		valid_docks += potential_crash_site

	if(!length(valid_docks))
		CRASH("No valid crash sides found!")
	var/obj/docking_port/stationary/crashmode/actual_crash_site = pick(valid_docks)

	shuttle.crashing = TRUE
	SSshuttle.moveShuttleToDock(shuttle.shuttle_id, actual_crash_site, TRUE) // FALSE = instant arrival
	addtimer(CALLBACK(src, PROC_REF(crash_shuttle), actual_crash_site), 10 MINUTES)

	GLOB.start_squad_landmarks_list = null

	GLOB.all_supply_groups -= "Factory" // In ideal world, we just balance factories out

	for(var/obj/machinery/telecomms/relay/preset/telecomms/relay AS in GLOB.ground_telecomms_relay)
		qdel(relay) // so there's no double intercomms, hacky, but i don't know a better way.

/datum/game_mode/infestation/crash/post_setup()
	. = ..()

	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)

	for(var/obj/machinery/computer/shuttle/shuttle_control/computer_to_disable AS in GLOB.shuttle_controls_list)
		if(istype(computer_to_disable, /obj/machinery/computer/shuttle/shuttle_control/canterbury))
			continue
		computer_to_disable.machine_stat |= BROKEN
		computer_to_disable.update_icon()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, PROC_REF(on_nuclear_explosion))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, PROC_REF(on_nuclear_diffuse))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, PROC_REF(on_nuke_started))

	if(!(round_type_flags & MODE_INFESTATION))
		return

	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/xeno/silo/crash(i)

	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_mob()

	for(var/i in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		if(isxenolarva(i)) // Larva
			var/mob/living/carbon/xenomorph/larva/X = i
			X.evolution_stored = X.xeno_caste.evolution_threshold //Immediate roundstart evo for larva.

/datum/game_mode/infestation/crash/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	priority_announce("Высадка запланирована через 10 минут. Приготовьтесь к посадке. Предварительное сканирование показывает наличие агрессивных форм биологической жизни. Ваша следующая миссия - заполучить коды доступа и активировать ядерную боеголовку.", title = "Доброе утро, товарищи!", type = ANNOUNCEMENT_PRIORITY, sound = 'sound/AI/crash_start.ogg', color_override = "red")

/datum/game_mode/infestation/crash/process()
	. = ..()

	if(world.time > last_larva_check + larva_check_interval)
		last_larva_check = world.time // It should stand first, so the check updates not after the balance_scales() gets completed
		balance_scales()

/datum/game_mode/infestation/crash/proc/crash_shuttle(obj/docking_port/stationary/target)
	shuttle_landed = TRUE
	shuttle.crashing = FALSE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CANTERBURRY_LANDING)
	generate_nuke_disk_spawners()

/datum/game_mode/infestation/crash/check_finished(force_end)
	if(round_finished)
		return TRUE

	if(!shuttle_landed && !force_end)
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]

	if(num_humans && planet_nuked == INFESTATION_NUKE_NONE && marines_evac == CRASH_EVAC_NONE && !force_end)
		return FALSE

	switch(planet_nuked)

		if(INFESTATION_NUKE_NONE)
			if(!num_humans)
				message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines
				round_finished = MODE_INFESTATION_X_MAJOR
				return TRUE
			if(marines_evac == CRASH_EVAC_COMPLETED || (!length(GLOB.active_nuke_list) && marines_evac != CRASH_EVAC_NONE))
				message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines evaced without a nuke
				round_finished = MODE_INFESTATION_X_MINOR
				return TRUE

		if(INFESTATION_NUKE_COMPLETED)
			if(marines_evac == CRASH_EVAC_NONE)
				message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines nuked the planet but didn't evac
				round_finished = MODE_INFESTATION_M_MINOR
				return TRUE
			message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines nuked the planet and managed to evac
			round_finished = MODE_INFESTATION_M_MAJOR
			return TRUE

		if(INFESTATION_NUKE_COMPLETED_SHIPSIDE, INFESTATION_NUKE_COMPLETED_OTHER)
			message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //marines nuked themselves somehow
			round_finished = MODE_INFESTATION_X_MAJOR
			return TRUE
	return FALSE

/datum/game_mode/infestation/crash/on_nuclear_diffuse(obj/machinery/nuclearbomb/bomb, mob/living/carbon/xenomorph/X)
	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	if(!num_humans) // no humans left on planet to try and restart it.
		addtimer(VARSET_CALLBACK(src, marines_evac, CRASH_EVAC_COMPLETED), 10 SECONDS)

/datum/game_mode/infestation/crash/can_summon_dropship(mob/user)
	to_chat(src, span_warning("This power doesn't work in this gamemode."))
	return FALSE

/// Adds more xeno job slots if needed.
/datum/game_mode/infestation/crash/proc/balance_scales()
	var/datum/hive_status/normal/xeno_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	// Spawn more xenos to help maintain the ratio.
	var/xenomorphs_below_ratio = trunc(get_jobpoint_difference() / xeno_job.job_points_needed)
	if(xenomorphs_below_ratio >= 1)
		xeno_job.add_job_positions(xenomorphs_below_ratio)
		xeno_hive.update_tier_limits()
		return
	if(xeno_hive.total_xenos_for_evolving() <= 0)
		xeno_job.add_job_positions(2)
		xeno_hive.update_tier_limits()

/// Gets the difference of job points between humans and xenos. Negative means too many xenos. Positive means too many humans.
/datum/game_mode/infestation/crash/proc/get_jobpoint_difference()
	var/datum/hive_status/normal/xeno_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	return get_total_joblarvaworth(count_flags = COUNT_IGNORE_HUMAN_SSD) - (xeno_hive.total_xenos_for_evolving() * xeno_job.job_points_needed)

/datum/game_mode/infestation/crash/get_adjusted_jobworth_list(list/jobworth_list)
	var/list/adjusted_jobworth_list = deep_copy_list(jobworth_list)
	var/jobpoint_difference = get_jobpoint_difference()
	for(var/index in jobworth_list)
		var/datum/job/scaled_job = SSjob.GetJobType(index)
		if(!(index in SSticker.mode.valid_job_types))
			continue
		if(!isxenosjob(scaled_job))
			continue
		var/amount = jobworth_list[index]
		adjusted_jobworth_list[index] = clamp(jobpoint_difference + amount, 0, amount)
	return adjusted_jobworth_list
