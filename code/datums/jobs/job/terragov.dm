/datum/job/terragov
	faction = FACTION_TERRAGOV

/datum/job/terragov/radio_help_message(mob/M)
	. = ..()
	if(CONFIG_GET(number/minimal_access_threshold))
		var/msg = "As this ship was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "skeleton crew, additional access may" : "full crew, only the job's necessities"] have been added to the crew's ID cards."
		to_chat(M, span_notice(msg))

/datum/job/terragov/return_spawn_type(datum/preferences/prefs)
	switch(prefs?.species)
		if("Vatborn")
			return /mob/living/carbon/human/species/vatborn
		if("Prototype Supersoldier")
			return /mob/living/carbon/human/species/prototype_supersoldier
		else
			return /mob/living/carbon/human
