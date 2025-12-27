/datum/ammo/bullet/revolver
	name = "revolver bullet"
	hud_state = "revolver"
	hud_state_empty = "revolver_empty"
	handful_amount = 7
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 40
	penetration = 10
	additional_xeno_penetration = 20
	matter_cost = 0

/datum/ammo/bullet/revolver/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/rifle
	name = ".44 Long Special bullet"
	hud_state = "revolver_impact"
	handful_amount = 8
	damage = 55
	penetration = 30
	additional_xeno_penetration = 10
	damage_falloff = 0.5
	shell_speed = 3.5
	matter_cost = 16

/datum/ammo/bullet/revolver/rifle/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/t500
	name = ".500 Nigro Express revolver bullet"
	handful_icon_state = "nigro"
	accurate_range = 15
	handful_amount = 5
	damage = 100
	penetration = 40
	max_range = 25
	additional_xeno_penetration = 0
	matter_cost = 0

/datum/ammo/bullet/revolver/t500/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 0, slowdown = 0, knockback = 2)

/datum/ammo/bullet/revolver/t500/slavs
	name = ".500 'Slavs' revolver bullet"
	handful_icon_state = "nigro_sv"

/datum/ammo/bullet/revolver/t500/slavs/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, knockback = 1)

/datum/ammo/bullet/revolver/t500/qk
	name = ".500 'Queen Killer' revolver bullet"
	handful_icon_state = "nigro_qk"

/datum/ammo/bullet/revolver/t500/qk/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	if(isxenoqueen(target_mob))
		var/mob/living/carbon/xenomorph/X = target_mob
		X.apply_damage(40)
		staggerstun(target_mob, proj, stagger = 0, slowdown = 0, knockback = 0)
		to_chat(X, span_xenouserdanger("Something burn inside you!"))
		return
	staggerstun(target_mob, proj, stagger = 0, slowdown = 0, knockback = 1)

/datum/ammo/bullet/revolver/t312
	name = ".500 White Express revolver bullet"
	handful_icon_state = "nigro_we"
	accurate_range = 15
	handful_amount = 5
	damage = 100
	penetration = 40
	additional_xeno_penetration = 0
	matter_cost = 0

/datum/ammo/bullet/revolver/t312/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1)

/datum/ammo/bullet/revolver/t312/med
	name = ".500 EMB"
	handful_icon_state = "nigro"
	handful_amount = 5
	damage = 20
	penetration = 100
	shrapnel_chance = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SKIPS_ALIENS
	matter_cost = 0

/datum/ammo/bullet/revolver/t312/med/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/revolver/t312/med/adrenaline
	name = ".500 Adrenaline EMB"
	handful_icon_state = "nigro_adr"
	hud_state = "t312_adr"

/datum/ammo/bullet/revolver/t312/med/adrenaline/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!ishuman(target_mob))
		return
	target_mob.reagents.add_reagent(/datum/reagent/medicine/adrenaline, 2)
	target_mob.reagents.add_reagent(/datum/reagent/medicine/hyronalin, 3)

/datum/ammo/bullet/revolver/t312/med/rr
	name = ".500 Russian Red EMB"
	handful_icon_state = "nigro_rr"
	hud_state = "t312_rr"

/datum/ammo/bullet/revolver/t312/med/rr/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!ishuman(target_mob))
		return
	target_mob.reagents.add_reagent(/datum/reagent/medicine/russian_red, 5)

/datum/ammo/bullet/revolver/t312/med/md
	name = "packet of .500 Meraderm EMB"
	handful_icon_state = "nigro_md"
	hud_state = "t312_md"

/datum/ammo/bullet/revolver/t312/med/md/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!ishuman(target_mob))
		return
	target_mob.reagents.add_reagent(/datum/reagent/medicine/meralyne, 2.5)
	target_mob.reagents.add_reagent(/datum/reagent/medicine/dermaline, 2.5)

/datum/ammo/bullet/revolver/t312/med/neu
	name = ".500 Neuraline EMB"
	handful_icon_state = "nigro_neu"
	hud_state = "t312_neu"

/datum/ammo/bullet/revolver/t312/med/neu/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(!ishuman(target_mob))
		return
	target_mob.reagents.add_reagent(/datum/reagent/medicine/neuraline, 3.1)
	target_mob.reagents.add_reagent(/datum/reagent/medicine/hyronalin, 1.9)

/datum/ammo/bullet/revolver/r44
	name = "standard revolver bullet"
	damage = 35
	penetration = 15
	additional_xeno_penetration = 10
	matter_cost = 8

/datum/ammo/bullet/revolver/r44/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	hud_state = "revolver_small"
	damage = 30
	matter_cost = 0

/datum/ammo/bullet/revolver/small/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 25
	penetration = 10
	additional_xeno_penetration = 20
	matter_cost = 0

/datum/ammo/bullet/revolver/judge
	name = "oversized revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 60
	penetration = 10
	additional_xeno_penetration = 15
	matter_cost = 0

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	hud_state = "revolver_heavy"
	damage = 42.5
	penetration = 5
	accuracy = -10
	additional_xeno_penetration = 17.5
	matter_cost = 0

/datum/ammo/bullet/revolver/heavy/incendiary
	name = "incendiary heavy revolver bullet"
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_BALLISTIC
	matter_cost = 0

/datum/ammo/bullet/revolver/t76
	name = "magnum 12.7 bullet"
	handful_amount = 5
	damage = 130
	penetration = 30
	additional_xeno_penetration = 15
	matter_cost = 0

/datum/ammo/bullet/revolver/t76/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 0.5, slowdown = 1)

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	hud_state = "revolver_impact"
	handful_amount = 6
	damage = 45
	penetration = 20
	additional_xeno_penetration = 15
	matter_cost = 0

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, slowdown = 1, knockback = 1)

/datum/ammo/bullet/revolver/ricochet
	bonus_projectiles_type = /datum/ammo/bullet/revolver/small
	bonus_projectiles_scatter = 0
	matter_cost = 0

/datum/ammo/bullet/revolver/ricochet/one
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet

/datum/ammo/bullet/revolver/ricochet/two
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/one

/datum/ammo/bullet/revolver/ricochet/three
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/two

/datum/ammo/bullet/revolver/ricochet/four
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/three

/datum/ammo/bullet/revolver/ricochet/on_hit_mob(mob/target_mob,atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/revolver/ricochet/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	reflect(target_turf, proj, 10)
