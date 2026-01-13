/datum/species/synthetic
	name = "Synthetic"

	default_language_holder = /datum/language_holder/synthetic
	unarmed_type = /datum/unarmed_attack/punch

	total_health = 125 //more health than regular humans

	brute_mod = 0.7
	burn_mod = 0.8 // A slight amount of burn resistance. Changed from 0.7 due to their critical condition phase.

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR|ROBOTIC_LIMBS|GREYSCALE_BLOOD

	blood_color = "#EEEEEE"

	has_organ = list()

	lighting_cutoff = LIGHTING_CUTOFF_HIGH

	screams = list(MALE = SFX_MALE_SCREAM, FEMALE = SFX_FEMALE_SCREAM)
	paincries = list(MALE = SFX_MALE_PAIN, FEMALE = SFX_FEMALE_PAIN)
	goredcries = list(MALE = SFX_MALE_GORED, FEMALE = SFX_FEMALE_GORED)
	warcries = list(MALE = SFX_MALE_WARCRY, FEMALE = SFX_FEMALE_WARCRY)
	laughs = list(MALE = SFX_MALE_LAUGH, FEMALE = SFX_FEMALE_LAUGH)
	special_death_message = "You have been shut down.<br><small>But it is not the end of you yet... if you still have your body, wait until somebody can resurrect you...</small>"

/datum/species/synthetic/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.add_hud_to(H)
	H.health_threshold_crit = -100

/datum/species/synthetic/prefs_name(datum/preferences/prefs)
	. = prefs.synthetic_name
	if(!. || . == "Undefined") //In case they don't have a name set.
		switch(prefs.gender)
			if(MALE)
				. = "David"
			if(FEMALE)
				. = "Anna"
			else
				. = "Jeri"
		to_chat(prefs.parent, span_warning("You forgot to set your synthetic name in your preferences. Please do so next time."))

/datum/species/synthetic/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.remove_hud_from(H)
	H.health_threshold_crit = -50

/mob/living/carbon/human/species/synthetic/binarycheck(mob/H)
	return TRUE

/datum/species/synthetic/early // Worse at medical, better at engineering. Tougher in general than later synthetics.
	name = "Early Synthetic"
	icobase = 'icons/mob/human_races/r_synthetic.dmi'
	slowdown = 1.15 //Slower than Late Synths.
	total_health = 200 //Tough boys, very tough boys.
	brute_mod = 0.6
	burn_mod = 0.6

	species_flags = NO_BREATHE|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_UNDERWEAR|ROBOTIC_LIMBS|GREYSCALE_BLOOD

	hair_color = "#000000"
