#define TURRET_HEALTH_REGEN 8

/obj/structure/xeno/turret
	name = "acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	icon = 'icons/Xeno/acid_turret.dmi'
	icon_state = "acid_turret"
	base_icon_state = "acid_turret"
	obj_integrity = 600
	max_integrity = 1500
	layer = ABOVE_MOB_LAYER
	density = TRUE
	resistance_flags = UNACIDABLE|DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	allow_pass_flags = PASS_AIR|PASS_THROW
	///What kind of spit it uses
	var/datum/ammo/ammo = /datum/ammo/xeno/acid/heavy/turret
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/atom/hostile
	///Last target of the turret
	var/atom/last_hostile
	///Potential list of targets found by scan
	var/list/atom/potential_hostiles = list()
	///Fire rate of the target in ticks
	var/firerate = 0.5 SECONDS
	///light color that gets set in initialize
	var/light_initial_color = LIGHT_COLOR_GREEN
	///For minimap icon change if sentry is firing
	var/firing

///Change minimap icon if its firing or not firing
/obj/structure/xeno/turret/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "xeno_turret[firing ? "_firing" : "_passive"]"), MINIMAP_BLIPS_LAYER)

/obj/structure/xeno/turret/Initialize(mapload, _hivenumber)
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	LAZYADDASSOC(GLOB.xeno_resin_turrets_by_hive, hivenumber, src)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, PROC_REF(shoot))
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(destroy_on_hijack))
	if(light_initial_color)
		set_light(2, 2, light_initial_color)
	update_minimap_icon()
	update_icon()

///Signal handler to delete the turret when the alamo is hijacked
/obj/structure/xeno/turret/proc/destroy_on_hijack()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/turret/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if(damage_amount) //Spawn effects only if we actually get destroyed by damage
		on_destruction()
		playsound(loc,'sound/effects/alien/turret_death.ogg', 70)
	return ..()

/obj/structure/xeno/turret/proc/on_destruction()
	var/datum/effect_system/smoke_spread/xeno/smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
	smoke.set_up(1, get_turf(src))
	smoke.start()

/obj/structure/xeno/turret/Destroy()
	GLOB.xeno_resin_turrets_by_hive[hivenumber] -= src
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/xeno/turret/ex_act(severity)
	take_damage(severity * 5, BRUTE, BOMB)

/obj/structure/xeno/turret/fire_act(burn_level, flame_color)
	take_damage(burn_level * 2, BURN, FIRE)
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/turret/update_overlays()
	. = ..()
	if(obj_integrity <= max_integrity * 0.5)
		. += image(icon, src, "[base_icon_state]_damage")
	if(CHECK_BITFIELD(resistance_flags, ON_FIRE))
		. += image(icon, src, "turret_on_fire")

/obj/structure/xeno/turret/process()
	//Turrets regen some HP, every 2 sec
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + TURRET_HEALTH_REGEN, max_integrity)
		update_icon()
		DISABLE_BITFIELD(resistance_flags, ON_FIRE)
	if(!scan())
		return
	set_hostile(get_target())
	if(!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		GLOB.hive_datums[hivenumber].xeno_message("Our [name] is attacking a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien/help1.ogg', FALSE, null, /atom/movable/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/structure/xeno/turret/attackby(obj/item/I, mob/living/user, params)
	if(I.item_flags & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage, I.damtype, MELEE)
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)

///Signal handler for hard del of hostile
/obj/structure/xeno/turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Setter for hostile with hard del in mind
/obj/structure/xeno/turret/proc/set_hostile(_hostile)
	if(hostile == _hostile)
		return
	hostile = _hostile
	RegisterSignal(hostile, COMSIG_QDELETING, PROC_REF(unset_hostile))

///Setter for last_hostile with hard del in mind
/obj/structure/xeno/turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/xeno/turret/proc/get_target()
	for(var/atom/nearby_hostile AS in potential_hostiles)
		if(check_path(get_step_towards(src, nearby_hostile), nearby_hostile, PASS_PROJECTILE) != get_turf(nearby_hostile)) //xeno turret seems to not care about actual sight, for whatever reason
			continue
		. = nearby_hostile

///Checks the nearby mobs for eligability. If they can be targets it stores them in potential_targets. Returns TRUE if there are targets, FALSE if not.
/obj/structure/xeno/turret/proc/scan()
	potential_hostiles.Cut()
	for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, range))
		if(nearby_human.stat == DEAD)
			continue
		if(nearby_human.get_xeno_hivenumber() == hivenumber)
			continue
		if(HAS_TRAIT(nearby_human, TRAIT_STEALTH))
			continue
		potential_hostiles += nearby_human
	for(var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(GLOB.hive_datums[hivenumber] == nearby_xeno.hive)
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		if(HAS_TRAIT(nearby_xeno, TRAIT_STEALTH))
			continue
		potential_hostiles += nearby_xeno
	for(var/obj/vehicle/unmanned/nearby_unmanned_vehicle AS in cheap_get_unmanned_vehicles_near(src, range))
		potential_hostiles += nearby_unmanned_vehicle
	for(var/obj/vehicle/sealed/mecha/nearby_mech AS in cheap_get_mechs_near(src, range))
		var/list/driver_list = nearby_mech.return_drivers()
		if(!length(driver_list))
			continue
		var/mob/living/carbon/human/human_occupant = driver_list[1]
		if(human_occupant.get_xeno_hivenumber() == hivenumber) // what if zombie rides a mech?
			continue
		potential_hostiles += nearby_mech
	for(var/obj/vehicle/sealed/armored/nearby_tank AS in cheap_get_tanks_near(src, range))
		var/list/driver_list = nearby_tank.return_drivers()
		if(!length(driver_list))
			continue
		var/mob/living/carbon/human/human_occupant = driver_list[1]
		if(human_occupant.get_xeno_hivenumber() == hivenumber)
			continue
		potential_hostiles += nearby_tank
	return potential_hostiles

///Signal handler to make the turret shoot at its target
/obj/structure/xeno/turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		firing = FALSE
		update_minimap_icon()
		return
	face_atom(hostile)
	var/atom/movable/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, null, src, ammo.max_range, ammo.shell_speed)
	firing = TRUE
	update_minimap_icon()

/obj/structure/xeno/turret/sticky
	name = "Sticky resin turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires resin against intruders."
	icon_state = "resin_turret"
	base_icon_state = "resin_turret"
	light_initial_color = LIGHT_COLOR_PURPLE
	ammo = /datum/ammo/xeno/sticky/turret

/obj/structure/xeno/turret/sticky/on_destruction()
	for(var/i in 1 to 20) // maybe a bit laggy
		var/atom/movable/projectile/new_proj = new(src)
		new_proj.generate_bullet(ammo)
		new_proj.fire_at(null, null, src, range = rand(1, 4), angle = rand(1, 360), recursivity = TRUE)

/obj/structure/xeno/turret/facehugger
	name = "hugger turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires huggers against intruders."
	icon_state = "hugger_turret"
	base_icon_state = "hugger_turret"
	obj_integrity = 400
	max_integrity = 400
	light_initial_color = LIGHT_COLOR_BROWN
	ammo = /datum/ammo/xeno/hugger
	firerate = 5 SECONDS

/obj/structure/xeno/turret/facehugger/shoot()
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		firing = FALSE
		update_minimap_icon()
		return
	face_atom(hostile)
	var/atom/movable/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, null, src, ammo.max_range, ammo.shell_speed)
	var/datum/ammo/xeno/hugger/hugger_ammo = ammo
	newshot.color = initial(hugger_ammo.hugger_type.color)
	hugger_ammo.hivenumber = hivenumber
	firing = TRUE
	update_minimap_icon()

/obj/structure/xeno/turret/facehugger/on_destruction()
	for(var/i in 1 to 5)
		var/atom/movable/projectile/new_proj = new(src)
		new_proj.generate_bullet(ammo)
		new_proj.fire_at(null, src, src, range = rand(1, 3), angle = rand(1, 360), recursivity = TRUE)

/obj/structure/xeno/turret/facehugger/attack_ghost(mob/dead/observer/user)
	. = ..()

	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(!hive.can_spawn_as_hugger(user))
		return FALSE

	var/mob/living/carbon/xenomorph/facehugger/new_hugger = new(get_turf(src))
	new_hugger.transfer_to_hive(hivenumber)
	new_hugger.transfer_mob(user)
	return TRUE

#undef TURRET_HEALTH_REGEN
