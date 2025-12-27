/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	ammo_behavior_flags = AMMO_SNIPER
	accurate_range = 15
	max_range = 40
	penetration = 50
	damage = 80
	hud_state = "bigshell_he"
	barricade_clear_distance = 4

/datum/ammo/rocket/ltb/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 320, 70)

/datum/ammo/rocket/ltb/heavy/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 450, 90)

/datum/ammo/bullet/tank_apfds
	name = "8.8cm APFDS round"
	icon_state = "apfds"
	hud_state = "bigshell_apfds"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 300
	penetration = 75
	shell_speed = 4
	accurate_range = 24
	max_range = 30
	on_pierce_multiplier = 0.85
	barricade_clear_distance = 4

/datum/ammo/bullet/tank_apfds/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 10

/datum/ammo/bullet/tank_apfds/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	proj.proj_max_range -= 2
	if(ishuman(target_mob) && !(target_mob.status_flags & GODMODE) &&  prob(35))
		target_mob.gib()

/datum/ammo/bullet/tank_apfds/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	if(!isvehicle(target_object) && !ishitbox(target_object))
		proj.proj_max_range -= 5
		return
	proj.proj_max_range = 0 //we don't penetrate past a vehicle
	proj.damage *= 2.2

/datum/ammo/rocket/homing
	name = "homing HE rocket"
	damage = 0
	penetration = 0
	max_range = 20
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_SPECIAL_PROCESS
	shell_speed = 0.3
	///If the projectile is pointing at the target with a variance of this number, we don't readjust the angle
	var/angle_precision = 5
	///Number in degrees that the projectile will change during each process
	var/turn_rate = 5

/datum/ammo/rocket/homing/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 165, 45)

/datum/ammo/rocket/homing/ammo_process(atom/movable/projectile/proj, damage)
	if(QDELETED(proj.original_target))
		return
	var/angle_to_target = Get_Angle(get_turf(proj), get_turf(proj.original_target)) //angle uses pixel offsets so we check turfs instead
	if((proj.dir_angle >= angle_to_target - angle_precision) && (proj.dir_angle <= angle_to_target + angle_precision))
		return
	proj.dir_angle = clamp(angle_to_target, proj.dir_angle - turn_rate, proj.dir_angle + turn_rate)
	proj.x_offset = round(sin(proj.dir_angle), 0.01)
	proj.y_offset = round(cos(proj.dir_angle), 0.01)
	var/matrix/rotate = matrix()
	rotate.Turn(proj.dir_angle)
	animate(proj, transform = rotate, time = SSprojectiles.wait)

/datum/ammo/rocket/homing/microrocket /// this is basically a tgmc version of the above
	name = "homing HE microrocket"
	shell_speed = 0.3
	damage = 75
	penetration = 40
	sundering = 10
	turn_rate = 10

/datum/ammo/rocket/homing/microrocket/drop_nade(turf/T)
	cell_explosion(T, 50, 15)

/datum/ammo/rocket/homing/tow
	name = "TOW-III missile"
	icon_state = "rocket_he"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_SPECIAL_PROCESS|AMMO_IFF
	shell_speed = 0.3
	turn_rate = 10
	damage = 60
	penetration = 30
	sundering = 10
	max_range = 30

/datum/ammo/rocket/homing/tow/drop_nade(turf/T)
	cell_explosion(T, 150, 50)

/datum/ammo/tx54/tank_cannister
	name = "cannister"
	icon_state = "cannister_shot"
	damage = 30
	penetration = 0
	ammo_behavior_flags = AMMO_SNIPER
	damage_falloff = 0.5
	max_range = 3
	projectile_greyscale_colors = "#4f0303"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/tank_cannister
	bonus_projectiles_scatter = 6
	bonus_projectile_quantity = 12

/datum/ammo/bullet/tx54_spread/tank_cannister
	name = "cannister shot"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	max_range = 7
	damage = 50
	penetration = 15
	sundering = 2
	damage_falloff = 1
	shrapnel_chance = 15

/datum/ammo/bullet/tx54_spread/tank_cannister/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 4, stagger = 2 SECONDS, slowdown = 0.2)

/datum/ammo/bullet/minigun/ltaap
	name = "chaingun bullet"
	damage = 30
	penetration = 10
	sundering = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF|AMMO_SNIPER
	damage_falloff = 2
	accurate_range = 7
	accuracy = 10
	barricade_clear_distance = 4

/datum/ammo/bullet/cupola
	name = "cupola bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	accurate_range = 12
	damage = 30
	penetration = 10
	sundering = 1

/datum/ammo/flamethrower/armored_spray // armored vehicle flamer that sprays a visual continual flame
	name = "spraying flames"
	icon_state = "spray_flamer"
	max_range = 7
	shell_speed = 0.3
	damage = 6
	burn_time = 0.3 SECONDS

/datum/ammo/rocket/coilgun
	name = "kinetic penetrator"
	icon_state = "tank_coilgun"
	hud_state = "rocket_ap"
	hud_state_empty = "rocket_empty"
	ammo_behavior_flags = AMMO_SNIPER
	armor_type = BULLET
	damage_falloff = 2
	shell_speed = 3
	accuracy = 10
	accurate_range = 20
	max_range = 40
	damage = 300
	penetration = 50
	sundering = 10
	bullet_color = LIGHT_COLOR_TUNGSTEN
	barricade_clear_distance = 4

/datum/ammo/rocket/coilgun/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 150, 30)

/datum/ammo/rocket/coilgun/holder //only used for tankside effect checks
	ammo_behavior_flags = AMMO_ENERGY

/datum/ammo/rocket/coilgun/low
	shell_speed = 2
	damage = 150
	penetration = 40
	sundering = 5

/datum/ammo/rocket/coilgun/low/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 120, 30)

/datum/ammo/rocket/coilgun/high
	damage_falloff = 0
	shell_speed = 4
	damage = 450
	penetration = 70
	sundering = 20
	ammo_behavior_flags = AMMO_SNIPER|AMMO_PASS_THROUGH_MOB

/datum/ammo/rocket/coilgun/high/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 350, 75)

/datum/ammo/rocket/coilgun/high/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(ishuman(target_mob) && !(target_mob.status_flags & GODMODE) &&  prob(50))
		target_mob.gib()
		proj.proj_max_range -= 5
		return
	proj.proj_max_range = 0

/datum/ammo/rocket/icc_lowvel_heat
	name = "Low Velocity HEAT shell"
	icon_state = "recoilless_rifle_heat"
	hud_state = "shell_heat"
	ammo_behavior_flags = AMMO_SNIPER
	shell_speed = 1
	damage = 180
	penetration = 100
	sundering = 0

/datum/ammo/rocket/icc_lowvel_heat/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 50, 25)

/datum/ammo/rocket/icc_lowvel_high_explosive
	name = "Low Velocity HE shell"
	damage = 50
	penetration = 100
	sundering = 10
	ammo_behavior_flags = AMMO_SNIPER // We want this to specifically go over onscreen range.
	shell_speed = 1

/datum/ammo/rocket/icc_lowvel_high_explosive/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 125, 45)

/datum/ammo/bullet/sarden
	name = "heavy autocannon armor piercing"
	hud_state = "alloy_spike"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 40
	penetration = 40
	sundering = 3.5
	matter_cost = 0

/datum/ammo/bullet/sarden/high_explosive
	name = "heavy autocannon high explosive"
	hud_state = "alloy_spike"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 25
	penetration = 30
	sundering = 0.5
	max_range = 21
	matter_cost = 0

/datum/ammo/bullet/sarden/high_explosive/drop_nade(turf/T)
	cell_explosion(T, 50, 25)

/datum/ammo/bullet/sarden/high_explosive/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/bullet/sarden/high_explosive/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/bullet/sarden/high_explosive/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/bullet/sarden/high_explosive/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/energy/volkite/heavy
	max_range = 35
	accurate_range = 12
	damage = 25
	fire_burst_damage = 20

/datum/ammo/energy/particle_lance
	name = "particle beam"
	hitscan_effect_icon = "particle_lance"
	hud_state = "plasma_blast"
	hud_state_empty = "battery_empty_flash"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE|AMMO_SNIPER
	bullet_color = LIGHT_COLOR_PURPLE_PINK
	armor_type = ENERGY
	max_range = 40
	accurate_range = 10
	accuracy = 25
	damage = 850
	penetration = 120
	sundering = 30
	damage_falloff = 5
	on_pierce_multiplier = 0.95
	barricade_clear_distance = 4

/datum/ammo/energy/particle_lance/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!isliving(target_mob))
		return
	var/mob/living/living_victim = target_mob
	living_victim.apply_radiation(living_victim.modify_by_armor(15, BIO, 25), 3)

/datum/ammo/energy/particle_lance/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(ishitbox(target_obj)) //yes this is annoying.
		var/obj/hitbox/hitbox = target_obj
		target_obj = hitbox.root

	if(isvehicle(target_obj))
		var/obj/vehicle/vehicle_target = target_obj
		for(var/mob/living/living_victim AS in vehicle_target.occupants)
			living_victim.apply_radiation(living_victim.modify_by_armor(12, BIO, 25), 3)
			living_victim.flash_pain()

	if(target_obj.obj_integrity > target_obj.modify_by_armor(proj.damage, ENERGY, proj.penetration, attack_dir = get_dir(target_obj, proj)))
		proj.proj_max_range = 0

#define BFG_SOUND_DELAY_SECONDS 1

/datum/ammo/energy/bfg
	name = "bfg glob"
	icon_state = "bfg_ball"
	hud_state = "electrothermal"
	hud_state_empty = "electrothermal_empty"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SPECIAL_PROCESS|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 0.2
	damage = 150
	penetration = 50
	max_range = 20
	bullet_color = COLOR_PALE_GREEN_GRAY

/datum/ammo/energy/bfg/ammo_process(atom/movable/projectile/proj, damage)
	if(proj.distance_travelled <= 2)
		return
	// range expands as it flies to avoid hitting the shooter and tank riders
	var/bfg_range = 4
	if(proj.distance_travelled < bfg_range)
		bfg_range = (proj.distance_travelled - 2)
	bfg_beam(proj, bfg_range, damage, penetration)

	//handling for BFG sound. yes it's kinda wierd to use distance traveled and probably will break at high lag
	//but this is super snowflake and I don't wanna bother something like making looping sounds attachable to projectiles today
	//feel free to do it though as a TODO?
	var/sound_delay_time = BFG_SOUND_DELAY_SECONDS/proj.projectile_speed
	if(proj.distance_travelled % sound_delay_time)
		playsound(proj, 'sound/weapons/guns/misc/bfg_fly.ogg', 30, FALSE)

/datum/ammo/energy/bfg/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	proj.proj_max_range -= 2

/datum/ammo/energy/bfg/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 2

/datum/ammo/energy/bfg/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 200, 50)

/datum/ammo/energy/bfg/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/bullet/tank_autocannon
	name = "autocannon armor piercing"
	hud_state = "alloy_spike"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 30
	penetration = 40
	sundering = 2.5
	matter_cost = 0

/datum/ammo/rocket/tank_autocannon
	name = "autocannon high explosive"
	icon_state = "bullet"
	hud_state = "alloy_spike"
	hud_state_empty = "railgun_hvap"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 15
	penetration = 20
	sundering = 1.5
	matter_cost = 0

/datum/ammo/rocket/tank_autocannon/on_hit_mob(mob/target_mob, atom/movable/projectile/proj) // This is so it doesn't knock back on hit.
	var/target_turf = get_turf(target_mob)
	drop_nade(target_turf)

/datum/ammo/rocket/tank_autocannon/drop_nade(turf/target_turf)
	cell_explosion(target_turf, 45, 25)

#undef BFG_SOUND_DELAY_SECONDS
