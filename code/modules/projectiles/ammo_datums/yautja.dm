/datum/ammo/energy/yautja
	accurate_range = 12
	shell_speed = 2
	bullet_color = COLOR_STRONG_VIOLET
	damage_type = BURN
	ammo_behavior_flags = NONE

	hud_state = "plasma"
	hud_state_empty = "electrothermal_empty"

/datum/ammo/energy/yautja/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	icon_state = "MSpearFlight"
	hud_state = "alloy_spike"
	sound_hit = SFX_ALLOY_HIT
	sound_armor = SFX_ALLOY_ARMOR
	sound_bounce = SFX_ALLOY_BOUNCE
	bullet_color = COLOR_MAGENTA
	armor_type = BULLET
	accuracy = 20
	accurate_range = 15
	max_range = 15
	damage = 40
	penetration = 50
	shrapnel_chance = 75

/datum/ammo/energy/yautja/pistol
	name = "plasma pistol bolt"
	icon_state = "ion"

	hud_state = "plasma_pistol"

	bullet_color = COLOR_MAGENTA
	damage = 40
	shell_speed = 1.5

/datum/ammo/energy/yautja/caster
	name = "root caster bolt"
	icon_state = "ion"

/datum/ammo/energy/yautja/caster/stun
	name = "low power stun bolt"
	hud_state = "plasma_pistol"

	bullet_color = COLOR_VIOLET
	damage = 0
	ammo_behavior_flags = AMMO_ENERGY
	var/stun_time = 2.5 SECONDS

/datum/ammo/energy/yautja/caster/stun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/mob/living/carbon/C = target_mob
	if(istype(C))
		if(isyautja(C) || ispredalien(C))
			return
		to_chat(C, span_danger("An electric shock ripples through your body, freezing you in place!"))
		log_attack("[key_name(C)] was stunned by a high power stun bolt from [key_name(proj.firer)] at [get_area(proj)]")

		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.apply_effect(stun_time, EFFECT_PARALYZE)
		else
			C.apply_effect(stun_time, EFFECT_PARALYZE)

		C.apply_effect(stun_time, EFFECT_STUN)
	return ..()

/datum/ammo/energy/yautja/caster/bolt
	name = "plasma bolt"
	icon_state = "pulse1"
	bullet_color = COLOR_BRIGHT_BLUE
	shell_speed = 3
	damage = 35

/datum/ammo/energy/yautja/caster/bolt/stun
	name = "high power stun bolt"
	icon_state = "pred_stun"
	var/stun_time = 5 SECONDS
	bullet_color = COLOR_MAGENTA

	hud_state = "plasma_rifle"

	damage = 0
	ammo_behavior_flags = AMMO_ENERGY

/datum/ammo/energy/yautja/caster/bolt/stun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/mob/living/carbon/C = target_mob
	if(istype(C))
		if(isyautja(C) || ispredalien(C))
			return
		to_chat(C, span_danger("An electric shock ripples through your body, freezing you in place!"))
		log_attack("[key_name(C)] was stunned by a high power stun bolt from [key_name(proj.firer)] at [get_area(proj)]")

		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.apply_effect(stun_time, EFFECT_PARALYZE)
		else
			C.apply_effect(stun_time, EFFECT_PARALYZE)

		C.apply_effect(stun_time, EFFECT_STUN)
	return ..()

/datum/ammo/energy/yautja/caster/sphere/stun
	name = "plasma immobilizer"
	bullet_color = COLOR_MAGENTA
	damage = 0
	ammo_behavior_flags = AMMO_ENERGY
	hud_state = "plasma_rifle_blast"
	accurate_range = 20
	max_range = 20
	var/stun_range = 4
	var/stun_time = 3 SECONDS

/datum/ammo/energy/yautja/caster/sphere/stun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	do_area_stun(proj)

/datum/ammo/energy/yautja/caster/sphere/stun/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	do_area_stun(proj)

/datum/ammo/energy/yautja/caster/sphere/stun/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	do_area_stun(proj)

/datum/ammo/energy/yautja/caster/sphere/stun/do_at_max_range(atom/movable/projectile/proj)
	do_area_stun(proj)

/datum/ammo/energy/yautja/caster/sphere/stun/proc/do_area_stun(atom/movable/projectile/proj)
	playsound(proj, 'sound/weapons/wave.ogg', 75, 1, 25)
	for(var/mob/living/carbon/target_mob in view(stun_range, get_turf(proj)))
		var/f_stun_time = stun_time
		log_attack("[key_name(target_mob)] was stunned by a plasma immobilizer from [key_name(proj.firer)] at [get_area(proj)]")
		if(isyautja(target_mob))
			f_stun_time -= 2 SECONDS
		if(ispredalien(target_mob))
			continue
		to_chat(target_mob, span_danger("A powerful electric shock ripples through your body, freezing you in place!"))
		target_mob.apply_effect(f_stun_time, EFFECT_STUN)

		if(ishuman(target_mob))
			var/mob/living/carbon/human/H = target_mob
			H.apply_effect(f_stun_time, EFFECT_PARALYZE)
		else
			target_mob.apply_effect(f_stun_time, EFFECT_PARALYZE)

/datum/ammo/energy/yautja/rifle/bolt
	name = "plasma rifle bolt"
	icon_state = "ion"
	damage_type = BURN

	hud_state = "plasma_rifle"

	damage = 70
	penetration = 55
