///Default ammo for the HSG-102.
/obj/item/ammo_magazine/hsg102
	name = "HSG-102 drum magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the HSG-102 mounted heavy smartgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "hsg102"
	magazine_flags = NONE
	caliber = CALIBER_10X30
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/machinegun/smart
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_hmg"

///This is the one that comes in the mapbound and dropship mounted version of the HSG-102, it has a stupid amount of ammo. Even more than the ammo counter can display.
/obj/item/ammo_magazine/hsg102/hsg_nest
	max_rounds = 500

/obj/item/ammo_magazine/hmg08
	name = "HMG-08 drum magazine (10x30mm Caseless)"
	desc = "A box of 500, 10x28mm caseless tungsten rounds for the HMG-08 mounted heavy machinegun. Is probably not going to fit in your backpack. Put it on your belt or back."
	w_class = WEIGHT_CLASS_BULKY
	equip_slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "mg08"
	icon_state_mini = "mag_drum_big_green"
	magazine_flags = NONE
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/hmg08/small
	name = "HMG-08 box magazine (10x30mm Caseless)"
	desc = "A box of 250 10x28mm caseless tungsten rounds for the HMG-08 mounted heavy machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	equip_slot_flags = ITEM_SLOT_BELT
	icon_state = "mg08_small"
	icon_state_mini = "mag_hmg"
	max_rounds = 250
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/mg27
	name = "MG-27 box magazine (10x27m Caseless)"
	desc = "A box of 150 10x27mm caseless rounds for the MG-27 medium machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "mg27"
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state_mini = "mag_drum_big_armygreen"
	magazine_flags = NONE
	caliber = CALIBER_10X27_CASELESS
	max_rounds = 150
	default_ammo = /datum/ammo/bullet/rifle/heavy
	reload_delay = 1 SECONDS

/obj/item/ammo_magazine/agls37
	name = "AGLS-37 HE magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless HE grenades for the AGLS-37 automatic grenade launcher."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "agls"
	magazine_flags = NONE
	caliber = CALIBER_40MM
	max_rounds = 30
	default_ammo = /datum/ammo/grenade_container/agls37
	reload_delay = 4 SECONDS

/obj/item/ammo_magazine/agls37/fragmentation
	name = "AGLS-37 Frag magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Fragmentation grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "agls_frag"
	default_ammo = /datum/ammo/ags_shrapnel

/obj/item/ammo_magazine/agls37/incendiary
	name = "AGLS-37 WP magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless White Phosphorous grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "agls_incend"
	default_ammo = /datum/ammo/ags_shrapnel/incendiary

/obj/item/ammo_magazine/agls37/flare
	name = "AGLS-37 Flare magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Flare grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "agls_flare"
	default_ammo = /datum/ammo/grenade_container/agls37/flare

/obj/item/ammo_magazine/agls37/cloak
	name = "AGLS-37 Cloak magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Cloak grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "agls_cloak"
	default_ammo = /datum/ammo/grenade_container/agls37/cloak

/obj/item/ammo_magazine/agls37/tanglefoot
	name = "AGLS-37 Tanglefoot magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Tanglefoot grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "agls_pgas"
	default_ammo = /datum/ammo/grenade_container/agls37/tanglefoot

/obj/item/ammo_magazine/at36
	name = "AT-36 AP-HE shell (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns. Will penetrate walls and fortifications, before hitting a target and exploding, has less payload and punch than usual rounds."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "at36"
	worn_icon_state = "tat36"
	magazine_flags = MAGAZINE_REFUND_IN_CHAMBER
	caliber = CALIBER_37MM
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/atgun_shell
	reload_delay = 2 SECONDS

/obj/item/ammo_magazine/at36/apcr
	name = "AT-36 APCR shell (37mm Shell)"
	desc = "A 37mm tungsten shell for light anti tank guns made to penetrate through just about everything, but it won't leave a big hole."
	icon_state = "at36_apcr"
	worn_icon_state = "tat36_apcr"
	default_ammo = /datum/ammo/rocket/atgun_shell/apcr

/obj/item/ammo_magazine/at36/he
	name = "AT-36 HE (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to destroy fortifications, the high amount of payload gives it a slow speed. But it leaves quite a hole."
	icon_state = "at36_he"
	worn_icon_state = "tat36_he"
	default_ammo = /datum/ammo/rocket/atgun_shell/he

/obj/item/ammo_magazine/at36/beehive
	name = "AT-36 Beehive (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to mince infantry, the light payload gives it moderate speed. Turns anyone into swiss cheese."
	icon_state = "at36_beehive"
	worn_icon_state = "tat36_beehive"
	default_ammo = /datum/ammo/rocket/atgun_shell/beehive

/obj/item/ammo_magazine/at36/incend
	name = "AT-36 Napalm (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to set the battlefield ablaze, the light payload gives it a moderate speed. Will cook any target flambé."
	icon_state = "at36_incend"
	worn_icon_state = "tat36_incend"
	default_ammo = /datum/ammo/rocket/atgun_shell/beehive/incend

/obj/item/ammo_magazine/heavy_minigun
	name = "MG-2005 box magazine (7.62x51mm)"
	desc = "A box of 1000 rounds for the MG-2005 mounted minigun."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "minigun"
	magazine_flags = NONE
	caliber = CALIBER_762X51
	max_rounds = 1000
	default_ammo = /datum/ammo/bullet/minigun
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/atr22
	name = "autocannon high-velocity magazine(20mm)"
	desc = "A box of 100 high-velocity 20mm rounds for the ATR-22 mounted autocannon. Will pierce people and cover."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "ac"
	worn_icon_state = "ac"
	magazine_flags = NONE
	caliber = CALIBER_20
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/auto_cannon
	reload_delay = 4 SECONDS

/obj/item/ammo_magazine/atr22/flak
	name = "autocannon smart-detonating magazine(20mm)"
	desc = "A box of 80 smart-detonating 20mm rounds for the ATR-22 mounted autocannon. Will detonate upon hitting a target."
	icon_state = "ac_flak"
	worn_icon_state = "ac_flak"
	default_ammo = /datum/ammo/bullet/auto_cannon/flak

/obj/item/cell/lasgun/heavy_laser
	name = "heavy-duty weapon laser cell"
	desc = "A cell with enough charge to contain energy for the TE-9001. This cannot be recharged."
	w_class = WEIGHT_CLASS_BULKY
	maxcharge = 225
	reload_delay = 5 SECONDS
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "hl"
	charge_overlay = null

/obj/item/ammo_magazine/fk88
	name = "FK-88 shell (155mm Shell)"
	desc = "A 15cm shell for the FK-88 mounted flak gun. How did you even get this?"
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "fk88_he"
	w_class = WEIGHT_CLASS_BULKY
	magazine_flags = MAGAZINE_REFUND_IN_CHAMBER
	caliber = CALIBER_15CM
	max_rounds = 1
	reload_delay = 8 SECONDS
	default_ammo = /datum/ammo/rocket/fk88

/obj/item/ammo_magazine/fk88/he
	name = "FK-88 HE shell (155mm Shell)"
	desc = "A 15cm HE shell for the FK-88 mounted flak gun."
	default_ammo = /datum/ammo/rocket/fk88

/obj/item/ammo_magazine/fk88/he/unguided
	name = "FK-88 unguided HE shell (155mm Shell)"
	desc = "A 15cm unguided HE shell for the FK-88 mounted flak gun."
	default_ammo = /datum/ammo/rocket/fk88/unguided

/obj/item/ammo_magazine/fk88/sabot
	name = "FK-88 APFDS shell (155mm Shell)"
	desc = "A 15cm APFDS shell for the FK-88 mounted flak gun containing a large metal dart fired at hypersonic speeds, will pierce through basically anything and onto the other side with ease. Requires a minimum range before it stabilizes to properly hit anything, will rip a clean hole through basically anything."
	icon_state = "fk88_sabot"
	default_ammo = /datum/ammo/bullet/fk88_apfds

///Default ammo for the ML-91 and its export variants.
/obj/item/ammo_magazine/kord
	name = "KRD-61ES magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the KRD-61ESmounted heavy smartgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "kord"
	magazine_flags = NONE
	caliber = CALIBER_10X30
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_hmg"

/obj/item/ammo_magazine/maxim1910

	name = "Maxim 1910 box magazine(7.62x54mm)" // maxim 1910 has 54 caliber, like Mosin
	desc = "A box of 250, 7.62x54mm light rounds for the Maxim machine gun of the 1910 model, designed by gunsmiths P.P. Tretyakov and master I.A. Pastukhov"
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/items/ammo/stationary.dmi'
	icon_state = "maxim1910"
	magazine_flags = NONE
	caliber = CALIBER_762X54
	max_rounds = 250 // box for ammo of light round for Maxin 1910 has 250 rounds capacity
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_hmg"
