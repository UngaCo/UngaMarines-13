/datum/ammo/bullet/pistol
	name = "pistol bullet"
	hud_state = "pistol"
	hud_state_empty = "pistol_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 15
	penetration = 5
	accurate_range = 5
	additional_xeno_penetration = 20
	matter_cost = 6

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"
	hud_state = "pistol_light"
	damage = 12
	penetration = 5
	additional_xeno_penetration = 17.5
	matter_cost = 2

/datum/ammo/bullet/pistol/tiny/ap
	name = "light pistol bullet"
	hud_state = "pistol_lightap"
	damage = 20
	penetration = 15 //So it can actually hurt something.
	additional_xeno_penetration = 7.5
	damage_falloff = 1.5
	matter_cost = 0

/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	hud_state = "pistol_tranq"
	damage = 25
	damage_type = STAMINA
	matter_cost = 0

/datum/ammo/bullet/pistol/tranq/on_hit_mob(mob/victim, atom/movable/projectile/proj)
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/potassium_chlorophoride, 1)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	hud_state = "pistol_hollow"
	damage = 12.5
	accuracy = -10
	shrapnel_chance = 45
	additional_xeno_penetration = 30
	matter_cost = 0

/datum/ammo/bullet/pistol/hollow/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 15
	penetration = 12.5
	shrapnel_chance = 15
	additional_xeno_penetration = 12.5
	matter_cost = 0

/datum/ammo/bullet/pistol/ap/smart
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	hud_state = "pistol_heavy"
	damage = 25
	penetration = 5
	shrapnel_chance = 25
	additional_xeno_penetration = 20
	matter_cost = 0

/datum/ammo/bullet/pistol/superheavy
	name = "high impact pistol bullet"
	hud_state = "pistol_superheavy"
	damage = 45
	penetration = 15
	additional_xeno_penetration = 10
	damage_falloff = 0.75
	matter_cost = 0

/datum/ammo/bullet/pistol/superheavy/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 0.5 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/superheavy/derringer
	handful_amount = 2
	handful_icon_state = "derringer"
	matter_cost = 0

/datum/ammo/bullet/pistol/superheavy/derringer/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	hud_state = "pistol_fire"
	damage_type = BURN
	shrapnel_chance = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 20
	penetration = 0
	additional_xeno_penetration = 0
	matter_cost = 0

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	hud_state = "pistol_squash"
	accuracy = 5
	damage = 26
	penetration = 10
	shrapnel_chance = 25
	additional_xeno_penetration = 20
	matter_cost = 0

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	hud_state = "monkey"
	hud_state_empty = "monkey_empty"
	ping = null //no bounce off.
	damage_type = BURN
	ammo_behavior_flags = AMMO_INCENDIARY
	shell_speed = 2
	damage = 15
	matter_cost = 0

/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!target_mob.stat && !ismonkey(target_mob))
		proj.visible_message(span_danger("The [src] chimpers furiously!"))
		new /mob/living/carbon/human/species/monkey(proj.loc)
