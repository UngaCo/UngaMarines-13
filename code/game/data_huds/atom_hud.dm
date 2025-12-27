/datum/atom_hud/simple //Naked-eye observable statuses.
	hud_icons = list(STATUS_HUD_SIMPLE)

/datum/atom_hud/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

//med hud used by silicons, only shows humans with a uniform with sensor mode activated.
/datum/atom_hud/medical/basic

/datum/atom_hud/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U))
		return FALSE
	if(U.sensor_mode <= 2)
		return FALSE
	return TRUE

/datum/atom_hud/medical/basic/add_to_single_hud(mob/user, mob/target)
	if(check_sensors(user))
		return ..()

/datum/atom_hud/medical/basic/proc/update_suit_sensors(mob/living/carbon/human/H)
	if(check_sensors(H))
		add_to_hud(H)
	else
		remove_from_hud(H)

//med hud used by medical hud glasses
/datum/atom_hud/medical/advanced

//HUD used by the synth, separate typepath so it's not accidentally removed.
/datum/atom_hud/medical/advanced/synthetic

//medical hud used by ghosts
/datum/atom_hud/medical/observer
	hud_icons = list(HEALTH_HUD, XENO_EMBRYO_HUD, XENO_REAGENT_HUD, XENO_DEBUFF_HUD, STATUS_HUD, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD, XENO_BANISHED_HUD, HUNTER_CLAN, HUNTER_HUD, HUNTER_HEALTH_HUD)

/datum/atom_hud/medical/pain
	hud_icons = list(PAIN_HUD)

//infection status that appears on humans and monkeys, viewed by xenos only.
/datum/atom_hud/xeno_infection
	hud_icons = list(XENO_EMBRYO_HUD)

//active reagent hud that apppears only for xenos
/datum/atom_hud/xeno_reagents
	hud_icons = list(XENO_REAGENT_HUD)

///hud component for revealing xeno specific status effect debuffs to xenos
/datum/atom_hud/xeno_debuff
	hud_icons = list(XENO_DEBUFF_HUD)

//Xeno status hud, for xenos
/datum/atom_hud/xeno
	hud_icons = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, ENHANCEMENT_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_FIRE_HUD, XENO_RANK_HUD, XENO_PRIMO_HUD, XENO_BANISHED_HUD, XENO_BLESSING_HUD, XENO_EVASION_HUD, HUNTER_HUD)

/datum/atom_hud/xeno_heart
	hud_icons = list(HEART_STATUS_HUD)

/datum/atom_hud/squad
	hud_icons = list(SQUAD_HUD_TERRAGOV, MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)

/datum/atom_hud/order
	hud_icons = list(ORDER_HUD)

/datum/atom_hud/hunter_clan
	hud_icons = list(HUNTER_CLAN)

/datum/atom_hud/hunter_hud
	hud_icons = list(HUNTER_HUD, HUNTER_HEALTH_HUD)
