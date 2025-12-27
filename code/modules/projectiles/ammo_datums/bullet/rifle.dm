/datum/ammo/bullet/rifle
	name = "rifle bullet"
	hud_state = "rifle"
	hud_state_empty = "rifle_empty"
	accurate_range = 12
	damage = 25
	penetration = 5
	additional_xeno_penetration = 10
	matter_cost = 4

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"
	hud_state = "rifle_ap"
	damage = 20
	penetration = 25
	additional_xeno_penetration = 25
	matter_cost = 0

/datum/ammo/bullet/rifle/t25
	name = "smartmachinegun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	accurate_range = 20
	damage = 20
	penetration = 15
	additional_xeno_penetration = 20
	matter_cost = 0

/datum/ammo/bullet/rifle/hv
	name = "high-velocity rifle bullet"
	hud_state = "hivelo"
	damage = 20
	penetration = 20
	additional_xeno_penetration = 10
	matter_cost = 3

/datum/ammo/bullet/rifle/heavy
	name = "heavy rifle bullet"
	hud_state = "rifle_heavy"
	damage = 30
	penetration = 10
	additional_xeno_penetration = 15
	matter_cost = 5

/datum/ammo/bullet/rifle/repeater
	name = "heavy impact rifle bullet"
	hud_state = "sniper"
	damage = 70
	penetration = 20
	additional_xeno_penetration = 2.5
	matter_cost = 8

/datum/ammo/bullet/rifle/repeater/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 3, slowdown = 2, stagger = 1 SECONDS)

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	hud_state = "rifle_fire"
	damage_type = BURN
	shrapnel_chance = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	accuracy = -10
	matter_cost = 0

/datum/ammo/bullet/rifle/machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 20
	penetration = 10
	additional_xeno_penetration = 12.5
	matter_cost = 3

/datum/ammo/bullet/rifle/som_machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 25
	penetration = 12.5
	additional_xeno_penetration = 12.5
	matter_cost = 0

/datum/ammo/bullet/rifle/som_machinegun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 20, slowdown = 0.5)

/datum/ammo/bullet/rifle/som_big
	name = "heavy rifle bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0.5
	accurate_range = 18
	max_range = 30
	damage = 65
	penetration = 20
	sundering = 2
	matter_cost = 0

/datum/ammo/bullet/rifle/som_big/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 9, slowdown = 0.75)

/datum/ammo/bullet/rifle/som_big/incendiary
	name = "heavy incendiary bullet"
	hud_state = "hivelo_fire"
	damage = 40
	penetration = 10
	sundering = 1
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	bullet_color = LIGHT_COLOR_FIRE
	matter_cost = 0

/datum/ammo/bullet/rifle/som_big/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/rifle/som_big/anti_armour
	name = "heavy AT bullet"
	hud_state = "hivelo_impact"
	damage = 40
	penetration = 45
	sundering = 8
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOVABLE
	bullet_color = LIGHT_COLOR_BLUE
	on_pierce_multiplier = 0.8
	matter_cost = 0

/datum/ammo/bullet/rifle/som_big/anti_armour/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 9, slowdown = 1, stagger = 0.5 SECONDS)
	proj.proj_max_range = 0

/datum/ammo/bullet/rifle/som_big/anti_armour/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(!isvehicle(target_obj))
		proj.proj_max_range -= 20 //can shoot through 1 piece of cover
		return
	proj.damage *= 2
	proj.proj_max_range = 0

/datum/ammo/bullet/rifle/tx8
	name = "A19 high velocity bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	accurate_range = 15
	damage = 35
	penetration = 20
	additional_xeno_penetration = 40
	bullet_color = COLOR_SOFT_RED
	matter_cost = 0

/datum/ammo/bullet/rifle/tx8/incendiary
	name = "high velocity incendiary bullet"
	hud_state = "hivelo_fire"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_PASS_THROUGH_MOB|AMMO_IFF
	damage = 25
	penetration = 20
	additional_xeno_penetration = 15
	bullet_color = LIGHT_COLOR_FIRE
	matter_cost = 0

/datum/ammo/bullet/rifle/tx8/impact
	name = "high velocity impact bullet"
	hud_state = "hivelo_impact"
	damage = 30
	penetration = 10
	additional_xeno_penetration = 45
	matter_cost = 0

/datum/ammo/bullet/rifle/tx8/impact/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 14, slowdown = 1, knockback = 1)

/datum/ammo/bullet/rifle/mpi_km
	name = "crude heavy rifle bullet"
	hud_state = "rifle_crude"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 30
	penetration = 15
	additional_xeno_penetration = 12.5
	matter_cost = 4

/datum/ammo/bullet/rifle/type16
	name = "crude rifle bullet"
	hud_state = "rifle_crude"
	damage = 30
	penetration = 10
	additional_xeno_penetration = 15
	matter_cost = 5

/datum/ammo/bullet/rifle/dmr37
	name = "marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0.5
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 25
	accurate_range_min = 6
	max_range = 40
	damage = 60
	penetration = 15
	additional_xeno_penetration = 10
	matter_cost = 6

/datum/ammo/bullet/rifle/garand
	name = "heavy marksman bullet"
	hud_state = "sniper"
	damage = 70
	penetration = 25
	additional_xeno_penetration = 5
	matter_cost = 0

/datum/ammo/bullet/rifle/br64
	name = "light marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	penetration = 15
	damage = 30
	additional_xeno_penetration = 10
	matter_cost = 0

/datum/ammo/bullet/rifle/icc_confrontationrifle
	name = "armor-piercing heavy rifle bullet"
	hud_state = "rifle_ap"
	damage = 50
	penetration = 40
	additional_xeno_penetration = 12.5
	matter_cost = 0

/datum/ammo/bullet/sg62
	name = "smart marksman bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	damage = 40
	max_range = 40
	penetration = 17.5
	additional_xeno_penetration = 12.5
	shell_speed = 4
	damage_falloff = 0.5
	accurate_range = 25
	accurate_range_min = 3
	matter_cost = 0

/datum/ammo/bullet/sg153
	name = "smart spotting bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "spotrifle"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	damage = 50
	penetration = 25
	sundering = 5
	shell_speed = 4
	accurate_range = 12
	max_range = 12
	matter_cost = 0

/datum/ammo/bullet/sg153/highimpact
	name = "smart high-impact spotting bullet"
	hud_state = "spotrifle_impact"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/sg153/highimpact/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 1 SECONDS, slowdown = 1, max_range = 12)

/datum/ammo/bullet/sg153/heavyrubber
	name = "smart heavy-rubber spotting bullet"
	hud_state = "spotrifle_rubber"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/sg153/heavyrubber/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 3, max_range = 12)

/datum/ammo/bullet/sg153/plasmaloss
	name = "smart tanglefoot spotting bullet"
	hud_state = "spotrifle_plasmaloss"
	damage = 10
	sundering = 0.5
	matter_cost = 0
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/bullet/sg153/plasmaloss/on_hit_mob(mob/living/victim, atom/movable/projectile/proj)
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/X = victim
		X.use_plasma(20 + 0.2 * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit) // This is draining 20%+20 flat per hit.
	var/datum/effect_system/smoke_spread/plasmaloss/S = new
	S.set_up(0, victim, 3)
	S.start()

/datum/ammo/bullet/sg153/plasmaloss/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_object)
	drop_tg_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bullet/sg153/plasmaloss/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_tg_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bullet/sg153/plasmaloss/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_tg_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bullet/sg153/plasmaloss/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/plasmaloss()

/datum/ammo/bullet/sg153/plasmaloss/proc/drop_tg_smoke(turf/target_turf)
	if(target_turf.density)
		return

	set_smoke()
	smoke_system.set_up(0, target_turf, 3)
	smoke_system.start()
	smoke_system = null

/datum/ammo/bullet/sg153/tungsten
	name = "smart tungsten spotting bullet"
	hud_state = "spotrifle_tungsten"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/sg153/tungsten/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 0.5 SECONDS, knockback = 1, max_range = 12)

/datum/ammo/bullet/sg153/flak
	name = "smart flak spotting bullet"
	hud_state = "spotrifle_flak"
	damage = 60
	sundering = 0.5
	airburst_multiplier = 0.5

/datum/ammo/bullet/sg153/flak/on_hit_mob(mob/victim, atom/movable/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/sg153/incendiary
	name = "smart incendiary spotting  bullet"
	hud_state = "spotrifle_incend"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_IFF
	damage_type = BURN
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/railgun
	name = "armor piercing railgun slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 20
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85
	matter_cost = 0

/datum/ammo/bullet/railgun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 4 SECONDS, slowdown = 2, knockback = 2)

/datum/ammo/bullet/railgun/hvap
	name = "high velocity railgun slug"
	hud_state = "railgun_hvap"
	shell_speed = 5
	max_range = 21
	damage = 100
	penetration = 30
	sundering = 50
	matter_cost = 0

/datum/ammo/bullet/railgun/hvap/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, knockback = 3)

/datum/ammo/bullet/railgun/smart
	name = "smart armor piercing railgun slug"
	hud_state = "railgun_smart"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE|AMMO_IFF
	damage = 100
	penetration = 20
	sundering = 20
	matter_cost = 0

/datum/ammo/bullet/railgun/smart/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 3 SECONDS, slowdown = 3)

/datum/ammo/bullet/coilgun
	name = "high-velocity tungsten slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 5
	max_range = 31
	damage = 70
	penetration = 35
	sundering = 5
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85
	matter_cost = 0

/datum/ammo/bullet/coilgun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 0.2 SECONDS, slowdown = 1, knockback = 3)
