//Vali Sword
/obj/item/weapon/sword/harvester
	name = "\improper HP-S Harvester blade"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_sword"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	worn_icon_state = "vali_sword"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/sword/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/sword/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/sword/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Vali Knife
/obj/item/weapon/combat_knife/harvester
	name = "\improper HP-S Harvester knife"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' knife. An advanced version of the HP-S Harvester blade, shrunken down to the size of the standard issue boot knife. It trades the harvester blades size and power for a smaller form, with the side effect of a miniscule chemical storage, yet it still keeps its ability to apply debilitating effects to its targets. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_knife"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	worn_icon_state = "vali_knife"
	w_class = WEIGHT_CLASS_SMALL
	force = 25
	throwforce = 15
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	sharp = IS_SHARP_ITEM_ACCURATE
	hitsound = 'sound/weapons/slash.ogg'

/obj/item/weapon/combat_knife/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 5)

/obj/item/weapon/combat_knife/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/combat_knife/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//Vali Claymore (That thing was too big to be called a sword. Too big, too thick, too heavy, and too rough, it was more like a large hunk of iron.)
/obj/item/weapon/twohanded/glaive/harvester
	name = "\improper HP-S Harvester claymore"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system. This specific version is enlarged to fit the design of an old world claymore. Simply squeeze the hilt to activate."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_claymore"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	worn_icon_state = "vali_claymore"
	attack_speed = 24
	resistance_flags = NONE

/obj/item/weapon/twohanded/glaive/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester, 60)

/obj/item/weapon/twohanded/glaive/harvester/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/twohanded/glaive/harvester/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)

//Vali rapier
/obj/item/weapon/sword/officer/valirapier
	name = "\improper HP-C Harvester rapier"
	desc = "Extremely expensive looking blade, with a golden handle and engravings, unexpectedly effective in combat, despite its ceremonial looks, compacted with a vali module."
	icon = 'icons/obj/items/vali.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	icon_state = "rapier"
	worn_icon_state = "rapier"
	force = 60
	attack_speed = 5

/obj/item/weapon/sword/officer/valirapier/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)
	RemoveElement(/datum/element/strappable)

//Vali Spear
/obj/item/weapon/twohanded/spear/tactical/harvester
	name = "\improper HP-S Harvester spear"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' spear. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "vali_spear"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	worn_icon_state = "vali_spear"
	force = 32
	force_activated = 60
	throwforce = 60

/obj/item/weapon/twohanded/spear/tactical/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

///////////////////////////////////////////////////////////////////////
////////////////// VAL-HAL-A, the Vali Halberd ////////////////////////
///////////////////////////////////////////////////////////////////////
/obj/item/weapon/twohanded/glaive/halberd/harvester
	name = "\improper VAL-HAL-A halberd harvester"
	desc = "TerraGov Marine Corps' cutting-edge 'Harvester' halberd, with experimental plasma regulator. An advanced weapon that combines sheer force with the ability to apply a variety of debilitating effects when loaded with certain reagents, but should be used with both hands. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon = 'icons/obj/items/vali.dmi'
	icon_state = "VAL-HAL-A"
	worn_icon_state = "VAL-HAL-A"
	worn_icon_list = list(
		slot_back_str = 'icons/mob/clothing/back.dmi',
		slot_l_hand_str = 'icons/mob/inhands/weapons/vali_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/vali_right.dmi',
	)
	force = 40
	force_activated = 95 //Reminder: putting trama inside deals 60% additional damage
	item_flags = TWOHANDED
	resistance_flags = 0 //override glavie
	attack_speed = 10 //Default is 7, this has slower attack
	reach = 2 //like spear
	slowdown = 0 //Slowdown in back slot
	var/wielded_slowdown = 0.5 //Slowdown in hands, wielded
	var/wield_delay = 0.8 SECONDS

/obj/item/weapon/twohanded/glaive/halberd/harvester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/harvester)

// Stuff which should ideally be in /twohanded code
/obj/item/weapon/twohanded/glaive/halberd/harvester/unwield(mob/user)
	. = ..()
	user.remove_movespeed_modifier(MOVESPEED_ID_WIELDED_SLOWDOWN)


/obj/item/weapon/twohanded/glaive/halberd/harvester/wield(mob/user)
	. = ..()

	if (!(item_flags & WIELDED))
		return

	if(wield_delay > 0)
		if (!do_after(user, wield_delay, IGNORE_LOC_CHANGE, user, BUSY_ICON_HOSTILE, null, PROGRESS_CLOCK))
			unwield(user)
			return

	user.add_movespeed_modifier(MOVESPEED_ID_WIELDED_SLOWDOWN, TRUE, 0, NONE, TRUE, wielded_slowdown)
