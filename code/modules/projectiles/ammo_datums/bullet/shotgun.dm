/datum/ammo/bullet/shotgun
	hud_state_empty = "shotgun_empty"
	shell_speed = 2
	handful_amount = 5

/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 3
	max_range = 15
	damage = 85
	penetration = 20
	additional_xeno_penetration = 20

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, knockback = 1, slowdown = 2)

/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	handful_icon_state = "beanbag slug"
	icon_state = "beanbag"
	hud_state = "shotgun_beanbag"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 15
	max_range = 15
	shrapnel_chance = 0
	accuracy = 5

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 4 SECONDS, knockback = 1, slowdown = 2, hard_size_threshold = 1)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	handful_icon_state = "incendiary slug"
	hud_state = "shotgun_fire"
	damage_type = BRUTE
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	max_range = 10
	damage = 100
	penetration = 15
	bullet_color = COLOR_TAN_ORANGE

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 1 SECONDS, knockback = 1, slowdown = 1)

/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/flechette/flechette_spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 3
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 45
	damage_falloff = 0.5
	penetration = 15
	additional_xeno_penetration = 20
	///shatter effection duration when hitting mobs
	var/shatter_duration = 8 SECONDS

/datum/ammo/bullet/shotgun/flechette/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!isliving(target_mob))
		return

	var/mob/living/living_victim = target_mob
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

/datum/ammo/bullet/shotgun/flechette/flechette_spread
	name = "additional flechette"
	damage = 35
	additional_xeno_penetration = 30

/datum/ammo/bullet/shotgun/flechette/flechette_spread/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread
	bonus_projectiles_amount = 5
	bonus_projectiles_scatter = 4
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
	damage_falloff = 4

/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, knockback = 2, slowdown = 0.5, max_range = 3)

/datum/ammo/bullet/hefa_buckshot
	name = "hefa fragment"
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	shrapnel_chance = 15
	damage = 30
	damage_falloff = 3

/datum/ammo/bullet/hefa_buckshot/on_hit_mob(mob/mob_hit, atom/movable/projectile/projectile)
	staggerstun(mob_hit, projectile, knockback = 2, max_range = 4)

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
	damage_falloff = 4

/datum/ammo/bullet/shotgun/frag
	name = "shotgun explosive shell"
	handful_icon_state = "shotgun tracker shell"
	hud_state = "shotgun_tracker"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/frag/frag_spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 6
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 10
	damage_falloff = 0.5
	penetration = 0

/datum/ammo/bullet/shotgun/frag/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 15, 10)

/datum/ammo/bullet/shotgun/frag/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/bullet/shotgun/frag/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_nade(target_object.density ? get_step_towards(target_object, proj) : target_object)

/datum/ammo/bullet/shotgun/frag/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/bullet/shotgun/frag/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/bullet/shotgun/frag/frag_spread
	name = "additional frag shell"
	damage = 5

/datum/ammo/bullet/shotgun/sx16_buckshot
	name = "shotgun buckshot shell" //16 gauge is between 12 and 410 bore.
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/sx16_buckshot/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 10
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 25
	damage_falloff = 4

/datum/ammo/bullet/shotgun/sx16_buckshot/spread
	name = "additional buckshot"

/datum/ammo/bullet/shotgun/heavy_buckshot
	name = "heavy buckshot shell"
	handful_icon_state = "heavy_shotgun_buckshot"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/heavy_spread
	bonus_projectiles_amount = 5
	bonus_projectiles_scatter = 4
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 50
	damage_falloff = 4

/datum/ammo/bullet/shotgun/heavy_buckshot/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, knockback = 2, slowdown = 0.5, max_range = 3)

/datum/ammo/bullet/shotgun/barrikada_slug
	name = "heavy metal slug"
	handful_icon_state = "heavy_shotgun_barrikada"
	hud_state = "shotgun_slug"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 4
	max_range = 15
	damage = 125
	penetration = 50
	sundering = 15

/datum/ammo/bullet/shotgun/barrikada/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 2, stagger = 3 SECONDS, knockback = 2)

/datum/ammo/bullet/shotgun/heavy_spread
	name = "additional buckshot"
	icon_state = "buckshot"
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 50
	damage_falloff = 4

/datum/ammo/bullet/shotgun/sx16_flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/sx16_flechette/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 8
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 15
	damage = 15
	damage_falloff = 0.5
	penetration = 15

/datum/ammo/bullet/shotgun/sx16_flechette/spread
	name = "additional flechette"

/datum/ammo/bullet/shotgun/sx16_slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	shell_speed = 3
	max_range = 15
	damage = 40
	penetration = 20
	matter_cost = 10

/datum/ammo/bullet/shotgun/sx16_slug/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 1, knockback = 1)

/datum/ammo/bullet/shotgun/sh15_flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/sh15_flechette/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 2
	max_range = 15
	damage = 19
	damage_falloff = 0.25
	penetration = 17
	additional_xeno_penetration = 20
	matter_cost = 10

/datum/ammo/bullet/shotgun/sh15_flechette/spread
	name = "additional flechette"

/datum/ammo/bullet/shotgun/sh15_slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 3
	max_range = 15
	damage = 60
	penetration = 30
	additional_xeno_penetration = 5

/datum/ammo/bullet/shotgun/sh15_slug/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 2, knockback = 1)

/datum/ammo/bullet/shotgun/mbx900_buckshot
	name = "light shotgun buckshot shell" // If .410 is the smallest shotgun shell, then...
	handful_icon_state = "light shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/mbx900_buckshot/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 10
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 50
	damage_falloff = 1

/datum/ammo/bullet/shotgun/mbx900_buckshot/spread
	name = "additional buckshot"
	damage = 40

/datum/ammo/bullet/shotgun/mbx900_sabot
	name = "light shotgun sabot shell"
	handful_icon_state = "light shotgun sabot shell"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_sabot"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 5
	max_range = 30
	damage = 50
	penetration = 40
	additional_xeno_penetration = 2.5

/datum/ammo/bullet/shotgun/mbx900_tracker
	name = "light shotgun tracker round"
	handful_icon_state = "light shotgun tracker round"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_tracker"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/mbx900_tracker/on_hit_mob(mob/living/victim, atom/movable/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)

/datum/ammo/bullet/shotgun/tracker
	name = "shotgun tracker shell"
	handful_icon_state = "shotgun tracker shell"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_tracker"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/tracker/on_hit_mob(mob/living/victim, atom/movable/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)

//I INSERT THE SHELLS IN AN UNKNOWN ORDER
/datum/ammo/bullet/shotgun/blank
	name = "shotgun blank shell"
	handful_icon_state = "shotgun blank shell"
	icon_state = "shotgun_blank"
	hud_state = "shotgun_buckshot" // don't fix this: this is so you can do buckshot roulette
	shell_speed = 0
	max_range = -1
	damage = 0

// Проки для SH46
/datum/ammo/bullet/shotgun/buckshot/shq6/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1, slowdown = 1, max_range = 3)

/datum/ammo/bullet/shotgun/slug/shq6/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 2, max_range = 5)

/datum/ammo/bullet/shotgun/incendiary/shq6/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1)

/datum/ammo/bullet/shotgun/flechette/shq6/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!isliving(target_mob))
		return

	var/mob/living/living_victim = target_mob
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, 3 SECONDS)
