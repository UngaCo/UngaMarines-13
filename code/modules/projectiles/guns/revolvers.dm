/obj/item/weapon/gun/revolver
	icon = 'icons/obj/items/gun/pistol.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/gun/pistol_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/gun/pistol_righthand_1.dmi',
	)
	equip_slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	fire_sound = 'sound/weapons/guns/fire/44mag.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/revolver_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/revolver_spun.ogg'
	cocked_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	unload_sound = 'sound/weapons/guns/interact/revolver_unload.ogg'
	muzzleflash_iconstate = "muzzle_flash_medium"
	hand_reload_sound = 'sound/weapons/guns/interact/revolver_load.ogg'
	type_of_casings = "bullet"
	load_method = SINGLE_CASING|SPEEDLOADER //codex
	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_NO_PITCH_SHIFT_NEAR_EMPTY|GUN_SMOKE_PARTICLES
	aim_speed_modifier = 0.75
	aim_fire_delay = 0.25 SECONDS
	wield_delay = 0.4 SECONDS
	gun_skill_category = SKILL_PISTOLS

	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_ROTATES_CHAMBER|AMMO_RECIEVER_TOGGLES_OPEN|AMMO_RECIEVER_TOGGLES_OPEN_EJECTS
	max_chamber_items = 7
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver)

	movement_acc_penalty_mult = 3
	fire_delay = 2
	accuracy_mult_unwielded = 0.85
	scatter_unwielded = 15
	recoil = 0
	recoil_unwielded = 1
	placed_overlay_iconstate = "revolver"
	var/recent_spin = 0

/obj/item/weapon/gun/revolver/examine(mob/user)
	. = ..()
	if(!(reciever_flags & AMMO_RECIEVER_ROTATES_CHAMBER))
		return
	. += span_notice("It's champer can be spun with <b>alt-right-click</b>.")

/obj/item/weapon/gun/revolver/AltRightClick(mob/living/user)
	. = ..()
	do_spin(user)

/obj/item/weapon/gun/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	if(!(reciever_flags & AMMO_RECIEVER_ROTATES_CHAMBER))
		return

	var/mob/user = usr
	if(user.stat || !in_range(user, src))
		return
	do_spin(user)

/obj/item/weapon/gun/revolver/proc/do_spin(mob/user)
	if(!(reciever_flags & AMMO_RECIEVER_ROTATES_CHAMBER))
		return
	if(recent_spin > world.time)
		return
	recent_spin = world.time + 1 SECONDS

	playsound(src, SFX_REVOLVER_SPIN, 30, FALSE)
	visible_message(span_notice("[user] spins [src]'s chamber."), span_notice("You spin [src]'s chamber."))
	balloon_alert(user, "chamber spun")

	var/previous_chamber_position = chamber_items[current_chamber_position]
	chamber_items[current_chamber_position] = in_chamber
	in_chamber = previous_chamber_position
	current_chamber_position = rand(1, max_chamber_items)
	var/previous_chambered_item = in_chamber
	in_chamber = chamber_items[current_chamber_position]
	chamber_items[current_chamber_position] = previous_chambered_item

/obj/item/weapon/gun/revolver/tactical_reload(obj/item/new_magazine, mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated(TRUE) || user.do_actions)
		return
	if(!(new_magazine.type in allowed_ammo_types))
		if(active_attachable)
			active_attachable.tactical_reload(new_magazine, user)
			return
		to_chat(user, span_warning("[new_magazine] cannot fit into [src]!"))
		return
	if(src != user.r_hand && src != user.l_hand && (!master_gun || (master_gun != user.r_hand && master_gun != user.l_hand)))
		to_chat(user, span_warning("[src] must be in your hand to do that."))
		return
	//no tactical reload for the untrained.
	if(user.skills.getRating(SKILL_FIREARMS) < SKILL_FIREARMS_DEFAULT)
		to_chat(user, span_warning("You don't know how to do tactical reloads."))
		return
	to_chat(user, span_notice("You start a tactical reload."))
	var/tac_reload_time = max(0.25 SECONDS, 0.85 SECONDS - user.skills.getRating(SKILL_FIREARMS) * 5)
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)) // if we are really closed
		if(!do_after(user, tac_reload_time * 0.2, IGNORE_USER_LOC_CHANGE, new_magazine) && loc == user)
			return
		unique_gun_open(user)
		update_ammo_count()
		update_icon()
	if(!do_after(user, tac_reload_time, IGNORE_USER_LOC_CHANGE, new_magazine) && loc == user)
		return
	if(new_magazine.item_flags & IN_STORAGE)
		var/obj/item/storage/S = new_magazine.loc
		S.storage_datum.remove_from_storage(new_magazine, get_turf(user), user)
		if(!SEND_SIGNAL(user, COMSIG_MAGAZINE_DROP, new_magazine))
			user.put_in_any_hand_if_possible(new_magazine)
	reload(new_magazine, user)
	if(!do_after(user, tac_reload_time * 0.2, IGNORE_USER_LOC_CHANGE, new_magazine) && loc == user)
		return
	unique_gun_close(user)
	update_ammo_count()
	update_icon()

//-------------------------------------------------------
//R-44 COMBAT REVOLVER

/obj/item/weapon/gun/revolver/r44
	name = "\improper R-44 combat revolver"
	desc = "The R-44 standard combat revolver, produced by Terran Armories. A sturdy and hard hitting firearm that loads .44 Magnum rounds. Holds 7 rounds in the cylinder. Due to an error in the cylinder rotation system the fire rate of the gun is much faster than intended, it ended up being billed as a feature of the system."
	icon_state = "tp44"
	worn_icon_state = "tp44"
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_r44.ogg'
	caliber = CALIBER_44 //codex
	max_chamber_items = 7 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/r44
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/r44)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/b7_scope,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/gyro,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 23, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 19)
	fire_delay = 0.15 SECONDS
	akimbo_additional_delay = 0.6 // Ends up as 0.249, so it'll get moved up to 0.25.
	accuracy_mult_unwielded = 0.85
	accuracy_mult = 1
	scatter = -1
	recoil_unwielded = 0.75

/obj/item/weapon/gun/revolver/r44/Initialize(mapload, spawn_empty)
	. = ..()
	if(round(rand(1, 10), 1) != 1)
		return
	base_gun_icon = "tp44cool"
	update_icon()

/obj/item/weapon/gun/revolver/r44/beginner
	starting_attachment_types = list(/obj/item/attachable/reddot, /obj/item/attachable/compensator, /obj/item/attachable/lasersight)

//-------------------------------------------------------
//RUSSIAN REVOLVER //Based on the 7.62mm Russian revolvers.

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "ny762"
	worn_icon_state = "ny762"
	caliber = CALIBER_762X38 //codex
	max_chamber_items = 7 //codex
	fire_sound = 'sound/weapons/guns/fire/ny.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/upp
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/upp)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 21,"rail_x" = 14, "rail_y" = 23, "under_x" = 24, "under_y" = 19, "stock_x" = 24, "stock_y" = 19)

	damage_mult = 1.05
	scatter_unwielded = 12
	recoil_unwielded = 0

//-------------------------------------------------------
//A generic 357 revolver. With a twist.

/obj/item/weapon/gun/revolver/small
	name = "\improper FFA 'Rebota' revolver"
	desc = "A lean .357 made by Falffearmeria. A timeless design, from antiquity to the future. This one is well known for it's strange ammo, which ricochets off walls constantly. Which went from being a defect to a feature."
	icon_state = "rebota"
	worn_icon_state = "rebota"
	caliber = CALIBER_357 //codex
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/small
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/small)
	force = 6
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 21, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)

	recoil_unwielded = 0


//-------------------------------------------------------
//Mateba is pretty well known. The cylinder folds up instead of to the side. This has a non-marine version and a marine version.

/obj/item/weapon/gun/revolver/mateba
	name = "\improper R-24 'Mateba' autorevolver"
	desc = "The R-24 is the rather rare autorevolver used by the TGMC issued in rather small numbers to backline personnel and officers it uses recoil to spin the cylinder. Uses heavy .454 rounds."
	icon_state = "mateba"
	worn_icon_state = "mateba"
	fire_animation = "mateba_fire"
	muzzleflash_iconstate = "muzzle_flash"
	caliber = CALIBER_454 //codex
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/mateba
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/mateba)
	force = 15
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lace,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 8, "rail_y" = 23, "under_x" = 24, "under_y" = 15, "stock_x" = 22, "stock_y" = 15)

	fire_delay = 0.2 SECONDS
	aim_fire_delay = 0.3 SECONDS
	accuracy_mult = 1.15
	scatter = 0
	accuracy_mult_unwielded = 0.8
	akimbo_additional_delay = 0.9 // Akimbo only gives more shots.
	scatter_unwielded = 7

/obj/item/weapon/gun/revolver/mateba/notmarine
	name = "\improper Mateba autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. Uses .454 rounds."


/obj/item/weapon/gun/revolver/mateba/custom
	name = "\improper R-24 autorevolver special"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. This one appears to have had more love and care put into it. Uses .454 rounds."
	icon_state = "mateba"
	worn_icon_state = "mateba"

//-------------------------------------------------------
//MARSHALS REVOLVER

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB autorevolver"
	desc = "An automatic revolver chambered in .357 magnum. Commonly issued to Nanotrasen security. It has a burst mode. Currently in trial with other revolvers across Terra and other colonies."
	icon_state = "cmb"
	worn_icon_state = "cmb"
	caliber = CALIBER_357 //codex
	max_chamber_items = 6 //codex
	fire_sound = 'sound/weapons/guns/fire/revolver_light.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/cmb
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/cmb)
	force = 12
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 22,"rail_x" = 11, "rail_y" = 25, "under_x" = 20, "under_y" = 18, "stock_x" = 20, "stock_y" = 18)

	fire_delay = 0.15 SECONDS
	scatter_unwielded = 12
	burst_amount = 3
	burst_delay = 0.1 SECONDS
	damage_mult = 1.05

//-------------------------------------------------------
//The Judge, a shotgun and revolver in one

/obj/item/weapon/gun/revolver/judge
	name = "\improper 'Judge' revolver"
	desc = "An incredibly uncommon revolver utilizing a oversized chamber to be able to both fire 45 Long at the cost of firing speed. Normal rounds have no falloff, and next to no scatter. Due to the short barrel, buckshot out of it has high spread."
	icon_state = "judge"
	worn_icon_state = "judge"
	fire_animation = "judge_fire"
	caliber = CALIBER_45L //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/judge
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/revolver/judge,
		/obj/item/ammo_magazine/revolver/judge/buckshot,
	)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 22,"rail_x" = 17, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

	fire_delay = 0.8 SECONDS
	scatter = 8 // Only affects buckshot considering marksman has -15 scatter.
	damage_falloff_mult = 1.2

//-------------------------------------------------------
// The R-76 Magnum. Fires a big round, equal to a slug. Has a windup.

/obj/item/weapon/gun/revolver/standard_magnum
	name = "\improper R-76 KC magnum"
	desc = "The R-76 magnum is an absolute beast of a handgun used by the TGMC, rumors say it was created as a money laundering scheme by some general due to the sheer inpracticality of this firearm. Hits hard, recommended to be used with its stock attachment. Chambered in 12.7mm."
	icon = 'icons/obj/items/gun/pistol64.dmi'
	icon_state = "t76"
	worn_icon_state = "t76"
	fire_animation = "t76_fire"
	caliber = CALIBER_12X7 //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/standard_magnum
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/standard_magnum)
	force = 8
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/stock/t76,
		/obj/item/attachable/scope/standard_magnum,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 15, "rail_y" = 23, "under_x" = 22, "under_y" = 15, "stock_x" = 10, "stock_y" = 18)
	windup_delay = 0.6 SECONDS
	aim_slowdown = 0.2
	windup_sound = 'sound/weapons/guns/fire/t76_start.ogg'
	fire_sound = 'sound/weapons/guns/fire/tgmc/kinetic/gun_r76.ogg'
	fire_delay = 0.75 SECONDS
	akimbo_additional_delay = 1
	accuracy_mult_unwielded = 0.85
	accuracy_mult = 1
	scatter_unwielded = 6
	scatter = 2
	recoil = 3
	recoil_unwielded = 6

	starting_attachment_types = list(/obj/item/attachable/stock/t76)

/obj/item/weapon/gun/revolver/standard_magnum/fancy
	starting_attachment_types = list()
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/stock/t76,
		/obj/item/attachable/scope/standard_magnum,
		/obj/item/attachable/compensator,
	)

/obj/item/weapon/gun/revolver/standard_magnum/fancy/gold
	desc = "A gold plated R-76 magnum, to ensure it's incredibly expensive as well as incredibly impractical. The R-76 magnum is an absolute beast of a handgun used by the TGMC, rumors say it was created as a money laundering scheme by some general due to the sheer inpracticality of this firearm. Hits hard, recommended to be used with its stock attachment. Chambered in 12.7mm."
	icon_state = "g_t76"
	worn_icon_state = "g_t76"
	fire_animation = "g_t76_fire"

/obj/item/weapon/gun/revolver/standard_magnum/fancy/silver
	desc = "A silver plated R-76 magnum, to ensure it's incredibly expensive as well as incredibly impractical. The R-76 magnum is an absolute beast of a handgun used by the TGMC, rumors say it was created as a money laundering scheme by some general due to the sheer inpracticality of this firearm. Hits hard, recommended to be used with its stock attachment. Chambered in 12.7mm."
	icon_state = "s_t76"
	worn_icon_state = "s_t76"
	fire_animation = "s_t76_fire"

/obj/item/weapon/gun/revolver/standard_magnum/fancy/nickle
	desc = "A nickle plated R-76 magnum, for a more tasteful finish. The R-76 magnum is an absolute beast of a handgun used by the TGMC, rumors say it was created as a money laundering scheme by some general due to the sheer inpracticality of this firearm. Hits hard, recommended to be used with its stock attachment. Chambered in 12.7mm."
	icon_state = "n_t76"
	worn_icon_state = "n_t76"
	fire_animation = "n_t76_fire"

//Single action revolvers below
//---------------------------------------------------

/obj/item/weapon/gun/revolver/single_action //This town aint big enuf fer the two of us
	name = "single action revolver"
	desc = "you should not be seeing this."
	reload_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	cocked_sound = 'sound/weapons/guns/interact/revolver_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/revolver/r44
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/r44)
	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_ROTATES_CHAMBER|AMMO_RECIEVER_TOGGLES_OPEN|AMMO_RECIEVER_TOGGLES_OPEN_EJECTS|AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS
	cocked_message = "You prime the hammer."
	cock_delay = 0

//-------------------------------------------------------
//R-44, based off the SAA.

/obj/item/weapon/gun/revolver/single_action/m44
	name = "\improper R-44 SAA revolver"
	desc = "A uncommon revolver occasionally carried by civilian law enforcement that's very clearly based off a modernized Single Action Army. Has to be manully primed with each shot. Uses .44 Magnum rounds."
	icon_state = "m44"
	worn_icon_state = "m44"
	caliber = CALIBER_44 //codex
	max_chamber_items = 6
	default_ammo_type = /obj/item/ammo_magazine/revolver
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver, /obj/item/ammo_magazine/revolver/marksman, /obj/item/ammo_magazine/revolver/heavy)
	force = 8
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 22,"rail_x" = 17, "rail_y" = 22, "under_x" = 22, "under_y" = 17, "stock_x" = 22, "stock_y" = 19)

	fire_delay = 0.15 SECONDS
	damage_mult = 1.1

///////////////////////////////////////////////////////////////////////
//////// Сoltrifle, based on Colt Model 1855 Revolving Rifle. /////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/coltrifle
	name = "\improper M1855 Revolving Rifle"
	desc = "A revolver and carbine hybrid, designed and manufactured a long time ago by Crowford Armory Union. Popular back then, but completely obsolete today. Still used by some antiquity lovers."
	icon = 'icons/obj/items/gun/marksman64.dmi'
	icon_state = "coltrifle"
	worn_icon_state = "coltrifle"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/gun/marksman_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/gun/marksman_righthand_1.dmi',
	)
	fire_animation = "coltrifle_fire"
	fire_sound = 'sound/weapons/guns/fire/mateba.ogg'
	gun_skill_category = SKILL_RIFLES
	equip_slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	caliber = CALIBER_44LS
	max_chamber_items = 8
	default_ammo_type = /obj/item/ammo_magazine/revolver/rifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/revolver/rifle)
	force = 20

	accuracy_mult_unwielded = 0.6
	scatter = 3
	recoil = 0.5
	scatter_unwielded = 10
	recoil_unwielded = 6
	recoil_backtime_multiplier = 2

	fire_delay = 0.25 SECONDS
	aim_fire_delay = 0.25 SECONDS
	akimbo_scatter_mod = 8
	akimbo_additional_delay = 1
	aim_slowdown = 0.3

	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
	)
	attachable_offset = list("muzzle_x" = 50, "muzzle_y" = 21,"rail_x" = 24, "rail_y" = 22)

/obj/item/weapon/gun/revolver/coltrifle/tactical_reload(obj/item/new_magazine, mob/living/carbon/human/user)
	return

//////////////////////////////////////////////////////////////////////////
/////////////////////////// t500 revolver ////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/t500
	name = "\improper R-500 'Nigredo' revolver"
	desc = "The R-500 'Nigredo' revolver, chambered in .500 Nigro Express. Hard to use, but hits as hard as it’s kicks your hand. This handgun made by BMSS, designed to be deadly, unholy force to stop everything what moves, so in exchange for it, revolver lacking recoil control and have tight cocking system. Because of its specific, handcanon niche, was produced in small numbers. Black & Metzer special attachments system can turn extremely powerful handgun to fullscale rifle, making it a weapon to surpass Metal Gear."
	icon = 'icons/obj/items/gun/pistol64.dmi'
	icon_state = "t500"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/gun/pistol_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/gun/pistol_righthand_1.dmi',
	)
	worn_icon_state = "t500"
	caliber =  CALIBER_500 //codex
	max_chamber_items = 5 //codex
	default_ammo_type = /obj/item/ammo_magazine/revolver/t500
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/revolver/t500,
		/obj/item/ammo_magazine/revolver/t500/slavs,
	)
	force = 20
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/t500,
		/obj/item/attachable/t500_barrel/short,
		/obj/item/attachable/t500_barrel,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lace/t500,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	attachable_offset = list("muzzle_x" = 0, "muzzle_y" = 0,"rail_x" = 10, "rail_y" = 20, "under_x" = 19, "under_y" = 13, "stock_x" = -19, "stock_y" = 0)
	windup_delay = 0.8 SECONDS
	windup_sound = 'sound/weapons/guns/fire/t500_start.ogg'
	fire_sound = 'sound/weapons/guns/fire/t500.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/t500_empty.ogg'
	fire_animation = "t500_fire"
	fire_delay = 0.8 SECONDS
	akimbo_additional_delay = 0.6
	accuracy_mult_unwielded = 0.9
	accuracy_mult = 1
	scatter_unwielded = 5
	scatter = -1
	recoil = 2
	recoil_unwielded = 3

//////////////////////////////////////////////////////////////////////////
/////////////////////////// t312 revolver ////////////////////////////////
//////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/revolver/t312
	name = "R-312 'Albedo' Revolver"
	desc = "Futuristic style revolver with railgun system, using to fire EMB (experimental medical bullets). Just first make sure that you chambered EMB, but not .500 White Express."
	icon = 'icons/obj/items/gun/pistol64.dmi'
	icon_state = "t312"
	worn_icon_state = "t312"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/gun/pistol_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/gun/pistol_righthand_1.dmi',
	)
	caliber =  CALIBER_500_EMB
	max_chamber_items = 5 //codex
	default_ammo_type = /datum/ammo/bullet/revolver/t312
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/revolver/t312,
		/obj/item/ammo_magazine/revolver/t312/med/adrenaline,
		/obj/item/ammo_magazine/revolver/t312/med/rr,
		/obj/item/ammo_magazine/revolver/t312/med/md,
		/obj/item/ammo_magazine/revolver/t312/med/neu
	)
	force = 20
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/lace/t500,
	)
	attachable_offset = list("stock_x" = -19, "stock_y" = 0)
	fire_sound = 'sound/weapons/guns/fire/t312.ogg'
	dry_fire_sound = 'sound/mecha/mag_bullet_insert.ogg'
	fire_animation = "t312_fire"
	fire_delay = 0.2 SECONDS
	scatter = -7
	scatter_unwielded = -5
	damage_mult = 0.35
	recoil = -1
	recoil_unwielded = -1
	accuracy_mult = 3
	accuracy_mult_unwielded = 2
	type_of_casings = null
	akimbo_additional_delay = 0.6
	reciever_flags = AMMO_RECIEVER_HANDFULS|AMMO_RECIEVER_TOGGLES_OPEN


/obj/item/weapon/gun/revolver/t312/able_to_fire(mob/user)
	. = ..()
	if(!.)
		return
	if(user.skills.getRating(SKILL_MEDICAL) < SKILL_MEDICAL_PRACTICED)
		to_chat(user, span_warning("You don't seem to know how to use [src]..."))
		return FALSE
