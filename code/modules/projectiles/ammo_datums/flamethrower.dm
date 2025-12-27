/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	hud_state = "flame"
	hud_state_empty = "flame_empty"
	damage_type = BURN
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_FLAME|AMMO_TARGET_TURF
	armor_type = FIRE
	max_range = 7
	damage = 31
	damage_falloff = 0
	incendiary_strength = 30 //Firestacks cap at 20, but that's after armor.
	bullet_color = LIGHT_COLOR_FIRE
	var/fire_color = FLAME_COLOR_RED
	var/burn_time = 17
	var/burn_level = 31

/datum/ammo/flamethrower/drop_flame(turf/target_turf)
	if(!istype(target_turf))
		return
	target_turf.ignite(burn_time, burn_level, fire_color)

/datum/ammo/flamethrower/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_flame(get_turf(target_mob))

/datum/ammo/flamethrower/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_flame(get_turf(target_object))

/datum/ammo/flamethrower/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/flamethrower/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/flamethrower/tank_flamer/drop_flame(turf/target_turf)
	if(!istype(target_turf))
		return
	flame_radius(2, target_turf)

/datum/ammo/flamethrower/blue
	name = "blue flame"
	hud_state = "flame_blue"
	max_range = 7
	fire_color = FLAME_COLOR_BLUE
	burn_time = 40
	burn_level = 46
	bullet_color = COLOR_NAVY

/datum/ammo/flamethrower/green
	name = "green flame"
	hud_state = "flame_green"
	max_range = 8
	fire_color = FLAME_COLOR_LIME
	burn_time = 12
	burn_level = 18
	bullet_color = LIGHT_COLOR_ELECTRIC_GREEN

/datum/ammo/water
	name = "water"
	icon_state = "pulse1"
	hud_state = "water"
	hud_state_empty = "water_empty"
	damage = 0
	shell_speed = 1
	damage_type = BURN
	ammo_behavior_flags = AMMO_TARGET_TURF
	bullet_color = null

/datum/ammo/water/proc/splash(turf/extinguished_turf, splash_direction)
	for(var/atom/relevant_atom AS in extinguished_turf)
		if(isfire(relevant_atom))
			qdel(relevant_atom)
			continue
		if(isliving(relevant_atom))
			var/mob/living/caught_mob = relevant_atom
			caught_mob.ExtinguishMob()
	new /obj/effect/temp_visual/dir_setting/water_splash(extinguished_turf, splash_direction)

/datum/ammo/water/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	splash(get_turf(target_mob), proj.dir)

/datum/ammo/water/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	splash(get_turf(target_object), proj.dir)

/datum/ammo/water/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	splash(get_turf(target_turf), proj.dir)

/datum/ammo/water/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	splash(get_turf(target_turf), proj.dir)
