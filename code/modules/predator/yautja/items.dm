//Items specific to yautja. Other people can use em, they're not restricted or anything.
//They can't, however, activate any of the special functions.
//Thrall subtypes are located in /code/modules/predator/thrall_items.dm

/proc/add_to_missing_pred_gear(obj/item/W)
	if(!is_centcom_level(W.z))
		GLOB.loose_yautja_gear |= W

/proc/remove_from_missing_pred_gear(obj/item/W)
	GLOB.loose_yautja_gear -= W

//=================//\\=================\\
//======================================\\

/*
				EQUIPMENT
*/

//======================================\\
//=================\\//=================\\

/obj/item/clothing/suit/armor/yautja
	name = "ancient alien armor"
	desc = "Ancient armor made from a strange alloy. It feels cold with an alien weight."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "halfarmor1_ebony"
	worn_icon_state = "armor"
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/hunter/pred_gear.dmi'
	)

	attachments_by_slot = list(
		ACCESSORY_SLOT_ARMOR_Y_C,
		ACCESSORY_SLOT_ARMOR_Y_S,
		ACCESSORY_SLOT_ARMOR_Y_H,
		ACCESSORY_SLOT_ARMOR_Y_RL,
		ACCESSORY_SLOT_ARMOR_Y_LL,
		ACCESSORY_SLOT_ARMOR_Y_RH,
		ACCESSORY_SLOT_ARMOR_Y_LH,
	)
	attachments_allowed = list(
		/obj/item/armor_module/limb/skeleton/l_arm,
		/obj/item/armor_module/limb/skeleton/l_foot,
		/obj/item/armor_module/limb/skeleton/l_hand,
		/obj/item/armor_module/limb/skeleton/l_leg,
		/obj/item/armor_module/limb/skeleton/r_arm,
		/obj/item/armor_module/limb/skeleton/r_foot,
		/obj/item/armor_module/limb/skeleton/r_hand,
		/obj/item/armor_module/limb/skeleton/r_leg,
		/obj/item/armor_module/limb/skeleton/head,
		/obj/item/armor_module/limb/skeleton/head/spine,
		/obj/item/armor_module/limb/skeleton/torso,
	)

	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 20, FIRE = 20, ACID = 20)

	armor_protection_flags = CHEST|GROIN|ARMS
	item_flags = ITEM_PREDATOR
	inventory_flags = NONE
	slowdown = 0
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.1
	allowed = list(
		/obj/item/weapon/harpoon,
		/obj/item/weapon/gun/energy/yautja,
		/obj/item/weapon/yautja,
		/obj/item/weapon/twohanded/yautja,
	)
	resistance_flags = UNACIDABLE
	worn_worn_icon_state_slots = list(slot_wear_suit_str = "halfarmor1")
	/// Used to affect icon generation.
	var/thrall = FALSE

/obj/item/clothing/suit/armor/yautja/Initialize(mapload, armor_number = rand(1,7), armor_material = "ebony", legacy = "None")
	. = ..()
	if(thrall)
		return

	cold_protection_flags = armor_protection_flags
	heat_protection_flags = armor_protection_flags

	if(legacy != "None")
		switch(legacy)
			if("Dragon")
				name = "\improper 'Armor of the Dragon'"
				icon_state = "halfarmor_elder_tr"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor_elder_tr")
				return
			if("Swamp")
				name = "\improper 'Armor of the Swamp Horror'"
				icon_state = "halfarmor_elder_joshuu"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor_elder_joshuu")
				return
			if("Enforcer")
				name = "\improper 'Armor of the Enforcer'"
				icon_state = "halfarmor_elder_feweh"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor_elder_feweh")
				return
			if("Collector")
				name = "\improper 'Armor of the Ambivalent Collector'"
				icon_state = "halfarmor_elder_n"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor_elder_n")
				return
			else
				name = "clan elder's armor"
				icon_state = "halfarmor_elder"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor_elder")
				return

	if(armor_number > 7)
		armor_number = 1
	if(armor_number) //Don't change full armor number
		icon_state = "halfarmor[armor_number]_[armor_material]"
		LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "halfarmor[armor_number]_[armor_material]")

/obj/item/clothing/suit/armor/yautja/hunter
	name = "clan armor"
	desc = "A suit of armor with light padding. It looks old, yet functional."

	soft_armor = list(MELEE = 15, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)

/obj/item/clothing/suit/armor/yautja/hunter/pred
	anchored = TRUE
	color = "#FFE55C"
	icon_state = "halfarmor_elder_joshuu"

/obj/item/clothing/suit/armor/yautja/hunter/full
	name = "heavy clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon_state = "fullarmor_ebony"
	armor_protection_flags = CHEST|GROIN|ARMS|HEAD|LEGS
	item_flags = ITEM_PREDATOR

	soft_armor = list(MELEE = 40, BULLET = 30, LASER = 35, ENERGY = 35, BOMB = 45, BIO = 40, FIRE = 30, ACID = 30)
	slowdown = 0.7
	worn_worn_icon_state_slots = list(slot_wear_suit_str = "fullarmor")
	allowed = list(
		/obj/item/weapon/harpoon,
		/obj/item/weapon/gun/energy/yautja,
		/obj/item/weapon/yautja,
		/obj/item/storage/belt/yautja,
		/obj/item/weapon/twohanded/yautja,
	)

/obj/item/clothing/suit/armor/yautja/hunter/full/Initialize(mapload, armor_number, armor_material = "ebony")
	. = ..(mapload, 0)
	icon_state = "fullarmor_[armor_material]"
	LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "fullarmor_[armor_material]")

/obj/item/clothing/yautja_cape
	name = PRED_YAUTJA_CAPE
	desc = "A battle-worn cape passed down by elder Yautja."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "fullcape"
	worn_icon_list = list(
		slot_back_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	equip_slot_flags = ITEM_SLOT_BACK
	item_flags = ITEM_PREDATOR
	resistance_flags = UNACIDABLE
	var/clan_rank_required = CLAN_RANK_ELDER_INT
	var/councillor_override = FALSE

/obj/item/clothing/yautja_cape/Initialize(mapload, new_color = "#654321")
	. = ..()
	color = new_color

/obj/item/clothing/yautja_cape/dropped(mob/living/user)
	add_to_missing_pred_gear(src)
	return ..()

/obj/item/clothing/yautja_cape/pickup(mob/living/user)
	if(isyautja(user))
		remove_from_missing_pred_gear(src)
	return ..()

/obj/item/clothing/yautja_cape/Destroy()
	. = ..()
	remove_from_missing_pred_gear(src) // after due to item handling calling dropped()

/obj/item/clothing/yautja_cape/ceremonial
	name = PRED_YAUTJA_CEREMONIAL_CAPE
	icon_state = "ceremonialcape"
	clan_rank_required = CLAN_RANK_ELDER_INT

/obj/item/clothing/yautja_cape/third
	name = PRED_YAUTJA_THIRD_CAPE
	icon_state = "thirdcape"
	clan_rank_required = CLAN_RANK_ELDER_INT

/obj/item/clothing/yautja_cape/half
	name = PRED_YAUTJA_HALF_CAPE
	icon_state = "halfcape"
	clan_rank_required = CLAN_RANK_BLOODED_INT

/obj/item/clothing/yautja_cape/quarter
	name = PRED_YAUTJA_QUARTER_CAPE
	icon_state = "quartercape"
	clan_rank_required = CLAN_RANK_BLOODED_INT

/obj/item/clothing/yautja_cape/poncho
	name = PRED_YAUTJA_PONCHO
	icon_state = "councilor_poncho"
	clan_rank_required = CLAN_RANK_BLOODED_INT

/obj/item/clothing/shoes/marine/yautja
	name = "ancient alien greaves"
	desc = "Greaves made from scraps of cloth and a strange alloy. They feel cold with an alien weight."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_list = list(
		slot_shoes_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	icon_state = "y-boots1_ebony"

	resistance_flags = UNACIDABLE
	permeability_coefficient = 0.01
	inventory_flags = NOSLIPPING
	armor_protection_flags = FEET|LEGS
	item_flags = ITEM_PREDATOR

	siemens_coefficient = 0.2
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

	soft_armor = list(MELEE = 15, BULLET = 25, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 20, FIRE = 20, ACID = 20)
	var/thrall = FALSE//Used to affect icon generation.

/obj/item/clothing/shoes/marine/yautja/Initialize(mapload, boot_number = rand(1,4), armor_material = "ebony")
	. = ..()
	if(thrall)
		return
	if(boot_number > 4)
		boot_number = 1
	icon_state = "y-boots[boot_number]_[armor_material]"

	cold_protection_flags = armor_protection_flags
	heat_protection_flags = armor_protection_flags

/obj/item/clothing/shoes/marine/yautja/update_icon_state()
	return

/obj/item/clothing/shoes/marine/yautja/hunter
	name = "clan greaves"
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."

	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)

/obj/item/clothing/shoes/marine/yautja/hunter/pred
	color = "#FFE55C"
	icon_state = "y-boots2"
	anchored = TRUE

/obj/item/clothing/shoes/marine/yautja/hunter/knife
	knife_to_add = /obj/item/weapon/yautja/knife

/obj/item/clothing/under/chainshirt
	name = "ancient alien mesh suit"
	desc = "A strange alloy weave in the form of a vest. It feels cold with an alien weight."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "mesh_shirt"
	worn_icon_list = list(
		slot_w_uniform_str = 'icons/mob/hunter/pred_gear.dmi'
	)

	armor_protection_flags = CHEST|GROIN|ARMS
	cold_protection_flags = CHEST|GROIN|LEGS|ARMS|FEET|HANDS //Does not cover the head though.
	heat_protection_flags = CHEST|GROIN|LEGS|ARMS|FEET|HANDS
	item_flags = ITEM_PREDATOR
	has_sensor = 0
	sensor_mode = 0
	siemens_coefficient = 0.9
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 20, FIRE = 20, ACID = 20)

/obj/item/clothing/under/chainshirt/hunter
	name = "body mesh"
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."

	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)
	resistance_flags = UNACIDABLE

//=================//\\=================\\
//======================================\\

/*
				GEAR
*/

//======================================\\
//=================\\//=================\\

//Yautja channel. Has to delete stock encryption key so we don't receive sulaco channel.
/obj/item/radio/headset/yautja
	name = "\improper Communicator"
	desc = "A strange Yautja device used for projecting the Yautja's voice to the others in its pack. Similar in function to a standard human radio."
	icon_state = "communicator"
	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_state = "headset"
	frequency = YAUT_FREQ
	keyslot = /obj/item/encryptionkey/yautja
	freqlock = TRUE
	independent = TRUE
	resistance_flags = UNACIDABLE
	var/no_radio_override = TRUE

/obj/item/radio/headset/yautja/set_frequency(new_frequency)
	if(no_radio_override)
		new_frequency = YAUT_FREQ
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)

/obj/item/radio/headset/yautja/attack_self(mob/living/user)
	return //no cargo shitcode

/obj/item/radio/headset/yautja/talk_into(atom/movable/talking_movable, message, channel, list/spans, datum/language/language, list/message_mods)
	if(!isyautja(talking_movable)) //Nope.
		to_chat(talking_movable, span_warning("You try to talk into the headset, but just get a horrible shrieking in your ears!"))
		return

	for(var/mob/living/carbon/xenomorph/hellhound/hellhound as anything in GLOB.hellhound_list)
		if(!hellhound.stat)
			to_chat(hellhound, "\[Radio\]: [talking_movable], '<B>[message]</b>'.")
	return ..()

/obj/item/radio/headset/yautja/attackby()
	return

/obj/item/radio/headset/yautja/elder //primarily for use in another MR
	name = "\improper Elder Communicator"

/obj/item/encryptionkey/yautja
	name = "\improper Yautja encryption key"
	desc = "A complicated encryption device."
	icon_state = "cypherkey"
	channels = list(RADIO_CHANNEL_YAUTJA = TRUE)

/obj/item/storage/belt/yautja
	name = "hunting pouch"
	desc = "A Yautja hunting pouch worn around the waist, made from a thick tanned hide. Capable of holding various devices and tools and used for the transport of trophies."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "beltbag"
	worn_icon_state = "beltbag_w"
	worn_icon_list = list(
		slot_belt_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	item_flags = ITEM_PREDATOR

/obj/item/storage/belt/yautja/Initialize(mapload, ...)
	. = ..()
	storage_datum.max_w_class = WEIGHT_CLASS_BULKY
	storage_datum.storage_slots = 12
	storage_datum.max_storage_space = 30

/obj/item/yautja_teleporter
	name = "relay beacon"
	desc = "A device covered in sacred text. It whirrs and beeps every couple of seconds."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "teleporter"
	item_flags = ITEM_PREDATOR
	atom_flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	resistance_flags = UNACIDABLE

/obj/item/yautja_teleporter/attack_self(mob/user)
	. = ..()

	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH) || is_centcom_level(user.z))
		to_chat(user, span_warning("You fiddle with it, but nothing happens!"))
		return

	var/mob/living/carbon/human/H = user
	var/ship_to_tele = list("Yautja Ship" = -1, "Human Ship" = "Human") // what the fuck is this piece of crap

	if(H.client && H.client.clan_info)
		if(H.client.clan_info.item[3] & CLAN_PERMISSION_ADMIN_VIEW)
			var/datum/db_query/clans = SSdbcore.NewQuery("SELECT id, name, description, honor, color FROM [format_table_name("clan")]")
			clans.Execute()
			while(clans.NextRow())
				if(!SSpredships.is_clanship_loaded(clans.item[1]))
					continue
				ship_to_tele += list("[clans.item[2]]" = clans.item[1])

		if(SSpredships.is_clanship_loaded(H.client.clan_info.item[4]))
			ship_to_tele += list("Your clan" = "[H.client.clan_info.item[4]]")

	var/clan = ship_to_tele[tgui_input_list(H, "Select a ship to teleport to", "[src]", ship_to_tele)]
	if(clan != "Human" && !SSpredships.is_clanship_loaded(clan))
		return // Checking ship is valid

	// Getting an arrival point
	var/turf/target_turf
	if(clan == "Human")
		var/obj/effect/landmark/yautja_teleport/pickedYT = pick(GLOB.mainship_yautja_teleports)
		target_turf = get_turf(pickedYT)
	else
		target_turf = SAFEPICK(SSpredships.get_clan_spawnpoints(clan))
	if(!target_turf)
		return

	// Let's go
	playsound(src, 'sound/ambience/signal.ogg', 25, 1, sound_range = 6)
	user.visible_message(span_info("[user] starts becoming shimmery and indistinct..."))

	if(!do_after(user, 10 SECONDS, NONE, src, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
		return
	// Display fancy animation for you and the person you might be pulling (Legacy)
	user.visible_message(span_warning("[icon2html(user, viewers(src))][user] disappears!"))
	animation_teleport_quick_out(user)
	SEND_SIGNAL(H, COMSIG_ATOM_TELEPORT, src)
	var/mob/living/pulled_mob = user.pulling
	if(pulled_mob) // Pulled person
		SEND_SIGNAL(pulled_mob, COMSIG_ATOM_TELEPORT, src)
		pulled_mob.visible_message(span_warning("[icon2html(pulled_mob, viewers(src))][pulled_mob] disappears!"))
		animation_teleport_quick_out(pulled_mob)

	addtimer(CALLBACK(src, PROC_REF(teleport), target_turf, user, pulled_mob), 1 SECONDS)

/obj/item/yautja_teleporter/proc/teleport(turf/target_turf, mob/user, mob/pulled_mob)
	user.trainteleport(target_turf) // Actually teleports everyone, not just you + pulled

	// Undo animations
	animation_teleport_quick_in(user)
	if(pulled_mob)
		animation_teleport_quick_in(pulled_mob)

/obj/item/yautja_teleporter/verb/add_tele_loc()
	set name = "Add Teleporter Destination"
	set desc = "Adds this location to the teleporter."
	set category = "Yautja"
	set src in usr
	if(!usr || usr.stat || !is_ground_level(usr.z))
		return FALSE

	if(istype(usr.buckled, /obj/structure/bed/nest/))
		return FALSE

	if(!HAS_TRAIT(usr, TRAIT_YAUTJA_TECH))
		to_chat(usr, span_warning("You have no idea how this thing works!"))
		return FALSE

	if(loc && istype(usr.loc, /turf))
		var/turf/location = usr.loc
		GLOB.yautja_teleports += location
		var/name = input("What would you like to name this location?", "Text") as null|text
		if(!name)
			return FALSE
		GLOB.yautja_teleport_descs[name + " ([location.x], [location.y], [location.z])"] = location
		to_chat(usr, span_warning("You can now teleport to this location!"))
		log_game("[usr] ([usr.key]) has created a new teleport location at [get_area(usr)]")
		message_all_yautja("[usr.real_name] has created a new teleport location, [name], at [usr.loc] in [get_area(usr)]")
		return TRUE

//=================//\\=================\\
//======================================\\

/*
				OTHER THINGS
*/

//======================================\\
//=================\\//=================\\

/obj/item/scalp
	name = "scalp"
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "scalp_1"
	worn_icon_state = "scalp"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)
	appearance_flags = NONE //So that the blood overlay renders separately and isn't affected by the hair color matrix.
	var/true_desc = "This is the scalp of a" //humans and Yautja see different things when examining these.

/obj/item/scalp/Initialize(mapload, mob/living/carbon/human/scalpee, mob/living/carbon/human/user)
	. = ..()

	var/variant = rand(1, 4) //Random sprite variant.
	icon_state = "scalp_[variant]"
	blood_color =  "#A10808" //So examine describes it as 'bloody'. Synths can't be scalped so it'll always be human blood.
	atom_flags = NOBLOODY //Don't want the ugly item blood overlay ending up on this. We'll use our own blood overlay.

	var/image/blood_overlay = image('icons/obj/hunter/pred_gear.dmi', "scalp_[variant]_blood")
	blood_overlay.appearance_flags = RESET_COLOR
	overlays += blood_overlay

	if(!scalpee) //Presumably spawned as map decoration.
		true_desc = "This is the scalp of an irrelevant human."
		color = list(null, null, null, null, rgb(rand(0,255), rand(0,255), rand(0,255)))
		return

	name = "\proper [scalpee.real_name]'s scalp"
	color = list(null, null, null, null, rgb(scalpee.r_hair, scalpee.g_hair, scalpee.b_hair)) //Hair color.

	var/they = "they"
	var/their = "their"
	var/them = "them"
	var/themselves = "themselves"

	//Gender?
	switch(scalpee.gender)
		if(MALE)
			their = "his"
			they = "he"
			them = "him"
			themselves = "himself"

		if(FEMALE)
			their = "her"
			they = "she"
			them = "her"
			themselves = "herself"

	//What did this person do?
	var/list/biography = list()
	//Did they disgrace themselves more than humans usually do?
	var/dishonourable = FALSE
	//Did they distinguish themselves?
	var/honourable = FALSE

	if(scalpee.hunter_data.thralled)
		biography += "enthralled by [scalpee.hunter_data.thralled_set.real_name] for '[scalpee.hunter_data.thralled_reason]'"
		honourable = TRUE

	if(scalpee.hunter_data.honored)
		biography += "honored for '[scalpee.hunter_data.honored_reason]'"
		honourable = TRUE

	if(scalpee.hunter_data.dishonored)
		biography +=  "marked as dishonorable for '[scalpee.hunter_data.dishonored_reason]'"
		dishonourable = TRUE

	if(scalpee.hunter_data.gear)
		biography +=  "killed after [scalpee.hunter_data.gear_set.real_name] marked [them] as a thief of Yautja equipment"
		dishonourable = TRUE

	//How impressive a trophy is this?
	var/worth = 1
	switch(scalpee.life_kills_total)
		if(0)
			if(dishonourable)
				true_desc += " human who was even more shameful than usual."
				worth = -1
			else if(honourable) //They weren't marked as killing anyone but otherwise distinguished themselves.
				true_desc += " human."
			else
				true_desc += "n irrelevant human."
				worth = 0

		if(1 to 4)
			if(dishonourable)
				true_desc += " human who could have been worthy, had [they] not insisted on disgracing [themselves]."
				worth = -1
			else
				true_desc += " respectable human with blood on [their] hands."

		if(5 to 9)
			true_desc += "n uncommonly destructive human."
			if(!dishonourable)
				worth = 2 //Even if they did do something dishonourable, this person is worth at least grudging respect.

		if(10 to INFINITY)
			true_desc += " truly worthy human, no doubt descended from many storied warriors. [capitalize(their)] arms were soaked to the elbows with the life-blood of many."
			worth = 2

	if(length(biography))
		true_desc += " [scalpee.real_name] was [english_list(biography, final_comma_text = ",")]."

	if(scalpee.hunter_data.hunter == user) //You don't get your name on it unless you hunted them yourself.
		if(scalpee.hunter_data.automatic_target && scalpee.hunter_data.targeted == user)
			scalpee.hunter_data.complete_target(user)

		switch(worth)
			if(-1)
				true_desc += span_blue("\n[user.real_name] had the unpleasant duty of running [them] to ground.")
			if(0) //You hunted someone with no kills for no real reason.
				true_desc += span_blue("\nAn honourable first trophy for a truly precocious child. [user.real_name]'s parents must be so proud.")
			if(1)
				true_desc += span_blue("\nThis trophy was taken by [user.real_name] after a successful hunt.")
			if(2)
				true_desc += span_blue("\nThis fine trophy was taken by [user.real_name] after a successful hunt.")

/obj/item/scalp/examine(mob/user)
	. = ..()
	if(isyautja(user) || isobserver(user))
		. += true_desc
	else
		. += span_warning("Scalp-collecting is supposed to be a <i>joke</i>. Has someone been going around doing this shit for real? What next, a necklace of severed ears? Jesus Christ.")

/obj/item/explosive/grenade/spawnergrenade/hellhound
	name = "hellhound caller"
	spawner_type = /mob/living/carbon/xenomorph/hellhound
	force = 20
	throwforce = 40
	deliveryamt = 1
	desc = "A strange piece of alien technology. It seems to call forth a hellhound."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "hellnade"
	w_class = WEIGHT_CLASS_TINY
	det_time = 3 SECONDS
	var/obj/machinery/camera/current = null
	var/turf/activated_turf = null

/obj/item/explosive/grenade/spawnergrenade/hellhound/dropped(mob/user)
	check_eye(user)
	return ..()

/obj/item/explosive/grenade/spawnergrenade/hellhound/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!active)
		if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
			to_chat(user, span_warning("What's this thing?"))
			return
		to_chat(user, span_warning("You activate the hellhound beacon!"))
		activate(user)
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.toggle_throw_mode()

/obj/item/explosive/grenade/spawnergrenade/hellhound/activate(mob/user)
	if(active)
		return

	if(user)
		log_attack("[key_name(user)] primed \a [src] in [get_area(user)] ([user.loc.x],[user.loc.y],[user.loc.z]).")
	icon_state = initial(icon_state) + "_active"
	active = 1
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(prime)), det_time)

/obj/item/explosive/grenade/spawnergrenade/hellhound/prime()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		if(ispath(spawner_type))
			new spawner_type(T)
		qdel(src)
	return

/obj/item/explosive/grenade/spawnergrenade/hellhound/check_eye(mob/living/user)
	if(user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		user.unset_interaction()
	else if (!current || get_turf(user) != activated_turf || src.loc != user ) //camera doesn't work, or we moved.
		user.unset_interaction()

/obj/item/explosive/grenade/spawnergrenade/hellhound/on_set_interaction(mob/user)
	. = ..()
	user.reset_perspective(current)

/obj/item/explosive/grenade/spawnergrenade/hellhound/on_unset_interaction(mob/user)
	. = ..()
	current = null
	user.reset_perspective(null)

/obj/item/weapon/sword/ceremonial
	name = "Ceremonial Sword"
	desc = "A fancy ceremonial sword passed down from generation to generation. Despite this, it has been very well cared for, and is in top condition."
	icon_state = "officer_sword"
	worn_icon_state = "officer_sword"

// Hunting traps
/obj/item/hunting_trap
	name = "hunting trap"
	throw_speed = 6.67
	throw_range = 2
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "yauttrap0"
	desc = "A bizarre Yautja device used for trapping and killing prey."

	layer = LOW_ITEM_LAYER

	var/armed = 0
	var/resist_time = 15 SECONDS
	var/obj/effect/ebeam/beam
	var/tether_range = 5
	var/mob/trapped_mob

/obj/item/hunting_trap/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/hunting_trap/Destroy()
	cleanup_tether()
	return ..()

/obj/item/hunting_trap/dropped(mob/living/carbon/human/mob) //Changes to "camouflaged" icons based on where it was dropped.
	if(armed && isturf(mob.loc))
		var/turf/T = mob.loc
		if(istype(T,/turf/open/floor/plating/ground/dirt))
			icon_state = "yauttrapdirt"
		else if (istype(T,/turf/open/ground/jungle))
			icon_state = "yauttrapgrass"
		else
			icon_state = "yauttrap1"
	return ..()

/obj/item/hunting_trap/attack_self(mob/user as mob)
	. = ..()
	if(ishuman(user) && !user.stat && !user.restrained())
		var/wait_time = 3 SECONDS
		if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
			wait_time = rand(5 SECONDS, 10 SECONDS)
		if(!do_after(user, wait_time, NONE, src, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE))
			return
		armed = TRUE
		anchored = TRUE
		icon_state = "yauttrap[armed]"
		to_chat(user, span_notice("[src] is now armed."))
		log_attack("[key_name(user)] has armed \a [src] at [ADMIN_JMP_USER(user)].")
		user.drop_held_item()

/obj/item/hunting_trap/attack_hand(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		disarm(user)
	//Humans and synths don't know how to handle those traps!
	if((issynth(user) || ishuman(user)) && armed)
		to_chat(user, span_warning("You foolishly reach out for \the [src]..."))
		trapMob(user)
		return
	return ..()

/obj/item/hunting_trap/proc/trapMob(mob/living/carbon/C)
	if(!armed)
		return

	armed = FALSE
	anchored = TRUE

	trapped_mob = C
	ADD_TRAIT(C, TRAIT_LEASHED, src)
	beam = beam(C, "chain", 'icons/effects/beam.dmi', INFINITY, INFINITY)
	RegisterSignal(C, COMSIG_LIVING_DO_RESIST, PROC_REF(resist_callback))
	RegisterSignal(C, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_dist))

	icon_state = "yauttrap0"
	playsound(C,'sound/weapons/tablehit1.ogg', 25, 1)
	to_chat(C, "[icon2html(src, C)] \red <B>You get caught in \the [src]!</B>")

	log_attack("[key_name(C)] was caught in \a [src] at [ADMIN_JMP_USER(C)].")

	if(ishuman(C))
		C.emote("pain")
	if(isxeno(C))
		var/mob/living/carbon/xenomorph/X = C
		C.emote("needhelp")
		X.interference = 100 // Some base interference to give pred time to get some damage in, if it cannot land a single hit during this time pred is cheeks
	message_all_yautja("A hunting trap has caught something in [get_area_name(loc)]!")

/obj/item/hunting_trap/proc/on_cross(turf/passed, atom/movable/AM)
	if(!isliving(AM))
		return
	if(CHECK_MULTIPLE_BITFIELDS(AM.pass_flags, HOVERING))
		return
	var/mob/living/L = AM
	if(L.lying_angle || L.buckled) ///so dragged corpses don't trigger mines.
		return

	if(armed)
		if(isturf(src.loc))
			var/mob/living/carbon/H = L
			if(isyautja(H))
				to_chat(H, span_notice("You carefully avoid stepping on the trap."))
			else
				trapMob(H)
				for(var/mob/O in viewers(H, null))
					if(O == H)
						continue
					O.show_message(span_warning("[icon2html(src, O)] <B>[H] gets caught in \the [src].</B>"), EMOTE_VISIBLE)
		else if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot))
			armed = FALSE
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20

/obj/item/hunting_trap/proc/check_dist(datum/victim, atom/newloc)
	SIGNAL_HANDLER
	if(get_dist(newloc, src) >= tether_range)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/obj/item/hunting_trap/proc/resist_callback()
	SIGNAL_HANDLER

	if(isnull(beam))
		return

	INVOKE_ASYNC(src, PROC_REF(resisted))

/obj/item/hunting_trap/proc/resisted()
	to_chat(trapped_mob, span_danger("You attempt to break out of your tether to [src]. (This will take around [resist_time * 0.1] seconds and you need to stand still)"))
	if(!do_after(trapped_mob, resist_time, NONE, src, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE))
		return
	to_chat(trapped_mob, span_warning("You have broken out of your tether to [src]!"))
	cleanup_tether()

/obj/item/hunting_trap/proc/cleanup_tether()
	if(trapped_mob)
		UnregisterSignal(trapped_mob, COMSIG_MOVABLE_PRE_MOVE)
		REMOVE_TRAIT(trapped_mob, TRAIT_LEASHED, src)
		trapped_mob = null
		QDEL_NULL(beam)

/obj/item/hunting_trap/proc/disarm(mob/user)
	SIGNAL_HANDLER
	armed = FALSE
	anchored = FALSE
	icon_state = "yauttrap[armed]"
	if(user)
		to_chat(user, span_notice("[src] is now disarmed."))
		log_attack("[key_name(user)] has disarmed \a [src] at [ADMIN_JMP_USER(user)].")
	cleanup_tether()

/obj/item/hunting_trap/verb/configure_trap()
	set name = "Configure Hunting Trap"
	set category = "IC.Object"

	var/mob/living/carbon/human/H = usr
	if(!HAS_TRAIT(H, TRAIT_YAUTJA_TECH))
		to_chat(H, span_warning("You do not know how to configure the trap."))
		return
	var/range = tgui_input_list(H, "Which range would you like to set the hunting trap to?", "Hunting Trap Range", list(2, 3, 4, 5, 6, 7))
	if(isnull(range))
		return
	tether_range = range
	to_chat(H, span_notice("You set the hunting trap's tether range to [range]."))

//flavor armor & greaves, not a subtype
/obj/item/clothing/suit/armor/yautja_flavor
	name = "alien stone armor"
	desc = "A suit of armor made entirely out of stone. Looks incredibly heavy."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	worn_icon_state = "armor"
	icon_state = "fullarmor_ebony"

	armor_protection_flags = CHEST|GROIN|ARMS|HEAD|LEGS
	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	siemens_coefficient = 0.1
	allowed = list(
		/obj/item/weapon/harpoon,
		/obj/item/weapon/gun/energy/yautja,
		/obj/item/weapon/yautja,
		/obj/item/weapon/twohanded/yautja,
	)
	resistance_flags = UNACIDABLE
	worn_worn_icon_state_slots = list(slot_wear_suit_str = "fullarmor_ebony")

/obj/item/clothing/shoes/yautja_flavor
	name = "alien stone greaves"
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through cement because they're incredibly heavy."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_list = list(
		slot_shoes_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	icon_state = "y-boots2_ebony"

	resistance_flags = UNACIDABLE
	armor_protection_flags = FEET|LEGS|GROIN
	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)

/obj/item/card/id/bracer_chip
	name = "bracer ID chip"
	desc = "A complex cypher chip embedded within a set of clan bracers."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "upp_key"
	access = list(ACCESS_YAUTJA_SECURE)
	w_class = WEIGHT_CLASS_TINY
	item_flags = ITEM_PREDATOR
	paygrade = null

/obj/item/card/id/bracer_chip/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)

/obj/item/card/id/bracer_chip/set_user_data(mob/living/carbon/human/human_user)
	if(!istype(human_user))
		return

	registered_name = human_user.real_name
	blood_type = human_user.blood_type

	var/list/new_access = list(ACCESS_YAUTJA_SECURE)
	var/obj/item/clothing/gloves/yautja/hunter/bracer = loc
	if(istype(bracer) && bracer.owner_rank)
		switch(bracer.owner_rank)
			if(CLAN_RANK_ELDER_INT, CLAN_RANK_LEADER_INT)
				new_access = list(ACCESS_YAUTJA_SECURE, ACCESS_YAUTJA_ELDER)
			if(CLAN_RANK_ADMIN_INT)
				new_access = list(ACCESS_YAUTJA_SECURE, ACCESS_YAUTJA_ELDER, ACCESS_YAUTJA_ANCIENT)
	access = new_access

/obj/item/storage/medicomp
	name = "medicomp"
	desc = "A complex kit of alien tools and medicines."
	icon_state = "medicomp"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ITEM_PREDATOR

/obj/item/storage/medicomp/full/Initialize(mapload, ...)
	. = ..()
	storage_datum.use_sound = "toolbox"
	storage_datum.storage_slots = 16
	storage_datum.max_storage_space = 17
	storage_datum.set_holdable(can_hold_list = list(
		/obj/item/tool/surgery/stabilizer_gel,
		/obj/item/tool/surgery/healing_gun,
		/obj/item/tool/surgery/wound_clamp,
		/obj/item/reagent_containers/hypospray/autoinjector/yautja,
		/obj/item/healthanalyzer/alien,
		/obj/item/tool/surgery/healing_gel,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack/predator,
		/obj/item/stack/medical/heal_pack/ointment/predator,
	))

/obj/item/storage/medicomp/full/PopulateContents()
	new /obj/item/tool/surgery/stabilizer_gel(src)
	new /obj/item/tool/surgery/healing_gun(src)
	new /obj/item/tool/surgery/wound_clamp(src)
	new /obj/item/healthanalyzer/alien(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/yautja(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/yautja(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/yautja(src)
	new /obj/item/tool/surgery/healing_gel/(src)
	new /obj/item/tool/surgery/healing_gel/(src)
	new /obj/item/tool/surgery/healing_gel/(src)

/obj/item/storage/medicomp/update_icon()
	. = ..()
	if(!contents.len)
		icon_state = "medicomp_open"
	else
		icon_state = "medicomp"

/obj/item/reagent_containers/glass/rag/polishing_rag
	name = "polishing rag"
	desc = "An astonishingly fine, hand-tailored piece of exotic cloth."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "polishing_rag"

/obj/item/reagent_containers/glass/rag/polishing_rag/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		. += span_notice("You could use this to polish bones.")

/obj/item/reagent_containers/glass/rag/polishing_rag/afterattack(obj/potential_limb, mob/user, proximity_flag, click_parameters)

	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		return ..()

	if(!istype(potential_limb, /obj/item/armor_module/limb/skeleton))
		return ..()

	var/obj/item/armor_module/limb/skeleton/current_limb = potential_limb
	if(current_limb.polished)
		to_chat(user, span_notice("This limb has already been polished."))
		return ..()

	to_chat(user, span_warning("You start wiping [current_limb] with the [name]."))
	if(!do_after(user, 5 SECONDS, NONE, current_limb, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE))
		to_chat(user, span_notice("You stop polishing [current_limb]."))
		return
	to_chat(user, span_notice("You polish [current_limb] to perfection."))
	current_limb.polished = TRUE
	current_limb.name = "polished [current_limb.name]"

//Skeleton limbs, meant to be for bones
//Only an onmob for the skull
/obj/item/armor_module/limb/skeleton
	name = "How did you get this?"
	desc = "A bone from a human."
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB|ATTACH_SEPERATE_MOB_OVERLAY|ATTACH_NO_HANDS
	icon = 'icons/obj/items/skeleton.dmi'
	attach_icon = 'icons/obj/items/skeleton.dmi'
	mob_overlay_icon = 'icons/mob/hunter/pred_gear.dmi'

	slot = ACCESSORY_SLOT_ARMOR_M

	icon_state = null

	///Has it been cleaned by a polishing rag?
	var/polished = FALSE

/obj/item/armor_module/limb/skeleton/l_arm
	name = "arm bone"
	icon_state = "l_arm"
	slot = ACCESSORY_SLOT_ARMOR_Y_LH

/obj/item/armor_module/limb/skeleton/l_foot
	name = "foot bone"
	icon_state = "l_foot"
	slot = ACCESSORY_SLOT_ARMOR_Y_LL

/obj/item/armor_module/limb/skeleton/l_hand
	name = "hand bone"
	icon_state = "l_hand"
	slot = ACCESSORY_SLOT_ARMOR_Y_LH

/obj/item/armor_module/limb/skeleton/l_leg
	name = "leg bone"
	icon_state = "l_leg"
	slot = ACCESSORY_SLOT_ARMOR_Y_LL

/obj/item/armor_module/limb/skeleton/r_arm
	name = "arm bone"
	icon_state = "r_arm"
	slot = ACCESSORY_SLOT_ARMOR_Y_RH

/obj/item/armor_module/limb/skeleton/r_foot
	name = "foot bone"
	icon_state = "r_foot"
	slot = ACCESSORY_SLOT_ARMOR_Y_RL

/obj/item/armor_module/limb/skeleton/r_hand
	name = "hand bone"
	icon_state = "r_hand"
	slot = ACCESSORY_SLOT_ARMOR_Y_RH

/obj/item/armor_module/limb/skeleton/r_leg
	name = "leg bone"
	icon_state = "r_leg"
	slot = ACCESSORY_SLOT_ARMOR_Y_RL

/obj/item/armor_module/limb/skeleton/head
	name = "skull"
	icon_state = "skull"
	slot = ACCESSORY_SLOT_ARMOR_Y_H

/obj/item/armor_module/limb/skeleton/head/spine
	icon_state = "spine"
	slot = ACCESSORY_SLOT_ARMOR_Y_S

/obj/item/armor_module/limb/skeleton/torso
	name = "ribcage"
	icon_state = "torso"
	slot = ACCESSORY_SLOT_ARMOR_Y_C

/obj/item/armor_module/limb/skeleton/examine(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		if(polished)
			. += span_notice("Polished to perfection.")
		else
			. += span_notice("[src] is still dirty.")

/obj/item/storage/belt/utility/pred
	name = "\improper Yautja toolbelt"
	desc = "A modular belt with various clips. This version lacks any hunting functionality, and is commonly used by engineers to transport important tools."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "utilitybelt_pred"
	worn_icon_state = "utility"

/obj/item/storage/belt/utility/pred/full/PopulateContents()
	new /obj/item/tool/screwdriver/yautja(src)
	new /obj/item/tool/wrench/yautja(src)
	new /obj/item/tool/weldingtool/yautja(src)
	new /obj/item/tool/crowbar/yautja(src)
	new /obj/item/tool/wirecutters/yautja(src)
	new /obj/item/stack/cable_coil(src, 30, pick("red", "orange"))
	new /obj/item/tool/multitool/yautja(src)

/// SKULLS
/obj/item/skull
	name = "skull"
	icon = 'icons/obj/hunter/xeno_skulls.dmi'
	resistance_flags = INDESTRUCTIBLE

/obj/item/skull/queen
	name = "Queen skull"
	desc = "Skull of a prime hive ruler, mother to many."
	icon_state = "queen_skull"

/obj/item/skull/king
	name = "King skull"
	desc = "Skull of a militant hive ruler, lord of destruction."
	icon_state = "king_skull"

/obj/item/skull/lurker
	name = "Lurker skull"
	desc = "Skull of a stealthy xenomorph, a nocturnal entity."
	icon_state = "lurker_skull"

/obj/item/skull/hunter
	name = "Hunter skull"
	desc = "Skull of a stealthy xenomorph, an ambushing predator."
	icon_state = "hunter_skull"

/obj/item/skull/deacon
	name = "Deacon skull"
	desc = "Skull of an unusual xenomorph, a mysterious specimen."
	icon_state = "deacon_skull"

/obj/item/skull/spitter
	name = "Spitter skull"
	desc = "Skull of an acidic xenomorph, a boiling menace."
	icon_state = "spitter_skull"

/obj/item/skull/warrior
	name = "Warrior skull"
	desc = "Skull of a strong xenomorph, a swift fighter."
	icon_state = "warrior_skull"

/// TOOLS

/obj/item/tool/crowbar/yautja
	name = "yautja crowbar"
	desc = "Used to remove floors and to pry open doors, made of an unusual alloy."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "bar"
	worn_icon_state = "bar"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)

/obj/item/tool/wrench/yautja
	name = "yautja wrench"
	desc = "A wrench with many common uses. Made of some bizarre alien bones."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "wrench"
	worn_icon_state = "wrench"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)

/obj/item/tool/wirecutters/yautja
	name = "yautja wirecutters"
	desc = "This cuts wires, also flesh. Made of some razorsharp animal teeth."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "wirescutter"
	worn_icon_state = "wirescutter"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)

/obj/item/tool/screwdriver/yautja
	name = "yautja screwdriver"
	desc = "Some hightech screwing abilities."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "screwdriver"
	worn_icon_state = "screwdriver"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)
	force = 7
	random_color = FALSE

/obj/item/tool/multitool/yautja
	name = "yautja multitool"
	desc = "Top notch alien tech for B&E through hacking."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "multitool"
	worn_icon_state = "multitool"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)

/obj/item/tool/weldingtool/yautja
	name = "yautja chem welding tool"
	desc = "A complex chemical welding device, keep away from youngblood."
	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "welder"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/hunter/items_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/hunter/items_righthand.dmi'
	)
	force = 10
	throwforce = 15
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	max_fuel = 150	//The max amount of fuel the welder can hold

/obj/item/weapon/sword/machete/arnold
	name = "\improper Dutch's Machete"
	desc = "Won by an Elder during their youthful hunting days. None are allowed to touch it."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "arnold-machete"
	force = 130
	anchored = TRUE
