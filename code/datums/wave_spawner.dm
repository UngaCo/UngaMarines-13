/datum/wave_spawner
	var/min_time = 0
	var/max_time = -1

	var/list/spawn_types = list()
	var/points_factor = 1

/datum/wave_spawner/proc/spawn_wave(points, health_factor)
	if(points <= 0)
		return FALSE
	if(!length(spawn_types))
		return FALSE
	for(var/i in 1 to points * points_factor)
		var/spawntype = pick(spawn_types)
		var/mob/living/carbon/xenomorph/xenomorph = new spawntype(pick(GLOB.waves_spawner_locs))
		xenomorph.maxHealth *= health_factor
		xenomorph.health = xenomorph.maxHealth
	return TRUE

/datum/wave_spawner/minions
	spawn_types = list(
		/mob/living/carbon/xenomorph/beetle/ai,
		/mob/living/carbon/xenomorph/mantis/ai,
		/mob/living/carbon/xenomorph/scorpion/ai,
		//mob/living/carbon/xenomorph/nymph/ai,
	)
	points_factor = 2

/datum/wave_spawner/t1
	spawn_types = list(
		//mob/living/carbon/xenomorph/runner/ai,
		/mob/living/carbon/xenomorph/sentinel/ai,
		/mob/living/carbon/xenomorph/defender/ai,
		//mob/living/carbon/xenomorph/drone/ai,
	)
	points_factor = 1.5
	min_time = 10 MINUTES

/datum/wave_spawner/t2
	spawn_types = list(
		//mob/living/carbon/xenomorph/hivelord/ai,
		/mob/living/carbon/xenomorph/hunter/ai,
		/mob/living/carbon/xenomorph/spitter/ai,
		/mob/living/carbon/xenomorph/warrior/ai,
	)
	min_time = 15 MINUTES
	points_factor = 1

/datum/wave_spawner/t3
	spawn_types = list(
		/mob/living/carbon/xenomorph/crusher/ai,
		/mob/living/carbon/xenomorph/praetorian/ai,
		/mob/living/carbon/xenomorph/ravager/ai,
		/mob/living/carbon/xenomorph/boiler/ai,
		/mob/living/carbon/xenomorph/chimera/ai,
	)
	min_time = 20 MINUTES
	points_factor = 0.5

/datum/wave_spawner/random
	spawn_types = list(
		/mob/living/carbon/xenomorph/mantis/ai,
		/mob/living/carbon/xenomorph/scorpion/ai,
		//mob/living/carbon/xenomorph/nymph/ai,
		//mob/living/carbon/xenomorph/runner/ai,
		/mob/living/carbon/xenomorph/sentinel/ai,
		/mob/living/carbon/xenomorph/defender/ai,
		//mob/living/carbon/xenomorph/drone/ai,
		//mob/living/carbon/xenomorph/hivelord/ai,
		/mob/living/carbon/xenomorph/hunter/ai,
		/mob/living/carbon/xenomorph/spitter/ai,
		/mob/living/carbon/xenomorph/warrior/ai,
		/mob/living/carbon/xenomorph/crusher/ai,
		/mob/living/carbon/xenomorph/praetorian/ai,
		/mob/living/carbon/xenomorph/ravager/ai,
		/mob/living/carbon/xenomorph/boiler/ai,
		/mob/living/carbon/xenomorph/chimera/ai,
	)
	min_time = 20 MINUTES
	points_factor = 0.8

/datum/wave_spawner/queen
	spawn_types = list(
		/mob/living/carbon/xenomorph/queen/ai,
	)
	min_time = 35 MINUTES
	points_factor = 0.2
