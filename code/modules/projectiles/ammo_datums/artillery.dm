/datum/ammo/mortar
	name = "80mm shell"
	icon_state = "mortar"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 0.75
	damage = 0
	penetration = 0
	sundering = 0
	accuracy = 1000
	max_range = 1000
	ping = null
	bullet_color = COLOR_VERY_SOFT_YELLOW

/datum/ammo/mortar/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 90, 30)

/datum/ammo/mortar/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf)

/datum/ammo/mortar/incend/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 45, 20)
	flame_radius(4, target_turf)
	playsound(target_turf, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/knee
	name = "50mm shell"
	icon_state = "howi"
	shell_speed = 0.75

/datum/ammo/mortar/knee/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 80, 30)

/datum/ammo/mortar/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/smoke/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 15, 5)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, target_turf, 11)
	smoke.start()

/datum/ammo/mortar/smoke/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/flare/drop_nade(turf/target_turf)
	new /obj/effect/temp_visual/above_flare(target_turf)
	playsound(target_turf, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)

/datum/ammo/mortar/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/howi/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 200, 100)

/datum/ammo/mortar/howi/incend/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 45, 30)
	flame_radius(5, target_turf)
	playsound(target_turf, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/smoke/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/smoke/howi/wp
	smoketype = /datum/effect_system/smoke_spread/phosphorus

/datum/ammo/mortar/smoke/howi/wp/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 15, 15)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, target_turf, 7)
	smoke.start()
	flame_radius(4, target_turf)
	flame_radius(1, target_turf, burn_intensity = 75, burn_duration = 45, burn_damage = 15, fire_stacks = 75)

/datum/ammo/mortar/smoke/howi/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/smoke/howi/plasmaloss/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 75, 25)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, target_turf, 11)
	smoke.start()

/datum/ammo/mortar/rocket
	name = "rocket"
	icon_state = "rocket"
	shell_speed = 1.5

/datum/ammo/mortar/rocket/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 175, 75)

/datum/ammo/mortar/rocket/incend/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 50, 20)
	flame_radius(6, target_turf)
	playsound(target_turf, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/rocket/minelayer/drop_nade(turf/target_turf)
	var/obj/item/explosive/mine/mine = new /obj/item/explosive/mine(target_turf)
	mine.deploy_mine(null, TGMC_LOYALIST_IFF)

/datum/ammo/mortar/rocket/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/rocket/smoke/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 15, 15)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, target_turf, 11)
	smoke.start()

/datum/ammo/mortar/rocket/mlrs
	shell_speed = 3

/datum/ammo/mortar/rocket/mlrs/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 70, 25)

/datum/ammo/mortar/rocket/smoke/mlrs
	shell_speed = 3
	smoketype = /datum/effect_system/smoke_spread/mustard

/datum/ammo/mortar/rocket/smoke/mlrs/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 30, 15)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(5, target_turf, 6)
	flame_radius(4, target_turf)
	smoke.start()

/datum/ammo/mortar/rocket/smoke/mlrs/tangle
	shell_speed = 3
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/rocket/smoke/mlrs/tangle/drop_nade(turf/target_turf)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	cell_explosion(target_turf, 10, 2)
	playsound(target_turf, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(5, target_turf, 6)
	smoke.start()

/datum/ammo/bullet/atgun_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 15
	accuracy_var_high = 5
	max_range = 6
	damage = 30
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/atgun_spread/incendiary
	name = "incendiary flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 20
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/atgun_spread/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/atgun_spread/incendiary/drop_flame(turf/target_turf)
	if(!istype(target_turf))
		return
	target_turf.ignite(5, 10)

/datum/ammo/bullet/atgun_spread/incendiary/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(target_turf)

/datum/ammo/ags_shrapnel
	name = "fragmentation grenade"
	icon_state = "grenade_projectile"
	hud_state = "grenade_frag"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	ping = null //no bounce off.
	sound_bounce = SFX_ROCKET_BOUNCE
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_IFF
	armor_type = BOMB
	damage_falloff = 0.5
	shell_speed = 2
	accurate_range = 12
	max_range = 21
	damage = 15
	shrapnel_chance = 0
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread
	bonus_projectiles_scatter = 20
	var/bonus_projectile_quantity = 15

/datum/ammo/ags_shrapnel/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_mob, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/ags_shrapnel/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	var/turf/det_turf = get_turf(target_object)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_object), loc_override = det_turf)

/datum/ammo/ags_shrapnel/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_turf(target_turf)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/ags_shrapnel/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_turf(target_turf)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/ags_shrapnel/incendiary
	name = "white phosphorous grenade"
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread/incendiary

/datum/ammo/bullet/ags_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 15
	accuracy_var_high = 5
	max_range = 4
	damage = 30
	penetration = 20
	sundering = 1
	damage_falloff = 0

/datum/ammo/bullet/ags_spread/incendiary
	name = "White phosphorous shrapnel"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 20
	penetration = 10
	sundering = 1.5
	damage_falloff = 0

/datum/ammo/bullet/ags_spread/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_flame(get_turf(target_mob))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_flame(get_turf(target_object))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/bullet/ags_spread/incendiary/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/bullet/ags_spread/incendiary/drop_flame(turf/target_turf)
	if(!istype(target_turf))
		return
	target_turf.ignite(5, 10)

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade
	icon_state = "grenade"
	armor_type = BOMB
	damage = 15
	accuracy = 15
	max_range = 10

/datum/ammo/grenade_container/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(proj))

/datum/ammo/grenade_container/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_nade(target_object.density ? proj.loc : target_object.loc)

/datum/ammo/grenade_container/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? proj.loc : target_turf)

/datum/ammo/grenade_container/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? proj.loc : target_turf)

/datum/ammo/grenade_container/drop_nade(turf/target_turf)
	var/obj/item/explosive/grenade/G = new nade_type(target_turf)
	G.visible_message(span_warning("\A [G] lands on [target_turf]!"))
	G.det_time = 10
	G.activate()

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"

/datum/ammo/grenade_container/agls37
	name = "grenade shell"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_IFF
	icon_state = "grenade_projectile"
	hud_state = "grenade_he"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	max_range = 21
	nade_type = /obj/item/explosive/grenade/agls

/datum/ammo/grenade_container/agls37/flare
	hud_state = "grenade_dummy"
	nade_type = /obj/item/explosive/grenade/flare

/datum/ammo/grenade_container/agls37/cloak
	hud_state = "grenade_hide"
	nade_type = /obj/item/explosive/grenade/smokebomb/cloak/agls

/datum/ammo/grenade_container/agls37/tanglefoot
	hud_state = "grenade_drain"
	nade_type = /obj/item/explosive/grenade/smokebomb/drain/agls
