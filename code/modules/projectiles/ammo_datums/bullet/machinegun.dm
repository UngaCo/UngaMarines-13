/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state = "bullet" // Keeping it bog standard with the turret but allows it to be changed.
	ammo_behavior_flags = AMMO_BALLISTIC
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	accurate_range = 12
	damage = 40 //Reduced damage due to vastly increased mobility
	penetration = 40 //Reduced penetration due to vastly increased mobility
	accuracy = 5
	barricade_clear_distance = 2
	sundering = 5

/datum/ammo/bullet/machinegun/smart
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accuracy_var_low = 3
	accuracy_var_high = 3
	accurate_range = 5
	damage = 25
	penetration = 15
	shrapnel_chance = 25
	sundering = 2.5

/datum/ammo/bullet/auto_cannon
	name = "autocannon high-velocity bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE|AMMO_IFF
	accurate_range_min = 6
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 30
	penetration = 50
	sundering = 1
	max_range = 35
	///Bonus flat damage to walls, balanced around resin walls.
	var/autocannon_wall_bonus = 20

/datum/ammo/bullet/auto_cannon/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 20

	if(istype(target_turf, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = target_turf
		wall_victim.take_damage(autocannon_wall_bonus, proj.damtype, proj.armor_type)

/datum/ammo/bullet/auto_cannon/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	proj.proj_max_range -= 5
	staggerstun(target_mob, proj, max_range = 20, slowdown = 1)

/datum/ammo/bullet/auto_cannon/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/bullet/auto_cannon/flak
	name = "autocannon smart-detonating bullet"
	hud_state = "sniper_flak"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_TARGET_TURF
	damage = 50
	penetration = 30
	sundering = 5
	max_range = 30
	airburst_multiplier = 1
	autocannon_wall_bonus = 5

/datum/ammo/bullet/auto_cannon/flak/on_hit_mob(mob/victim, atom/movable/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/auto_cannon/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	airburst(target_turf, proj)

/datum/ammo/bullet/smart_minigun
	name = "smartminigun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun_minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	accurate_range = 12
	damage = 12
	penetration = 20
	damage_falloff = 0.1
	var/shatter_duration = 3 SECONDS

/datum/ammo/bullet/smart_minigun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!isliving(target_mob))
		return

	var/mob/living/living_victim = target_mob
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)
