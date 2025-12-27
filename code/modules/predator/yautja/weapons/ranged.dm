/*#########################################
############## Ranged Weapons #############
#########################################*/

/datum/yautja_energy_weapon_modes
	///how much power the gun uses on this mode when shot.
	var/charge_cost = 0
	///the ammo datum this mode is.
	var/datum/ammo/ammo_datum_type = null
	///how long it takes between each shot of that mode, same as gun fire delay.
	var/fire_delay = 0
	///The gun firing sound of this mode
	var/fire_sound = null
	///What message it sends to the user when you switch to this mode.
	var/message_to_user = ""
	///Which icon file the radial menu will use.
	var/radial_icon = 'icons/mob/radial.dmi'
	///The icon state the radial menu will use.
	var/radial_icon_state = "laser"
	///The muzzleflash color of the weapon we use.
	var/muzzle_flash_color = COLOR_MAGENTA

/datum/yautja_energy_weapon_modes/stun_bolts
	charge_cost = 750
	ammo_datum_type = /datum/ammo/energy/yautja/caster/stun
	fire_delay = 5 SECONDS
	fire_sound = 'sound/weapons/pred_plasmacaster_fire.ogg'
	message_to_user = "will now fire low power stun bolts"
	radial_icon_state = "predator_plasma_weak"
	muzzle_flash_color = COLOR_MAGENTA

/datum/yautja_energy_weapon_modes/stun_heavy_bolts
	charge_cost = 1000
	ammo_datum_type = /datum/ammo/energy/yautja/caster/bolt/stun
	fire_delay = 7 SECONDS
	fire_sound = 'sound/weapons/pred_lasercannon.ogg'
	message_to_user = "will now fire high power stun bolts"
	radial_icon_state = "predator_plasma_strong"
	muzzle_flash_color = COLOR_MAGENTA

/datum/yautja_energy_weapon_modes/stun_spheres
	charge_cost = 1200
	ammo_datum_type = /datum/ammo/energy/yautja/caster/sphere/stun
	fire_delay = 100
	fire_sound = 'sound/weapons/pulse.ogg'
	message_to_user = "will now fire plasma immobilizers"
	radial_icon_state = "predator_stun_spheres"
	muzzle_flash_color = COLOR_MAGENTA

/datum/yautja_energy_weapon_modes/lethal_bolts
	charge_cost = 300
	ammo_datum_type = /datum/ammo/energy/yautja/caster/bolt
	fire_delay = 2 SECONDS
	fire_sound = 'sound/weapons/pred_lasercannon.ogg'
	message_to_user = "will now fire plasma bolts"
	radial_icon_state = "laser_disabler"
	muzzle_flash_color = COLOR_BRIGHT_BLUE

/obj/item/weapon/gun/energy/yautja
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = null
	worn_icon_list = list(
		slot_back_str = 'icons/mob/hunter/pred_gear.dmi',
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi',
		slot_s_store_str = 'icons/mob/hunter/pred_gear.dmi'
	)

	rounds_per_shot = 1
	muzzle_flash = "muzzle_flash_laser"
	muzzle_flash_color = COLOR_MAGENTA
	default_ammo_type = null

	gun_features_flags = GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_ENERGY|GUN_AMMO_COUNT_BY_PERCENTAGE|GUN_UNUSUAL_DESIGN

	var/list/datum/yautja_energy_weapon_modes/mode_list = list()

/obj/item/weapon/gun/energy/yautja/unique_action(mob/user)
	if(!user)
		CRASH("switch_modes called with no user.")

	if(length(mode_list))
		change_ammo_type(user)

/obj/item/weapon/gun/energy/yautja/update_icon_state()
	return

/obj/item/weapon/gun/energy/yautja/update_ammo_count()
	gun_user?.hud_used.update_ammo_hud(src, get_ammo_list(), get_display_ammo_count())

/obj/item/weapon/gun/energy/yautja/get_display_ammo_count()
	return round(rounds / charge_cost, 1)

/obj/item/weapon/gun/energy/yautja/unload(mob/living/user, drop = TRUE, after_fire = FALSE)
	return

/obj/item/weapon/gun/energy/yautja/proc/change_ammo_type(mob/user)
	var/list/available_modes = list()
	for(var/mode in mode_list)
		available_modes += list("[mode]" = image(icon = initial(mode_list[mode].radial_icon), icon_state = initial(mode_list[mode].radial_icon_state)))

	var/datum/yautja_energy_weapon_modes/choice = mode_list[show_radial_menu(user, user, available_modes, null, 64, tooltips = TRUE)]
	if(!choice)
		return

	playsound(user, 'sound/weapons/emitter.ogg', 5, FALSE, 2)

	ammo_datum_type = GLOB.ammo_list[initial(choice.ammo_datum_type)]
	fire_delay = initial(choice.fire_delay)
	fire_sound = initial(choice.fire_sound)
	charge_cost = initial(choice.charge_cost)

	to_chat(user, initial(choice.message_to_user))
	update_ammo_count()

/obj/item/weapon/gun/energy/yautja/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

//Spike launcher
/obj/item/weapon/gun/energy/yautja/spike
	name = "spike launcher"
	desc = "A compact Yautja device in the shape of a crescent. It can rapidly fire damaging spikes and automatically recharges."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "spikelauncher"
	worn_icon_state = "spikelauncher"
	resistance_flags = UNACIDABLE
	fire_sound = 'sound/effects/woodhit.ogg' // TODO: Decent THWOK noise.
	ammo_datum_type = /datum/ammo/energy/yautja/alloy_spike
	equip_slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY //Fits in yautja bags.
	rounds = 12
	max_rounds = 12
	var/last_regen
	item_flags = ITEM_PREDATOR|TWOHANDED

	fire_delay = 5
	accuracy_mult = 1.25
	accuracy_mult_unwielded = 1
	scatter = 1
	scatter_unwielded = 2
	damage_mult = 1

/obj/item/weapon/gun/energy/yautja/spike/Initialize(mapload, spawn_empty)
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time
	update_icon()

/obj/item/weapon/gun/energy/yautja/spike/get_display_ammo_count()
	return rounds

/obj/item/weapon/gun/energy/yautja/spike/process()
	if(rounds < max_rounds && world.time > last_regen + 100 && prob(70))
		rounds++
		last_regen = world.time
		update_icon()

/obj/item/weapon/gun/energy/yautja/spike/examine(mob/user)
	if(isyautja(user))
		. = ..()
		. += span_notice("It currently has <b>[rounds]/[max_rounds]</b> spikes.")
	else
		. = list()
		. += span_notice("Looks like some kind of...mechanical donut.")

/obj/item/weapon/gun/energy/yautja/spike/update_icon()
	..()
	var/new_icon_state = rounds <= 1 ? null : icon_state + "[round(rounds / (max_rounds / 3), 1)]"
	update_special_overlay(new_icon_state)

/obj/item/weapon/gun/energy/yautja/spike/able_to_fire(mob/user)
	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, span_warning("You have no idea how this thing works!"))
		return

	return ..()

/obj/item/weapon/gun/energy/yautja/spike/cycle()
	if(rounds > 0)
		in_chamber = get_ammo_object()
		rounds--
		return in_chamber

/obj/item/weapon/gun/energy/yautja/plasmarifle
	name = "plasma rifle"
	desc = "A long-barreled heavy plasma weapon. Intended for combat, not hunting. Has an integrated battery that allows for a functionally unlimited amount of shots to be discharged. Equipped with an internal gyroscopic stabilizer allowing its operator to fire the weapon one-handed if desired"
	icon_state = "plasmarifle"
	worn_icon_state = "plasmarifle"
	resistance_flags = UNACIDABLE
	fire_sound = 'sound/weapons/pred_plasma_shot.ogg'
	ammo_datum_type = /datum/ammo/energy/yautja/rifle/bolt
	zoomdevicename = "scope"
	equip_slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_GIGANTIC
	rounds = 100
	max_rounds = 100
	charge_cost = 5
	var/last_regen = 0
	item_flags = ITEM_PREDATOR|TWOHANDED
	gun_features_flags = GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_ENERGY|GUN_AMMO_COUNT_BY_PERCENTAGE|GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY

	fire_delay = 10
	accuracy_mult = 1.5
	accuracy_mult_unwielded = 1.5
	scatter = 2
	scatter_unwielded = 4
	damage_mult = 1

/obj/item/weapon/gun/energy/yautja/plasmarifle/Initialize(mapload, spawn_empty)
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time
	update_icon()

/obj/item/weapon/gun/energy/yautja/plasmarifle/process()
	if(rounds < max_rounds)
		rounds++
		if(rounds == max_rounds)
			if(ismob(loc)) to_chat(loc, span_notice("[src] hums as it achieves maximum charge."))
		update_icon()

/obj/item/weapon/gun/energy/yautja/plasmarifle/examine(mob/user)
	if(isyautja(user))
		. = ..()
		. += span_notice("It currently has <b>[rounds]/[max_rounds]</b> charge.")
	else
		. = list()
		. += span_notice("This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/yautja/plasmarifle/update_icon()
	. = ..()
	if(last_regen < rounds + max_rounds / 5 || last_regen > rounds || rounds > max_rounds / 1.05)
		var/new_icon_state = rounds <= 15 ? null : icon_state + "[round(rounds/(max_rounds / 3), 1)]"
		update_special_overlay(new_icon_state)
		last_regen = rounds

/obj/item/weapon/gun/energy/yautja/plasmarifle/able_to_fire(mob/user)
	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, span_warning("You have no idea how this thing works!"))
		return

	return ..()

/obj/item/weapon/gun/energy/yautja/plasmarifle/cycle()
	if(rounds < charge_cost)
		return

	ammo_datum_type = GLOB.ammo_list[/datum/ammo/energy/yautja/rifle/bolt]
	rounds -= charge_cost
	var/atom/movable/projectile/proj = get_ammo_object()
	in_chamber = proj
	return in_chamber

/obj/item/weapon/gun/energy/yautja/plasmapistol
	name = "plasma pistol"
	desc = "A plasma pistol capable of rapid fire. It has an integrated battery. Can be used to set fires, either to braziers or on people."
	icon_state = "plasmapistol"
	worn_icon_state = "plasmapistol"

	resistance_flags = UNACIDABLE
	fire_sound = 'sound/weapons/pulse3.ogg'
	equip_slot_flags = ITEM_SLOT_BELT
	ammo_datum_type = /datum/ammo/energy/yautja/pistol
	w_class = WEIGHT_CLASS_BULKY
	rounds = 40
	max_rounds = 40
	charge_cost = 1
	item_flags = ITEM_PREDATOR|TWOHANDED

	fire_delay = 4
	accuracy_mult = 1.5
	accuracy_mult_unwielded = 1.35
	scatter = 1
	scatter_unwielded = 3
	damage_mult = 1


/obj/item/weapon/gun/energy/yautja/plasmapistol/Initialize(mapload, spawn_empty)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/yautja/plasmapistol/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/yautja/plasmapistol/process()
	if(rounds < max_rounds)
		rounds += 0.25
		if(rounds == max_rounds)
			if(ismob(loc)) to_chat(loc, span_notice("[src] hums as it achieves maximum charge."))


/obj/item/weapon/gun/energy/yautja/plasmapistol/examine(mob/user)
	if(isyautja(user))
		. = ..()
		. += span_notice("It currently has <b>[rounds]/[max_rounds]</b> charge.")
	else
		. = list()
		. += span_notice("This thing looks like an alien rifle of some kind. Strange.")


/obj/item/weapon/gun/energy/yautja/plasmapistol/able_to_fire(mob/user)
	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, span_warning("You have no idea how this thing works!"))
		return
	else
		return ..()

/obj/item/weapon/gun/energy/yautja/plasmapistol/cycle()
	if(rounds < charge_cost)
		return
	var/atom/movable/projectile/proj = get_ammo_object()
	in_chamber = proj
	rounds -= charge_cost
	return in_chamber

#define PRED_MODE_STUN "stun"
#define PRED_MODE_LETHAL "lethal"

/obj/item/weapon/gun/energy/yautja/plasma_caster
	name = "plasma caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	icon_state = "plasma_ebony"
	var/initial_icon_state = "plasma"
	var/base_worn_icon_state = "plasma_wear"
	worn_worn_icon_state_slots = list(
		slot_back_str = "plasma_wear_off",
		slot_s_store_str = "plasma_wear_off"
	)
	fire_sound = 'sound/weapons/pred_plasmacaster_fire.ogg'
	ammo_datum_type = /datum/ammo/energy/yautja/caster/stun
	muzzle_flash_color = COLOR_VIOLET
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 0
	fire_delay = 3
	atom_flags = CONDUCT
	item_flags = NOBLUDGEON //Can't bludgeon with this.

	fire_delay = 5
	accuracy_mult = 1
	accuracy_mult_unwielded = 6
	scatter = 2
	scatter_unwielded = 4
	damage_mult = 1

	var/obj/item/clothing/gloves/yautja/hunter/source = null
	charge_cost = 100 //How much energy is needed to fire.
	var/last_time_targeted = 0
	var/mode = "stun"//fire mode (stun/lethal)
	var/strength = "low power stun bolts"//what it's shooting

	var/static/list/modes = list(
	PRED_MODE_STUN = image(icon = 'icons/mob/radial.dmi', icon_state = "pred_mode_stun"),
	PRED_MODE_LETHAL = image(icon = 'icons/mob/radial.dmi', icon_state = "pred_mode_lethal"))
	var/list/mode_by_mode_list = list(
		"stun" = list("low power stun bolts", "high power stun bolts", "plasma immobilizers"),
		"lethal" = list("plasma bolts")
	)
	mode_list = list(
		"low power stun bolts" = /datum/yautja_energy_weapon_modes/stun_bolts,
		"high power stun bolts" = /datum/yautja_energy_weapon_modes/stun_heavy_bolts,
		"plasma immobilizers" = /datum/yautja_energy_weapon_modes/stun_spheres,
		"plasma bolts" = /datum/yautja_energy_weapon_modes/lethal_bolts,
	)

	var/mob/living/carbon/laser_target = null

/obj/item/weapon/gun/energy/yautja/plasma_caster/Initialize(mapload, spawn_empty, caster_material = "ebony")
	icon_state = "[initial_icon_state]_[caster_material]"
	worn_icon_state = "[initial_icon_state]_[caster_material]"
	worn_worn_icon_state_slots[slot_back_str] = "[base_worn_icon_state]_off_[caster_material]"
	worn_worn_icon_state_slots[slot_s_store_str] = "[base_worn_icon_state]_off_[caster_material]"
	. = ..()
	source = loc
	if(!istype(source))
		qdel(src)
	RegisterSignal(src, COMSIG_ITEM_MIDDLECLICKON, PROC_REF(target_action))

/obj/item/weapon/gun/energy/yautja/plasma_caster/Destroy()
	. = ..()
	source = null

/obj/item/weapon/gun/energy/yautja/plasma_caster/get_display_ammo_count()
	return round(source.charge / source.charge_max * 100, 1)

/obj/item/weapon/gun/energy/yautja/plasma_caster/change_ammo_type(mob/user)
	var/list/available_modes = list()
	for(var/proj_mode in modes)
		available_modes += list("[proj_mode]" = image(icon = modes))

	var/selected_mode = show_radial_menu(user, user, modes, null, 64, tooltips = TRUE)
	if(selected_mode)
		mode = selected_mode

	available_modes = list()
	for(var/proj_mode in mode_by_mode_list[mode])
		available_modes += list("[proj_mode]" = image(icon = initial(mode_list[proj_mode].radial_icon), icon_state = initial(mode_list[proj_mode].radial_icon_state)))

	strength = show_radial_menu(user, user, available_modes, null, 64, tooltips = TRUE)
	var/datum/yautja_energy_weapon_modes/choice = mode_list[strength]
	if(!choice)
		return

	playsound(user, 'sound/weapons/emitter.ogg', 5, FALSE, 2)

	ammo_datum_type = GLOB.ammo_list[initial(choice.ammo_datum_type)]
	fire_delay = initial(choice.fire_delay)
	fire_sound = initial(choice.fire_sound)
	charge_cost = initial(choice.charge_cost)
	muzzle_flash_color = initial(choice.muzzle_flash_color)

	to_chat(user, initial(choice.message_to_user))
	update_ammo_count()

/obj/item/weapon/gun/energy/yautja/plasma_caster/examine(mob/user)
	. = ..()
	var/msg = "It is set to fire [strength]."
	if(mode == "lethal")
		. += span_red(msg)
	else
		. += span_orange(msg)

/obj/item/weapon/gun/energy/yautja/plasma_caster/dropped(mob/living/carbon/human/M)
	playsound(M, 'sound/weapons/pred_plasmacaster_off.ogg', 15, 1)
	to_chat(M, span_notice("You deactivate your plasma caster."))
	if(laser_target)
		laser_off(M)
	. = ..()
	if(source && !(src in M.contents))
		forceMove(source)
		source.caster_deployed = FALSE
		source.action_caster.set_toggle(FALSE)
		return

/obj/item/weapon/gun/energy/yautja/plasma_caster/able_to_fire(mob/user)
	if(!source)
		return
	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, span_warning("You have no idea how this thing works!"))
		return
	return ..()

/obj/item/weapon/gun/energy/yautja/plasma_caster/cycle(mob/user)
	if(source.drain_power(user, charge_cost))
		in_chamber = get_ammo_object()
		return in_chamber

/atom/proc/can_apply_pred_laser()
	return FALSE

/mob/living/carbon/can_apply_pred_laser()
	if(!overlays_standing[PRED_LASER_LAYER])
		return TRUE
	return FALSE

/atom/proc/apply_pred_laser()
	return FALSE

/mob/living/carbon/apply_pred_laser()
	overlays_standing[PRED_LASER_LAYER] = image("icon" = 'icons/mob/hunter/pred_gear.dmi', "icon_state" = "locking-y", "layer" = -PRED_LASER_LAYER)
	apply_overlay(PRED_LASER_LAYER)
	addtimer(CALLBACK(src, PROC_REF(delayed_apply_pred_laser)), 2 SECONDS)
	return TRUE

/mob/living/carbon/proc/delayed_apply_pred_laser()
	if(!overlays_standing[PRED_LASER_LAYER])
		return
	remove_overlay(PRED_LASER_LAYER)
	overlays_standing[PRED_LASER_LAYER] = image("icon" = 'icons/mob/hunter/pred_gear.dmi', "icon_state" = "locked-y", "layer" = -PRED_LASER_LAYER)
	apply_overlay(PRED_LASER_LAYER)

/atom/proc/remove_pred_laser()
	return FALSE

/mob/living/carbon/remove_pred_laser()
	remove_overlay(PRED_LASER_LAYER)
	return TRUE

/obj/item/weapon/gun/energy/yautja/plasma_caster/process()
	var/mob/living/user = loc
	if(!istype(user))
		laser_off()
	else if(!line_of_sight(user, laser_target, 24))
		laser_off(user)
		to_chat(user, span_danger("You lose sight of your target!"))

/obj/item/weapon/gun/energy/yautja/plasma_caster/do_fire(obj/object_to_fire)
	if(!QDELETED(laser_target))
		target = laser_target
	return ..()

/obj/item/weapon/gun/energy/yautja/plasma_caster/proc/target_action(datum/source, atom/A)
	if((!istype(A, /mob/living/carbon) && laser_target) || A == laser_target)
		laser_off(gun_user)
	else if(!laser_target && istype(A, /mob/living/carbon))
		if(last_time_targeted + 3 SECONDS > world.time)
			to_chat(gun_user, span_danger("You did it too recently!"))
			return
		if(!A.can_apply_pred_laser())
			return
		laser_on(A, gun_user)

/obj/item/weapon/gun/energy/yautja/plasma_caster/proc/activate_laser_target(atom/target, mob/user)
	if(laser_target)
		laser_off(user)
	target.apply_pred_laser()
	laser_target = target
	if(user)
		to_chat(user, span_danger("You focus your target marker on [target]!"))
	START_PROCESSING(SSobj, src)
	accuracy_mult += 0.50 //We get a big accuracy bonus vs the lasered target

/obj/item/weapon/gun/energy/yautja/plasma_caster/proc/deactivate_laser_target(mob/user)
	laser_target.remove_pred_laser()
	laser_target = null
	if(user)
		playsound(user, 'sound/machines/click.ogg', 25, 1)
	STOP_PROCESSING(SSobj, src)
	accuracy_mult -= 0.50 //We lose a big accuracy bonus vs the now unlasered target

/obj/item/weapon/gun/energy/yautja/plasma_caster/proc/laser_on(atom/target, mob/user)
	if(user?.client)
		user.client.click_intercept = src
		to_chat(user, span_notice("<b>You activate your target marker and take careful aim.</b>"))
		playsound(user,'sound/effects/nightvision.ogg', 25, 1)
	activate_laser_target(target, user)
	last_time_targeted = world.time
	return TRUE

/obj/item/weapon/gun/energy/yautja/plasma_caster/proc/laser_off(mob/user)
	if(!laser_target)
		return
	deactivate_laser_target()
	if(user?.client)
		user.client.click_intercept = null
		to_chat(user, span_notice("<b>You deactivate your target marker.</b>"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE

#undef PRED_MODE_STUN
#undef PRED_MODE_LETHAL
