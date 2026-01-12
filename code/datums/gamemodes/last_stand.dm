/datum/game_mode/last_stand
	name = "Last Stand"
	config_tag = "Last Stand"
	xeno_abilities_flags = ABILITY_LAST_STAND
	round_type_flags = MODE_XENO_SPAWN_PROTECT
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/requisitions/tech = 1,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/civilian/clown = -1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/robot = -1,
	)
	xenorespawn_time = 1 MINUTES

	whitelist_ground_maps = list(MAP_LAST_STAND)

	///time between waves
	var/waves_check_interval = 1 MINUTES
	///waves timer
	var/last_waves_check

	///the strength of the waves is ultimately multiplied by the number of people
	var/waves_power = 1
	var/health_factor = 1
	///time from the beginning of the round when the waves will not spawn
	var/neutral_time = 5 MINUTES
	///list of possible wave generators
	var/list/waves_spawner = list()

/datum/game_mode/last_stand/announce()
	to_chat(world, "<b>The current game mode is - Last Stand!</b>")

/datum/game_mode/last_stand/pre_setup()
	. = ..()

	for(var/job_type in GLOB.spawns_by_job)
		for(var/atom/loc in GLOB.spawns_by_job[job_type])
			if(is_ground_level(loc.z))
				continue
			if(is_centcom_level(loc.z))
				continue
			GLOB.spawns_by_job[job_type] -= loc

	for(var/latejoin in GLOB.latejoin)
		var/atom/loc = latejoin
		if(is_ground_level(loc.z))
			continue
		GLOB.latejoin -= loc

	for(var/latejoin_cryo in GLOB.latejoin_cryo)
		var/atom/loc = latejoin_cryo
		if(is_ground_level(loc.z))
			continue
		GLOB.latejoin_cryo -= loc

	for(var/latejoin_gateway in GLOB.latejoin_gateway)
		var/atom/loc = latejoin_gateway
		if(is_ground_level(loc.z))
			continue
		GLOB.latejoin_gateway -= loc

	for(var/atom/nuke in GLOB.nuclear_bombs)
		var/turf_targeted = get_turf(nuke)
		new /obj/effect/ai_node/goal(turf_targeted, null)

	GLOB.start_squad_landmarks_list = null
	GLOB.latejoin_squad_landmarks_list = null

/datum/game_mode/last_stand/post_setup()
	. = ..()

	for(var/spawner in subtypesof(/datum/wave_spawner))
		var/datum/wave_spawner/wave = spawner
		wave = new spawner()
		waves_spawner[spawner] = wave
	for(var/i in 1 to max(MIN_PHORON_MINER_AMOUNT, length(GLOB.miner_phorone_locs) * 0.5))
		new /obj/machinery/miner/damaged(pick_n_take(GLOB.miner_phorone_locs))
	for(var/i in 1 to max(MIN_PLATINUM_MINER_AMOUNT, length(GLOB.miner_platinum_locs) * 0.5))
		new /obj/machinery/miner/damaged/platinum(pick_n_take(GLOB.miner_platinum_locs))

/datum/game_mode/last_stand/process()
	. = ..()
	if(world.time < SSticker.round_start_time + neutral_time)
		return
	if(world.time > last_waves_check + waves_check_interval)
		spawn_wave()
		last_waves_check = world.time

/datum/game_mode/last_stand/proc/spawn_wave()
	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/points = (living_player_list[1] * 0.2) + waves_power

	var/wave_spawned = FALSE
	var/wave_checks = 0
	while(!wave_spawned)
		var/datum/wave_spawner/wave = waves_spawner[pick(waves_spawner)]
		if(wave_checks >= 100 || points <= 0)
			WARNING("Game mode couldn't spawn wave")
			break
		if(wave.min_time > world.time - SSticker.round_start_time)
			wave_checks++
			continue
		if(wave.max_time != -1 && wave.max_time < world.time - SSticker.round_start_time)
			wave_checks++
			continue
		wave_spawned = wave.spawn_wave(points, health_factor)

	waves_power += 0.08
	health_factor += 0.03

/datum/game_mode/last_stand/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/num_humans = living_player_list[1]

	if(!length(GLOB.nuclear_bombs))
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos destroyed the bombs, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE

	if(!num_humans)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE

	return FALSE

/datum/game_mode/last_stand/can_start(bypass_checks = FALSE)
	. = ..()
	if(!.)
		return
	if(!length(GLOB.ready_players) && !bypass_checks)
		to_chat(world, "<b>Unable to start [name].</b> No candidate found.")
		return FALSE

/datum/game_mode/last_stand/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")
