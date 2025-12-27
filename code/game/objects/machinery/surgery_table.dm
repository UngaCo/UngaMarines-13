/obj/item/deployable_optable
	name = "\improper Deployable Operating Table"
	desc = "An operating table able to be transported and deployed for medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table_deployable"
	max_integrity = 300
	deploy_flags = IS_DEPLOYABLE
	w_class = WEIGHT_CLASS_NORMAL
	var/deployable_item = /obj/machinery/optable/deployable

/obj/item/deployable_optable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 2 SECONDS, 2 SECONDS)

/obj/machinery/optable/deployable
	name = "Deployable Operating Table"
	icon_state = "table_deployable_idle"
	base_icon_state = "table_deployable"
	desc = "Used for advanced medical procedures in field."
	use_power = NO_POWER_USE
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	max_integrity = 300
	///What it deploys into. typecast version of internal_item
	var/obj/item/deployable_optable/internal_item

/obj/machinery/optable/deployable/Initialize(mapload, _internal_item, deployer)
	. = ..()
	if(!_internal_item && !internal_item)
		return INITIALIZE_HINT_QDEL

	internal_item = _internal_item

/obj/machinery/optable/deployable/get_internal_item()
	return internal_item

/obj/machinery/optable/deployable/clear_internal_item()
	internal_item = null

/obj/machinery/optable/deployable/Destroy()
	if(internal_item)
		QDEL_NULL(internal_item)
	return ..()

/obj/machinery/optable/deployable/MouseDrop(over_object, src_location, over_location)
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(over_object != user || !in_range(src, user) || user.incapacitated() || user.lying_angle)
		return
	disassemble(user)

///Dissassembles the device
/obj/machinery/optable/deployable/disassemble(mob/user)
	if(CHECK_BITFIELD(internal_item.deploy_flags, DEPLOYED_NO_PICKUP))
		balloon_alert(user, "cannot be disassembled")
		return FALSE
	if(anes_tank)
		anes_tank.forceMove(get_turf(src))
	SEND_SIGNAL(src, COMSIG_ITEM_UNDEPLOY, user)
	return TRUE
