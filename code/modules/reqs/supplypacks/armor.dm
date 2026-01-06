/datum/supply_packs/armor
	group = "Armor"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/armor/masks
	name = "SWAT protective mask"
	contains = list(/obj/item/clothing/mask/gas/swat)
	cost = 50

/datum/supply_packs/armor/riot
	name = "Heavy riot armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/riot,
		/obj/item/clothing/head/helmet/marine/riot,
	)
	cost = 120

/datum/supply_packs/armor/marine_shield
	name = "TL-172 defensive shield"
	contains = list(/obj/item/weapon/shield/riot/marine)
	cost = 100

/datum/supply_packs/armor/marine_shield/deployable
	name = "TL-182 deployable shield"
	contains = list(/obj/item/weapon/shield/riot/marine/deployable)
	cost = 30

/datum/supply_packs/armor/b18
	name = "B18 armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
	)
	cost = B18_PRICE
	crash_restricted = TRUE

/datum/supply_packs/armor/b17
	name = "B17 armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/clothing/head/helmet/marine/grenadier,
	)
	cost = B17_PRICE
	crash_restricted = TRUE

/datum/supply_packs/armor/scout_cloak
	name = "Scout cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak)
	cost = 500

/datum/supply_packs/armor/sniper_cloak
	name = "Sniper cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper)
	cost = 500

/datum/supply_packs/armor/grenade_belt
	name = "High capacity grenade belt"
	contains = list(/obj/item/storage/belt/grenade/b17)
	cost = 200

/datum/supply_packs/armor/modular/attachments/valkyrie_autodoc
	name = "Valkyrie automedical system"
	contains = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
	)
	cost = 200

/datum/supply_packs/armor/modular/attachments/fire_proof
	name = "Surt thermal insulation system"
	contains = list(
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/fire_proof_helmet,
	)
	cost = 120

/datum/supply_packs/armor/modular/attachments/tyr_extra_armor
	name = "Tyr Mk.2 armor reinforcement system"
	contains = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_head/mark2,
	)
	cost = 120

/datum/supply_packs/armor/modular/attachments/mimir_extra_armor
	name = "Mimir Mk.2 environmental resistance system"
	contains = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection,
	)
	cost = 160

/datum/supply_packs/armor/modular/attachments/artemis_mark_two
	name = "Freyr Mk.2 visual assistance helmet system"
	contains = list(
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
	)
	cost = 40

/*
/datum/supply_packs/armor/imager_goggle
	name = "Optical imager goggles"
	contains = list(/obj/item/clothing/glasses/night/imager_goggles)
	cost = 50
*/

/datum/supply_packs/armor/robot/advanced/physical
	name = "Cingulata physical protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical,
	)
	cost = 600

/datum/supply_packs/armor/robot/advanced/acid
	name = "Exidobate acid protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid,
	)
	cost = 600

/datum/supply_packs/armor/robot/advanced/bomb
	name = "Tardigrada bomb protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb,
	)
	cost = 600

/datum/supply_packs/armor/robot/advanced/fire
	name = "Urodela fire protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire,
	)
	cost = 600
