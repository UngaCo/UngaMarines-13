/obj/item/explosive/grenade/pmc
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_pmc"
	worn_icon_state = "grenade_pmc"
	hud_state = "grenade_frag"
	icon_state_mini = "grenade_red_white"
	power = 125
	falloff = 40

/obj/item/explosive/grenade/pmc/prime()
	create_shrapnel(loc, 15, shrapnel_type = /datum/ammo/bullet/shrapnel/metal)
	return ..()

/obj/item/explosive/grenade/m15
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated TGMC fragmentation grenade. With decades of service in the TGMC, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	worn_icon_state = "grenade_ex"
	hud_state = "grenade_frag"
	icon_state_mini = "grenade_yellow"
	power = 125
	falloff = 40

/obj/item/explosive/grenade/m15/prime()
	create_shrapnel(loc, 15, shrapnel_type = /datum/ammo/bullet/shrapnel/metal)
	return ..()

/obj/item/explosive/grenade/stick
	name = "\improper Webley Mk15 stick grenade"
	desc = "A fragmentation grenade produced in the colonies, most commonly using old designs and schematics. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_stick"
	worn_icon_state = "grenade_stick"
	hud_state = "grenade_frag"
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15

/obj/item/explosive/grenade/upp
	name = "\improper Type 5 shrapnel grenade"
	desc = "A fragmentation grenade found within the ranks of the USL. Designed to explode into shrapnel and rupture the bodies of opponents. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_upp"
	worn_icon_state = "grenade_upp"
	hud_state = "greande_frag"
	throw_speed = 2
	throw_range = 6

/obj/item/explosive/grenade/som
	name = "\improper S30 HE grenade"
	desc = "A reliable high explosive grenade utilised by SOM forces. Designed for hand or grenade launcher use."
	icon_state = "grenade_som"
	worn_icon_state = "grenade_som"

/obj/item/explosive/grenade/vsd
	name = "\improper XM93 HEAP Grenade"
	desc = "InterTech's experimental High Explosive Anti Personnel grenade. Good for clearing out rooms and such."
	icon_state = "grenade_vsd"
	power = 100
	falloff = 20

/obj/item/explosive/grenade/sectoid
	name = "alien bomb"
	desc = "An odd, squishy, organ-like grenade. It will explode 3 seconds after squeezing it."
	icon_state = "alien_grenade"
	worn_icon_state = "alien_grenade"
	hud_state = "grenade_frag"
	power = 150
	falloff = 25

/obj/item/explosive/grenade/agls
	name = "\improper AGLS-37 HEDP grenade"
	desc = "A small tiny smart grenade, it is about to blow up in your face, unless you found it inert. Otherwise a pretty normal grenade, other than it is somehow in a primeable state."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "agls_grenade"
	worn_icon_state = "agls_grenade"
	det_time = 1 SECONDS
	power = 80
	falloff = 20

/obj/item/explosive/grenade/impact
	name = "\improper M40 IMDP grenade"
	desc = "A high explosive contact detonation munition utilizing the standard DP canister chassis. Has a focused blast specialized for door breaching and combating emplacements and light armoured vehicles. WARNING: Handthrowing does not result in sufficient force to trigger impact detonators."
	icon_state = "grenade_impact"
	worn_icon_state = "grenade_impact"
	hud_state = "grenade_frag"
	det_time = 4 SECONDS
	dangerous = TRUE
	icon_state_mini = "grenade_blue_white"
	power = 80
	falloff = 30
	overlay_type = "cyan"

/obj/item/explosive/grenade/impact/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!.)
		return
	if(launched && active && !istype(hit_atom, /turf/open)) //Only contact det if active, we actually hit something, and we're fired from a grenade launcher.
		cell_explosion(loc, 50, 25)
		qdel(src)

/obj/item/explosive/grenade/creampie
	name = "\improper ERP4 HE Banana Cream Pie grenade"
	desc = "A high explosive munition, hidden in the form of a tasty cream pie!"
	icon = 'icons/obj/items/food/piecake.dmi'
	icon_state = "pie"
