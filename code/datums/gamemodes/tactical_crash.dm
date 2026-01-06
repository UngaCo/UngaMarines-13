/datum/game_mode/infestation/crash/tactical_crash
	name = "Tactical Crash"
	config_tag = "TacCrash"
	required_players = 2
	valid_job_types = list(
		/datum/job/clf/standard = -1,
		/datum/job/clf/medic = 1,
		/datum/job/clf/specialist = 1,
		/datum/job/clf/leader = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/xenomorph = FREE_XENO_AT_START
	)

	var/shuttle_id = SHUTTLE_CANTERBURY
