#define VISION_MODE_OFF 0
#define VISION_MODE_NVG 1
#define VISION_MODE_THERMAL 2
#define VISION_MODE_MESON 3

///parent type
/obj/item/clothing/mask/gas/yautja
	name = "alien mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_list = list(
		slot_wear_mask_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	icon_state = "pred_mask1_ebony"
	worn_icon_state = "helmet"
	worn_worn_icon_state_slots = list(slot_wear_mask_str = "pred_mask1_ebony")

	soft_armor = list(MELEE = 20, BULLET = 25, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 20, FIRE = 20, ACID = 20)

	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	armor_protection_flags = HEAD|FACE|EYES
	cold_protection_flags = HEAD
	inventory_flags = COVEREYES|COVERMOUTH|BLOCKGASEFFECT|BLOCKSHARPOBJ
	inv_hide_flags = HIDEEARS|HIDEEYES|HIDEFACE|HIDELOWHAIR
	eye_protection = 2
	item_flags = ITEM_PREDATOR
	var/current_goggles = VISION_MODE_OFF
	resistance_flags = UNACIDABLE
	unequip_delay_self = 20
	anti_hug = 5
	var/list/actions_to_add = list(
		new /datum/action/predator_action/mask/zoom,
		new /datum/action/predator_action/mask/togglesight
	)
	var/list/obj/item/clothing/glasses/glasses = list(
		"nvg" = new /obj/item/clothing/glasses/night/yautja,
		"thermal" = new /obj/item/clothing/glasses/thermal/yautja,
		"meson" = new /obj/item/clothing/glasses/meson/yautja,
	)
	var/list/mask_huds = list(DATA_HUD_MEDICAL_OBSERVER, DATA_HUD_XENO_STATUS, DATA_HUD_HUNTER, DATA_HUD_HUNTER_CLAN)
	var/thrall = FALSE //Used to affect icon generation.

/obj/item/clothing/mask/gas/yautja/Initialize(mapload, mask_number = rand(1,12), armor_material = "ebony", legacy = "None")
	. = ..()
	if(thrall)
		return

	if(legacy != "None")
		switch(legacy)
			if("Dragon")
				icon_state = "pred_mask_elder_tr"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask_elder_tr")
				return
			if("Swamp")
				icon_state = "pred_mask_elder_joshuu"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask_elder_joshuu")
				return
			if("Enforcer")
				icon_state = "pred_mask_elder_feweh"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask_elder_feweh")
				return
			if("Collector")
				icon_state = "pred_mask_elder_n"
				LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask_elder_n")
				return

	if(mask_number > 12)
		mask_number = 1

	icon_state = "pred_mask[mask_number]_[armor_material]"
	LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask[mask_number]_[armor_material]")

/obj/item/clothing/glasses/welding/Initialize(mapload)
	AddComponent(/datum/component/clothing_tint, TINT_NONE, FALSE)
	return ..()

/obj/item/clothing/mask/gas/yautja/pickup(mob/living/user)
	if(isyautja(user))
		remove_from_missing_pred_gear(src)
	return ..()

/obj/item/clothing/mask/gas/yautja/Destroy()
	remove_from_missing_pred_gear(src)
	return ..()

/obj/item/clothing/mask/gas/yautja/proc/togglesight(mob/living/carbon/human/M)
	if(!HAS_TRAIT(M, TRAIT_YAUTJA_TECH) && !M.hunter_data.thralled)
		to_chat(M, span_warning("You have no idea how to work this thing!"))
		return
	if(src != M.wear_mask) //sanity
		to_chat(M, span_warning("You must wear \the [src]!"))
		return
	var/obj/item/clothing/gloves/yautja/Y = M.gloves //Doesn't actually reduce power, but needs the bracers anyway.
	if(!Y || !istype(Y))
		to_chat(M, span_warning("You must be wearing your bracers, as they have the power source."))
		return
	var/obj/item/G = M.glasses
	if(G)
		if(!istype(G,/obj/item/clothing/glasses/night/yautja) && !istype(G,/obj/item/clothing/glasses/meson/yautja) && !istype(G,/obj/item/clothing/glasses/thermal/yautja))
			to_chat(M, span_warning("You need to remove your glasses first. Why are you even wearing these?"))
			return
		M.transferItemToLoc(G, src, TRUE)
	switch_vision_mode()
	add_vision(M)

/obj/item/clothing/mask/gas/yautja/proc/switch_vision_mode() //switches to the next one
	switch(current_goggles)
		if(VISION_MODE_OFF)
			current_goggles = VISION_MODE_NVG
		if(VISION_MODE_NVG)
			current_goggles = VISION_MODE_THERMAL
		if(VISION_MODE_THERMAL)
			current_goggles = VISION_MODE_MESON
		if(VISION_MODE_MESON)
			current_goggles = VISION_MODE_OFF

/obj/item/clothing/mask/gas/yautja/proc/add_vision(mob/living/carbon/human/user) //applies current_goggles
	switch(current_goggles)
		if(VISION_MODE_NVG)
			user.equip_to_slot_if_possible(glasses["nvg"], SLOT_GLASSES, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE)
			to_chat(user, span_notice("Low-light vision module: activated."))
		if(VISION_MODE_THERMAL)
			user.equip_to_slot_if_possible(glasses["thermal"], SLOT_GLASSES, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE)
			to_chat(user, span_notice("Thermal vision module: activated."))
		if(VISION_MODE_MESON)
			user.equip_to_slot_if_possible(glasses["meson"], SLOT_GLASSES, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE)
			to_chat(user, span_notice("Material vision module: activated."))
		if(VISION_MODE_OFF)
			to_chat(user, span_notice("You deactivate your visor."))

	playsound(src, 'sound/effects/pred_vision.ogg', 15, 1)
	user.update_inv_glasses()

/obj/item/clothing/mask/gas/yautja/dropped(mob/living/carbon/human/user) //Clear the gogglors if the helmet is removed.
	if(istype(user) && user.wear_mask == src) //inventory reference is only cleared after dropped().
		for(var/listed_hud in mask_huds)
			var/datum/atom_hud/H = GLOB.huds[listed_hud]
			H.remove_hud_from(user)
		playsound(src, 'sound/items/air_release.ogg', 15, 1)
		for(var/datum/action/action in actions_to_add)
			action.remove_action(user)
		var/obj/item/G = user.glasses
		if(G) //make your hud fuck off
			if(current_goggles)
				user.UnEquip(G, TRUE, src)
	..()

/obj/item/clothing/mask/gas/yautja/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_WEAR_MASK)
		for(var/listed_hud in mask_huds)
			var/datum/atom_hud/H = GLOB.huds[listed_hud]
			H.add_hud_to(user)
		if(current_goggles)
			add_vision(user)
		for(var/datum/action/action in actions_to_add)
			action.give_action(user)
	..()

/obj/item/clothing/mask/gas/yautja/unequipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_WEAR_MASK)
		for(var/listed_hud in mask_huds)
			var/datum/atom_hud/H = GLOB.huds[listed_hud]
			H.remove_hud_from(user)
		playsound(src, 'sound/items/air_release.ogg', 15, 1)
		for(var/datum/action/action in actions_to_add)
			action.remove_action(user)
		var/obj/item/G = user.glasses
		if(G) //make your hud fuck off
			if(current_goggles)
				user.UnEquip(G, TRUE, src)
	..()

/obj/item/clothing/mask/gas/yautja/thrall
	name = "alien mask"
	desc = "A simplistic metallic face mask with advanced capabilities."
	icon_state = "thrall_mask"
	worn_icon_state = "thrall_mask"
	icon = 'icons/obj/hunter/thrall_gear.dmi'
	worn_icon_list = list(
		slot_wear_mask_str = 'icons/mob/hunter/thrall_gear.dmi'
	)
	worn_worn_icon_state_slots = list(slot_wear_mask_str = "thrall_mask")
	thrall = TRUE

/obj/item/clothing/mask/gas/yautja/thrall/togglesight()
	set category = "Thrall"
	..()

/obj/item/clothing/mask/gas/yautja/hunter
	name = "clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."

	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)
	eye_protection = 2
	anti_hug = 100

/obj/item/clothing/mask/gas/yautja/hunter/pred
	anchored = TRUE
	color = "#FFE55C"
	icon_state = "pred_mask_elder_joshuu"

/obj/item/clothing/mask/gas/yautja/hunter/togglesight()
	set category = "Yautja"
	if(!isyautja(usr))
		to_chat(usr, span_warning("You have no idea how to work this thing!"))
		return
	..()

/obj/item/clothing/mask/gas/yautja/damaged
	name = "ancient alien mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional. This one seems to be old and degraded."

/obj/item/clothing/mask/gas/yautja/damaged/switch_vision_mode()
	switch(current_goggles)
		if(VISION_MODE_OFF)
			current_goggles = VISION_MODE_NVG
		if(VISION_MODE_NVG)
			current_goggles = VISION_MODE_OFF

/obj/item/clothing/mask/gas/yautja/damaged/add_vision(mob/living/carbon/human/user)
	switch(current_goggles)
		if(VISION_MODE_NVG)
			user.equip_to_slot_if_possible(glasses["nvg"], SLOT_GLASSES, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE)
			to_chat(user, span_notice("You activate your visor."))
		if(VISION_MODE_OFF)
			to_chat(user, span_notice("You deactivate your visor."))

	playsound(src, 'sound/effects/pred_vision.ogg', 15, 1)
	user.update_inv_glasses()

#undef VISION_MODE_OFF
#undef VISION_MODE_NVG
#undef VISION_MODE_THERMAL
#undef VISION_MODE_MESON


//flavor, not a subtype
/obj/item/clothing/mask/yautja_flavor
	name = "alien stone mask"
	desc = "A beautifully designed face mask, ornate but non-functional and made entirely of stone."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	worn_icon_list = list(
		slot_wear_mask_str = 'icons/mob/hunter/pred_gear.dmi'
	)
	icon_state = "pred_mask1_ebony"

	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 0, ACID = 0)
	armor_protection_flags = HEAD|FACE|EYES
	cold_protection_flags = HEAD
	inv_hide_flags = HIDEEARS|HIDEEYES|HIDEFACE|HIDELOWHAIR
	resistance_flags = UNACIDABLE
	worn_worn_icon_state_slots = list(slot_wear_mask_str = "pred_mask1_ebony")
	var/map_random = FALSE

/obj/item/clothing/mask/yautja_flavor/Initialize(mapload, ...)
	. = ..()
	if(mapload && !map_random)
		return

	var/list/possible_masks = list(1,2,3,4,5,6,7,8,9,10,11) //12
	var/mask_number = rand(1,11)
	if(mask_number in possible_masks)
		icon_state = "pred_mask[mask_number]_ebony"
		LAZYSET(worn_worn_icon_state_slots, slot_wear_mask_str, "pred_mask[mask_number]_ebony")

/obj/item/clothing/mask/yautja_flavor/map_random
	map_random = TRUE
