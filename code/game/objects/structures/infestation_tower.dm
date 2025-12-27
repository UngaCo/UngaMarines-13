/obj/structure/sensor_tower_infestation
	name = "sensor tower"
	desc = "A tall tower with a sensor array at the top and a control box at the bottom. Has a lengthy activation process."
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"
	obj_flags = NONE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	resistance_flags = RESIST_ALL | DROPSHIP_IMMUNE
	///The timer for when the sensor tower activates
	var/current_timer
	///Time it takes for the sensor tower to fully activate
	var/generate_time = 180 SECONDS
	///Time it takes to start the activation
	var/activate_time = 5 SECONDS
	///Time it takes to stop the activation
	var/deactivate_time = 10 SECONDS
	///Count amount of sensor towers existing
	var/static/id = 1
	///The id for the tower when it initializes, used for minimap icon
	var/towerid
	///True if the sensor tower has finished activation, used for minimap icon and preventing deactivation
	var/activated = FALSE

	//point generation

	///Tracks how many ticks have passed since we last added a sheet of material
	var/add_tick = 0
	///How many times we neeed to tick for a resource to be created, in this case this is 2* the specified amount
	var/required_ticks = 50
	///The amount of profit, less useful than phoron miners
	var/points_income = 500
	///Applies the actual bonus points for the dropship for each sale, even much more than miners
	var/dropship_bonus = 40

/obj/structure/sensor_tower_infestation/Initialize(mapload)
	. = ..()
	name += " " + num2text(id)
	towerid = id
	id++
	update_icon()

/obj/structure/sensor_tower_infestation/update_icon_state()
	icon_state = initial(icon_state)
	if(current_timer || activated)
		icon_state += "_loyalist"

/obj/structure/sensor_tower_infestation/attack_hand(mob/living/user)
	if(!ishuman(user))
		return
	if(user.do_actions)
		user.balloon_alert(user, "You are already doing something!")
		return
	interaction(user)

///Handles xeno interactions with the tower
/obj/structure/sensor_tower_infestation/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)

	//only t4 and liders can cap tower
	if(!(CHECK_BITFIELD(X.xeno_caste.can_flags, CASTE_CAN_CORRUPT_GENERATOR) || X.xeno_flags & XENO_LEADER))
		return

	if(X.status_flags & INCORPOREAL)
		return

	if(attack_alien_state_check(X))
		return

	balloon_alert(X, "You begin to deativate sensor tower!")
	if(!do_after(X, deactivate_time, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return

	if(attack_alien_state_check(X))
		return
	balloon_alert(X, "You deactivate sensor tower!")
	deactivate()

/obj/structure/sensor_tower_infestation/proc/attack_alien_state_check(mob/living/user)
	if(activated)
		return FALSE
	if(current_timer)
		return FALSE
	balloon_alert(user, "This sensor tower is not activated yet, don't let it be activated!")
	return TRUE

///Handles attacker interactions with the tower
/obj/structure/sensor_tower_infestation/proc/interaction(mob/living/user)
	if(!attacker_state_check(user))
		return
	balloon_alert_to_viewers("Activating sensor tower...")
	if(user.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_TRAINED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to activate [src]."),
		span_notice("You fumble around figuring out how to activate [src]."))
		if(!do_after(user, 25 SECONDS, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	if(!do_after(user, activate_time, NONE, src))
		return
	if(!attacker_state_check(user))
		return
	balloon_alert_to_viewers("Sensor tower activated!")
	begin_activation()

///Checks whether an attack can currently activate this tower
/obj/structure/sensor_tower_infestation/proc/attacker_state_check(mob/living/user)
	if(activated)
		balloon_alert(user, "This sensor tower is already fully activated!")
		return FALSE
	if(current_timer)
		balloon_alert(user, "This sensor tower is currently activating!")
		return FALSE
	return TRUE

///Starts timer and sends an alert
/obj/structure/sensor_tower_infestation/proc/begin_activation()
	current_timer = addtimer(CALLBACK(src, PROC_REF(finish_activation)), generate_time, TIMER_STOPPABLE)
	update_icon()

	//marines
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.playsound_local(human, 'sound/effects/CIC_order.ogg', 10, 1)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is being activated, get ready to defend it team!", /atom/movable/screen/text/screen_text/picture/potrait)
	//beno
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		xeno.playsound_local(xeno, 'sound/voice/alien/hiss1.ogg', 10, 1)
		xeno.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>HIVEMIND</u></span><br>" + "[src] is being activated, deactivate it!", /atom/movable/screen/text/screen_text/picture/potrait/queen_mother)

///When timer ends add a point to the point pool in sensor capture, increase game timer, and send an alert
/obj/structure/sensor_tower_infestation/proc/finish_activation()
	if(!current_timer)
		return
	if(activated)
		return

	current_timer = null
	activated = TRUE
	update_icon()

	START_PROCESSING(SSobj, src)

	var/datum/game_mode/infestation/distress/points_defence/mode = SSticker.mode
	mode.sensors_activated += 1

	playsound(src, 'sound/machines/ping.ogg', 25, 1)
	balloon_alert_to_viewers("[src] has finished activation!")

	//marines
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.playsound_local(human, 'sound/effects/CIC_order.ogg', 10, 1)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] is fully activated!", /atom/movable/screen/text/screen_text/picture/potrait)
	//beno
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		xeno.playsound_local(xeno, 'sound/voice/alien/hiss1.ogg', 10, 1)
		xeno.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>HIVEMIND</u></span><br>" + "[src] is fully activated, stop further towers from being activated!", /atom/movable/screen/text/screen_text/picture/potrait/queen_mother)

///Stops timer if activating and sends an alert
/obj/structure/sensor_tower_infestation/proc/deactivate()
	if(activated)
		STOP_PROCESSING(SSobj, src)
		var/datum/game_mode/infestation/distress/points_defence/mode = SSticker.mode
		mode.sensors_activated -= 1
	activated = FALSE
	current_timer = null

	update_icon()

	//marines
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.playsound_local(human, 'sound/effects/CIC_order.ogg', 10, 1)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + "[src] has been deactivated", /atom/movable/screen/text/screen_text/picture/potrait)
	//beno
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		xeno.playsound_local(xeno, 'sound/voice/alien/hiss1.ogg', 10, 1)
		xeno.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>HIVEMIND</u></span><br>" + "[src] has been deactivated! Get ready to defend it hive", /atom/movable/screen/text/screen_text/picture/potrait/queen_mother)

/obj/structure/sensor_tower_infestation/update_icon()
	. = ..()
	update_control_minimap_icon()

///Update minimap icon of tower if its deactivated, activated , and fully activated
/obj/structure/sensor_tower_infestation/proc/update_control_minimap_icon()
	SSminimaps.remove_marker(src)
	if(activated)
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "beacon_marines", MINIMAP_BLIPS_LAYER))
	else
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "beacon[current_timer ? "_capture" : "_xeno"]", MINIMAP_BLIPS_LAYER))

/obj/structure/sensor_tower_infestation/process()
	if(add_tick < required_ticks)
		add_tick += 1
		return
	SSpoints.supply_points[FACTION_TERRAGOV] += points_income
	SSpoints.dropship_points += dropship_bonus
	GLOB.round_statistics.points_from_towers += points_income
	do_sparks(5, TRUE, src)
	say("Scientific data has been sold for [points_income] points.")
	add_tick = 0
