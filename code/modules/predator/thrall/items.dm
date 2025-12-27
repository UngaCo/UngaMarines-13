/obj/item/clothing/suit/armor/yautja/thrall
	name = "alien armor"
	desc = "Armor made from scraps of cloth and a strange alloy. It feels cold with an alien weight. It has been adapted to carry both human and alien melee weaponry."

	icon = 'icons/obj/hunter/thrall_gear.dmi'
	icon_state = "chest1_cloth"
	worn_icon_state = "chest1_cloth"
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/hunter/thrall_gear.dmi'
	)
	thrall = TRUE

	allowed = list(
		/obj/item/weapon/gun/energy/yautja,
		/obj/item/weapon,
	)

/obj/item/clothing/suit/armor/yautja/thrall/Initialize(mapload, armor_area = pick("shoulders", "chest", "mix"), armor_number = rand(1,3), armor_material = pick("cloth", "bare"))
	if(armor_number > 3)
		armor_number = 1
	if(armor_number)
		icon_state = "[armor_area][armor_number]_[armor_material]"
		LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "[armor_area][armor_number]_[armor_material]")
	return ..()

/obj/item/clothing/shoes/marine/yautja/thrall
	name = "alien greaves"
	desc = "Greaves made from scraps of cloth and a strange alloy. They feel cold with an alien weight. They have been adapted for compatibility with human equipment."

	icon = 'icons/obj/hunter/thrall_gear.dmi'
	icon_state = "greaves1_cloth"
	worn_icon_list = list(
		slot_shoes_str = 'icons/mob/hunter/thrall_gear.dmi'
	)
	thrall = TRUE

/obj/item/clothing/shoes/marine/yautja/thrall/Initialize(mapload, greaves_number = 1, armor_material = pick("cloth", "bare"))
	if(greaves_number > 1)
		greaves_number = 1
	if(greaves_number)
		icon_state = "greaves[greaves_number]_[armor_material]"
		LAZYSET(worn_worn_icon_state_slots, slot_wear_suit_str, "greaves[greaves_number]_[armor_material]")
	return ..()

/obj/item/clothing/under/chainshirt/thrall
	name = "alien mesh suit"
	color = "#b85440"
	desc = "A strange alloy weave in the form of a vest. It feels cold with an alien weight. It has been adapted for human physiology."

/obj/item/storage/box/bracer
	name = "alien box"
	desc = "A strange, runed box."
	color = "#68423b"
	icon = 'icons/obj/structures/closet.dmi'
	icon_state = "pred_coffin"

/obj/item/storage/box/bracer/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/gloves/yautja/thrall(src)
	storage_datum.foldable = FALSE
