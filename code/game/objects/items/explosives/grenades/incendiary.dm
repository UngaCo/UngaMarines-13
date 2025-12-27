/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	worn_icon_state = "grenade_fire"
	det_time = 4 SECONDS
	hud_state = "grenade_fire"
	icon_state_mini = "grenade_orange"
	overlay_type = "orange"

/obj/item/explosive/grenade/incendiary/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, SFX_INCENDIARY_EXPLOSION, 35)
	qdel(src)

/proc/flame_radius(radius = 1, turf/epicenter, burn_intensity = 25, burn_duration = 25, burn_damage = 25, fire_stacks = 15, colour = FLAME_COLOR_RED) //~Art updated fire.
	if(!isturf(epicenter))
		CRASH("flame_radius used without a valid turf parameter")
	radius = clamp(radius, 1, 50) //Sanitize inputs

	for(var/t in filled_turfs(epicenter, radius, "circle", pass_flags_checked = PASS_AIR))
		var/turf/turf_to_flame = t
		turf_to_flame.ignite(randfloat(burn_duration*0.75, burn_duration), burn_intensity, colour, burn_damage, fire_stacks)

/obj/item/explosive/grenade/incendiary/som
	name = "\improper S30-I incendiary grenade"
	desc = "A reliable incendiary grenade utilised by SOM forces. Based off the S30 platform shared by most SOM grenades. Designed for hand or grenade launcher use."
	icon_state = "grenade_fire_som"
	worn_icon_state = "grenade_fire_som"
	overlay_type = "orange"

/obj/item/explosive/grenade/incendiary/molotov
	name = "improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	worn_icon_state = "molotov"
	arm_sound = 'sound/items/welder2.ogg'

/obj/item/explosive/grenade/incendiary/molotov/Initialize(mapload)
	. = ..()
	det_time = rand(1 SECONDS, 4 SECONDS)//Adds some risk to using this thing.

/obj/item/explosive/grenade/incendiary/molotov/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, SFX_MOLOTOV, 35)
	qdel(src)

/obj/item/explosive/grenade/incendiary/molotov/throw_impact(atom/hit_atom, speed, bounce = TRUE)
	. = ..()
	if(!.)
		return
	if(!hit_atom.density || prob(35))
		return
	prime()

/obj/item/explosive/grenade/phosphorus
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon_state = "grenade_phos"
	worn_icon_state = "grenade_phos"
	det_time = 2 SECONDS
	hud_state = "grenade_hide"
	icon_state_mini = "grenade_cyan"
	overlay_type = "aqua"
	var/datum/effect_system/smoke_spread/phosphorus/smoke

/obj/item/explosive/grenade/phosphorus/Initialize(mapload)
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/phosphorus/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/explosive/grenade/phosphorus/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, loc, 7)
	smoke.start()
	flame_radius(4, get_turf(src))
	flame_radius(1, get_turf(src), burn_intensity = 75, burn_duration = 45, burn_damage = 15, fire_stacks = 75)	//The closer to the middle you are the more it hurts
	qdel(src)

/obj/item/explosive/grenade/phosphorus/activate(mob/user)
	. = ..()
	if(!.)
		return FALSE
	user?.record_war_crime()

/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the USL. Designed to spill white phosphorus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	worn_icon_state = "grenade_upp_wp"
	arm_sound = 'sound/weapons/armbombpin_1.ogg'
