GLOBAL_LIST_INIT(no_sticky_resin, typecacheof(list(
	/obj/item/clothing/mask/facehugger,
	/obj/alien/egg,
	/obj/structure/mineral_door,
	/obj/alien/resin,
	/obj/structure/bed/nest
))) //For sticky/acid spit

/datum/ammo/xeno
	icon_state = "neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	ammo_behavior_flags = AMMO_XENO
	armor_type = BIO
	shell_speed = 1
	accuracy = 40
	accurate_range = 15
	max_range = 15
	accuracy_var_low = 3
	accuracy_var_high = 3
	bullet_color = COLOR_LIME
	///used to make cooldown of the different spits vary.
	var/added_spit_delay = 0
	var/spit_cost = 5
	///List of reagents transferred upon spit impact if any
	var/list/datum/reagent/spit_reagents
	///Amount of reagents transferred upon spit impact if any
	var/reagent_transfer_amount
	///Amount of stagger imposed on impact if any
	var/stagger_duration
	///Amount of slowdown stacks imposed on impact if any
	var/slowdown_stacks
	///These define the reagent transfer strength of the smoke caused by the spit, if any, and its aoe
	var/datum/effect_system/smoke_spread/xeno/smoke_system
	var/smoke_strength
	var/smoke_range
	///The hivenumber of this ammo
	var/hivenumber = XENO_HIVE_NORMAL

/datum/ammo/xeno/toxin
	icon_state = "transvitox"
	name = "transvitox spit"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	spit_cost = 55
	added_spit_delay = 0
	damage_type = STAMINA
	accurate_range = 5
	max_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 40
	stagger_duration = 1.1 SECONDS
	slowdown_stacks = 1.5
	smoke_strength = 0.5
	smoke_range = 0
	reagent_transfer_amount = 4
	bullet_color = COLOR_TOXIN_XENO_TRANSVITOX

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/toxin/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_transvitox = reagent_transfer_amount)

/datum/ammo/xeno/toxin/on_hit_mob(mob/living/carbon/carbon_victim, atom/movable/projectile/proj)
	drop_transvitox_smoke(get_turf(carbon_victim))

	if(!istype(carbon_victim) || carbon_victim.stat == DEAD || carbon_victim.issamexenohive(proj.firer) )
		return

	if(isnestedhost(carbon_victim))
		return

	carbon_victim.adjust_stagger(stagger_duration)
	carbon_victim.add_slowdown(slowdown_stacks)

	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = carbon_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	carbon_victim.reagents.add_reagent_list(spit_reagents)

	return ..()

/datum/ammo/xeno/toxin/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_object)
	drop_transvitox_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_transvitox_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_transvitox_smoke(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/toxin/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/transvitox/light()

/datum/ammo/xeno/toxin/proc/drop_transvitox_smoke(turf/target_turf)
	if(target_turf.density)
		return

	set_smoke()
	smoke_system.strength = smoke_strength
	smoke_system.set_up(smoke_range, target_turf)
	smoke_system.start()
	smoke_system = null

/datum/ammo/xeno/toxin/sent //Sentinel
	spit_cost = 70
	icon_state = "xeno_sent_neuro"

/datum/ammo/xeno/toxin/upgrade1
	smoke_strength = 0.6
	reagent_transfer_amount = 5

/datum/ammo/xeno/toxin/upgrade2
	smoke_strength = 0.7
	reagent_transfer_amount = 6

/datum/ammo/xeno/toxin/upgrade3
	smoke_strength = 0.75
	reagent_transfer_amount = 6.5

/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	added_spit_delay = 0
	spit_cost = 200
	damage = 80
	smoke_strength = 1
	reagent_transfer_amount = 18
	smoke_range = 1

/datum/ammo/xeno/tox_loss
	name = "toxin spit"
	icon_state = "transvitox"
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS
	spit_cost = 50
	added_spit_delay = 0
	damage_type = STAMINA
	accurate_range = 5
	max_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 15
	stagger_duration = 1 SECONDS
	slowdown_stacks = 1.5
	bullet_color = COLOR_LIGHT_ORANGE
	var/toxin_damage = 10

/datum/ammo/xeno/tox_loss/on_hit_mob(mob/living/carbon/carbon_victim, atom/movable/projectile/proj)
	carbon_victim.apply_damage(toxin_damage, TOX, proj.def_zone, armor_type, updating_health = TRUE)
	return ..()

/datum/ammo/xeno/tox_loss/heavy //Praetorian
	name = "toxin splash"
	added_spit_delay = 0
	spit_cost = 180
	damage = 30
	toxin_damage = 20

/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	icon_state = "sticky"
	ping = null
	ammo_behavior_flags = AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF|AMMO_XENO
	damage_type = STAMINA
	armor_type = BIO
	spit_cost = 50
	sound_hit = "alien_resin_build2"
	sound_bounce = "alien_resin_build3"
	damage = 40
	max_range = 40
	bullet_color = COLOR_PURPLE
	stagger_duration = 1 SECONDS
	slowdown_stacks = 3

/datum/ammo/xeno/sticky/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_resin(get_turf(target_mob))
	if(istype(target_mob, /mob/living/carbon))
		var/mob/living/carbon/C = target_mob
		if(C.issamexenohive(proj.firer))
			return
		C.adjust_stagger(stagger_duration) //stagger briefly; useful for support
		C.add_slowdown(slowdown_stacks) //slow em down

/datum/ammo/xeno/sticky/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	if(isarmoredvehicle(target_object))
		var/obj/vehicle/sealed/armored/tank = target_object
		COOLDOWN_START(tank, cooldown_vehicle_move, tank.move_delay)
	var/turf/target_turf = get_turf(target_object)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_resin(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/sticky/proc/drop_resin(turf/target_turf)
	if(target_turf.density || istype(target_turf, /turf/open/space)) // No structures in space
		return

	for(var/obj/target_object in target_turf.contents)
		if(is_type_in_typecache(target_object, GLOB.no_sticky_resin))
			return

	new /obj/alien/resin/sticky/thin(target_turf)

/datum/ammo/xeno/sticky/turret
	max_range = 9

/datum/ammo/xeno/sticky/globe
	name = "sticky resin globe"
	icon_state = "sticky_globe"
	damage = 40
	max_range = 7
	spit_cost = 200
	added_spit_delay = 3 SECONDS
	bonus_projectiles_type = /datum/ammo/xeno/sticky/mini
	bonus_projectiles_scatter = 22
	var/bonus_projectile_quantity = 16

/datum/ammo/xeno/sticky/mini
	damage = 5
	max_range = 3
	shell_speed = 1

/datum/ammo/xeno/sticky/globe/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	var/turf/det_turf = target_object.allow_pass_flags & PASS_PROJECTILE ? get_step_towards(target_object, proj) : target_object.loc
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_object), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/det_turf = get_turf(target_mob)
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/xeno/sticky/globe/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	drop_resin(det_turf)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid_weak"
	sound_hit 	 = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	damage_type = BURN
	added_spit_delay = 5
	spit_cost = 50
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF
	armor_type = ACID
	damage = 18
	max_range = 8
	bullet_color = COLOR_PALE_GREEN_GRAY
	///Duration of the acid puddles
	var/puddle_duration = 1 SECONDS //Lasts 1-3 seconds
	///Damage dealt by acid puddles
	var/puddle_acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE

/datum/ammo/xeno/acid/on_shield_block(mob/victim, atom/movable/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/acid/drop_nade(turf/target_turf) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(target_turf.density)
		return
	new /obj/effect/xenomorph/spray/weak(target_turf, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30
	ammo_behavior_flags = AMMO_XENO
	icon_state = "xeno_acid_normal"
	bullet_color = COLOR_VERY_PALE_LIME_GREEN

/datum/ammo/xeno/acid/medium/drop_nade(turf/target_turf) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(target_turf.density)
		return
	new /obj/effect/xenomorph/spray(target_turf, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/medium/passthrough //Spitter
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/auto
	name = "light acid spatter"
	damage = 10
	damage_falloff = 0.3
	spit_cost = 25
	added_spit_delay = 0
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/auto/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj)

/datum/ammo/xeno/acid/auto/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_nade(target_object.density ? get_step_towards(target_object, proj) : get_turf(target_object))

/datum/ammo/xeno/acid/auto/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : get_turf(target_turf))

/datum/ammo/xeno/acid/auto/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : get_turf(target_turf))

/datum/ammo/xeno/acid/passthrough
	name = "acid spittle"
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 2
	spit_cost = 70
	damage = 30
	icon_state = "xeno_acid_strong"
	bullet_color = COLOR_ASSEMBLY_YELLOW

/datum/ammo/xeno/acid/heavy/drop_nade(turf/target_turf) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(target_turf.density)
		return
	new /obj/effect/xenomorph/spray/strong(target_turf, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/heavy/passthrough //Praetorian
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/heavy/turret
	damage = 20
	name = "acid turret splash"
	shell_speed = 2
	max_range = 9
	icon_state = "xeno_acid_weak"
	bullet_color = COLOR_PALE_GREEN_GRAY

/datum/ammo/xeno/acid/heavy/turret/drop_nade(turf/target_turf) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(target_turf.density)
		return
	new /obj/effect/xenomorph/spray/weak(target_turf, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_mob)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_nade(target_object.density ? get_step_towards(target_object, proj) : get_turf(target_object))

/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/acid/heavy/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

///For the Spitter's Scatterspit ability
/datum/ammo/xeno/acid/heavy/scatter
	damage = 20
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	bonus_projectiles_type = /datum/ammo/xeno/acid/heavy/scatter
	bonus_projectiles_amount = 6
	bonus_projectiles_scatter = 2
	max_range = 8
	puddle_duration = 1 SECONDS //Lasts 2-4 seconds
	icon_state = "xeno_acid_normal"
	bullet_color = COLOR_VERY_PALE_LIME_GREEN

/datum/ammo/xeno/acid/heavy/scatter/drop_nade(turf/target_turf) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(target_turf.density)
		return
	new /obj/effect/xenomorph/spray(target_turf, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/heavy/scatter/praetorian
	max_range = 5
	damage = 15
	puddle_duration = 0.5 SECONDS
	bonus_projectiles_amount = 3

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	armor_type = BIO
	accuracy_var_high = 10
	max_range = 30
	damage = 50
	damage_type = STAMINA
	damage_falloff = 0
	penetration = 40
	bullet_color = BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR
	reagent_transfer_amount = 30
	///Key used for icon stuff during bombard ammo selection.
	var/icon_key = BOILER_GLOB_NEURO
	///This text will show up when a boiler selects this ammo. Span proc should be applied when this var is used.
	var/select_text = "We will now fire neurotoxic gas. This is nonlethal."
	var/danger_message = span_danger("A glob of acid lands with a splat and explodes into noxious fumes!")
	///On a direct hit, how long is the target paralyzed?
	var/hit_paralyze_time = 1 SECONDS
	///On a direct hit, how much do the victim's eyes get blurred?
	var/hit_eye_blur = 11
	///On a direct hit, how much drowsyness gets added to the target?
	var/hit_drowsyness = 12
	///Base spread range
	var/fixed_spread_range = 4
	///Which type is the smoke we leave on passed tiles, provided the projectile has AMMO_LEAVE_TURF enabled?
	var/passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	///We're going to reuse one smoke spread system repeatedly to cut down on processing.
	var/datum/effect_system/smoke_spread/xeno/trail_spread_system

/datum/ammo/xeno/boiler_gas/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	if(isxeno(proj.firer))
		var/mob/living/carbon/xenomorph/X = proj.firer
		trail_spread_system.strength = X.xeno_caste.bomb_strength
	trail_spread_system.set_up(0, target_turf)
	trail_spread_system.start()

/**
 * Loads a trap with a gas cloud depending on current glob type
 * Called when something with a boiler glob as current ammo interacts with an empty resin trap.
 * * Args:
 * * trap: The trap being loaded
 * * user_xeno: The xeno interacting with the trap
 * * Returns: TRUE on success, FALSE on failure.
**/
/datum/ammo/xeno/boiler_gas/proc/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 2 SECONDS, NONE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_NEURO)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/neuro/medium
	trap.smoke.set_up(2, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/New()
	. = ..()
	if((ammo_behavior_flags & AMMO_LEAVE_TURF) && passed_turf_smoke_type)
		trail_spread_system = new passed_turf_smoke_type(only_once = FALSE)

/datum/ammo/xeno/boiler_gas/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/boiler_gas/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)

/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj.firer)
	if(target_mob.stat == DEAD || !ishuman(target_mob))
		return
	var/mob/living/carbon/human/human_victim = target_mob

	human_victim.Paralyze(hit_paralyze_time)
	human_victim.blur_eyes(hit_eye_blur)
	human_victim.adjust_drowsyness(hit_drowsyness)

	if(!reagent_transfer_amount)
		return

	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = human_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	human_victim.reagents.add_reagent_list(spit_reagents)

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(ismecha(target_obj))
		proj.damage *= 7 //Globs deal much higher damage to mechs.
	var/turf/target_turf = get_turf(target_obj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_turf, proj.firer)

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj.firer) //we don't want the gas globs to land on dense turfs, they block smoke expansion.

/datum/ammo/xeno/boiler_gas/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj.firer)

/datum/ammo/xeno/boiler_gas/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()

/datum/ammo/xeno/boiler_gas/drop_nade(turf/target_turf, atom/firer, range = 1)
	set_smoke()
	if(isxeno(firer))
		var/mob/living/carbon/xenomorph/X = firer
		smoke_system.strength = X.xeno_caste.bomb_strength
		range = fixed_spread_range
	smoke_system.set_up(range, target_turf)
	smoke_system.start()
	smoke_system = null
	target_turf.visible_message(danger_message)

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_gas"
	sound_hit 	 = SFX_ACID_HIT
	sound_bounce = SFX_ACID_BOUNCE
	icon_key = BOILER_GLOB_ACID
	select_text = "We will now fire corrosive acid. This is lethal!"
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	armor_type = ACID
	danger_message = span_danger("A glob of acid lands with a splat and explodes into corrosive bile!")
	damage = 50
	damage_type = BURN
	penetration = 40
	bullet_color = BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR
	hit_paralyze_time = 1 SECONDS
	hit_eye_blur = 1
	hit_drowsyness = 1
	reagent_transfer_amount = 0

/datum/ammo/xeno/boiler_gas/corrosive/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 3 SECONDS, NONE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_ACID)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/acid
	trap.smoke.set_up(1, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/corrosive/on_shield_block(mob/victim, atom/movable/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/boiler_gas/corrosive/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/acid()

/datum/ammo/xeno/boiler_gas/lance
	name = "pressurized glob of gas"
	icon_key = BOILER_GLOB_NEURO_LANCE
	select_text = "We will now fire a pressurized neurotoxic lance. This is barely nonlethal."
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a nasty splat and explodes into noxious fumes!")
	max_range = 40
	damage = 75
	penetration = 60
	reagent_transfer_amount = 55
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	hit_paralyze_time = 2 SECONDS
	hit_eye_blur = 16
	hit_drowsyness = 18
	fixed_spread_range = 2
	accuracy = 100
	accurate_range = 30
	shell_speed = 1.5

/datum/ammo/xeno/boiler_gas/corrosive/lance
	name = "pressurized glob of acid"
	icon_key = BOILER_GLOB_ACID_LANCE
	select_text = "We will now fire a pressurized corrosive lance. This lethal!"
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a concerning hissing sound and explodes into corrosive bile!")
	max_range = 40
	damage = 75
	penetration = 60
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/acid/light
	hit_paralyze_time = 1.5 SECONDS
	hit_eye_blur = 4
	hit_drowsyness = 2
	fixed_spread_range = 2
	accuracy = 100
	accurate_range = 30
	shell_speed = 1.5

/datum/ammo/xeno/hugger
	name = "hugger ammo"
	ping = ""
	ammo_behavior_flags = AMMO_XENO
	damage = 0
	max_range = 6
	shell_speed = 1
	bullet_color = ""
	icon_state = "facehugger"
	///The type of hugger thrown
	var/obj/item/clothing/mask/facehugger/hugger_type = /obj/item/clothing/mask/facehugger

/datum/ammo/xeno/hugger/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(target_mob), hivenumber)
	hugger.try_attach(target_mob)

/datum/ammo/xeno/hugger/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(target_object), hivenumber)
	hugger.go_active()

/datum/ammo/xeno/hugger/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(target_turf.density ? proj.loc : target_turf, hivenumber)
	hugger.go_active()

/datum/ammo/xeno/hugger/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(target_turf.density ? proj.loc : target_turf, hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/slash
	hugger_type = /obj/item/clothing/mask/facehugger/combat/slash

/datum/ammo/xeno/hugger/neuro
	hugger_type = /obj/item/clothing/mask/facehugger/combat/chem_injector/neuro

/datum/ammo/xeno/hugger/ozelomelyn
	hugger_type = /obj/item/clothing/mask/facehugger/combat/chem_injector/ozelomelyn

/datum/ammo/xeno/hugger/resin
	hugger_type = /obj/item/clothing/mask/facehugger/combat/resin

/datum/ammo/xeno/hugger/acid
	hugger_type = /obj/item/clothing/mask/facehugger/combat/acid

/*
//================================================
					Widow Ammo Types
//================================================
*/

/datum/ammo/xeno/leash_ball
	icon_state = "widow_snareball"
	ping = "ping_x"
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_SKIPS_ALIENS | AMMO_TARGET_TURF
	bullet_color = COLOR_PURPLE
	ping = null
	damage = 0
	armor_type = BIO
	shell_speed = 1.5
	accurate_range = 8
	max_range = 8

/datum/ammo/xeno/leash_ball/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf)

/datum/ammo/xeno/leash_ball/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_mob)
	drop_leashball(target_turf.density ? proj.loc : target_turf, proj.firer)

/datum/ammo/xeno/leash_ball/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_obj)
	if(target_turf.density || (target_obj.density && !(target_obj.allow_pass_flags & PASS_PROJECTILE)))
		target_turf = get_turf(proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf, proj.firer)

/datum/ammo/xeno/leash_ball/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_leashball(target_turf.density ? proj.loc : target_turf)

/// This spawns a leash ball and checks if the turf is dense before doing so
/datum/ammo/xeno/leash_ball/proc/drop_leashball(turf/target_turf)
	new /obj/structure/xeno/aoe_leash(get_turf(target_turf), hivenumber)

/datum/ammo/xeno/web_projectile
	icon_state = "web_spit"
	sound_hit = SFX_SNAP
	sound_bounce = "alien_resin_build3"
	damage_type = STAMINA
	bullet_color = COLOR_PURPLE
	ammo_behavior_flags = AMMO_SKIPS_ALIENS
	ping = null
	armor_type = BIO
	accurate_range = 8
	max_range = 8
	///How long the victim will be KO'd
	var/hit_weaken = 2 SECONDS

/datum/ammo/xeno/web_projectile/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	. = ..()
	if(!ishuman(target_mob))
		return
	playsound(get_turf(target_mob), SFX_SNAP, 30, falloff = 5)
	var/mob/living/carbon/human/human_victim = target_mob
	human_victim.apply_effect(hit_weaken, EFFECT_PARALYZE)

/datum/ammo/energy/xeno
	barricade_clear_distance = 0
	///Plasma cost to fire this projectile
	var/ability_cost
	///Particle type used when this ammo is used
	var/particles/channel_particle
	///The colour the xeno glows when using this ammo type
	var/glow_color

/datum/ammo/energy/xeno/psy_blast
	name = "psychic blast"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_ENERGY|AMMO_HITSCAN|AMMO_SKIPS_ALIENS
	damage = 35
	penetration = 10
	sundering = 1
	max_range = 7
	accurate_range = 7
	hitscan_effect_icon = "beam_cult"
	icon_state = "psy_blast"
	ability_cost = 230
	channel_particle = /particles/warlock_charge/psy_blast
	glow_color = "#9e1f1f"
	///The AOE for drop_nade
	var/aoe_range = 2

/datum/ammo/energy/xeno/psy_blast/drop_nade(turf/target_turf, atom/movable/projectile/proj)
	if(!target_turf || !isturf(target_turf))
		return
	playsound(target_turf, 'sound/effects/EMPulse.ogg', 50)
	var/aoe_damage = 25
	if(isxeno(proj.firer))
		var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
		aoe_damage = xeno_firer.xeno_caste.blast_strength

	var/list/throw_atoms = list()
	var/list/turf/target_turfs = generate_cone(target_turf, aoe_range, -1, 359, 0, pass_flags_checked = PASS_AIR)
	for(var/turf/targetted_turf AS in target_turfs)
		for(var/atom/movable/target AS in targetted_turf)
			if(isliving(target))
				var/mob/living/living_victim = target
				if(living_victim.stat == DEAD)
					continue
				if(!isxeno(living_victim))
					living_victim.apply_damage(aoe_damage, BURN, null, ENERGY, FALSE, FALSE, TRUE, penetration)
					staggerstun(living_victim, proj, 10, slowdown = 1)
			else if(isobj(target))
				var/obj/obj_victim = target
				if(!(obj_victim.resistance_flags & XENO_DAMAGEABLE))
					continue
				obj_victim.take_damage(aoe_damage, BURN, ENERGY, TRUE, armour_penetration = penetration)
			if(target.anchored)
				continue
			throw_atoms += target

	for(var/atom/movable/target AS in throw_atoms)
		var/throw_dir = get_dir(target_turf, target)
		if(target_turf == get_turf(target))
			throw_dir = get_dir(proj.starting_turf, target_turf)
		target.safe_throw_at(get_ranged_target_turf(target_turf, throw_dir, 5), 3, 1, spin = TRUE)

	new /obj/effect/temp_visual/shockwave(target_turf, aoe_range + 2)

/datum/ammo/energy/xeno/psy_blast/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob), proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	drop_nade(target_object.density ? get_step_towards(target_object, proj) : target_object, proj)

/datum/ammo/energy/xeno/psy_blast/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj)

/datum/ammo/energy/xeno/psy_blast/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf, proj)

/datum/ammo/energy/xeno/psy_blast/psy_lance
	name = "psychic lance"
	ammo_behavior_flags = AMMO_XENO|AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE
	damage = 60
	penetration = 50
	accuracy = 100
	sundering = 5
	max_range = 16
	hitscan_effect_icon = "beam_hcult"
	icon_state = "psy_lance"
	ability_cost = 300
	channel_particle = /particles/warlock_charge/psy_blast/psy_lance
	glow_color = "#CB0166"

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	if(ismecha(target_object))
		proj.damage *= 3
	else if(ishitbox(target_object) || isvehicle(target_object))
		proj.damage *= 1.5

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(isxeno(target_mob))
		return
	staggerstun(target_mob, proj, 9, stagger = 4 SECONDS, slowdown = 2, knockback = 1)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	return

/datum/ammo/energy/xeno/psy_blast/psy_lance/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	return
