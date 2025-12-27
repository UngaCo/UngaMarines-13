/obj/machinery/prop/yautja/bubbler
	name = "yautja cauldron"
	desc = "A large, black machine emitting an ominous hum with an attached pot of boiling fluid. Bits of what appears to be leftover lard and balls of hair can be seen floating inside of it."
	icon = 'icons/obj/machines/yautja_machines.dmi'
	icon_state = "vat"
	density = TRUE

/obj/machinery/prop/yautja/bubbler/examine(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		. += span_notice("You can use this machine to clean the skin off limbs, and turn them into bones for your armor.")
		. += span_notice("You first need to find a limb. Then you use a ceremonial dagger to prepare it.")
		. += span_notice("After preparing the limb, you put it into the cauldron, removing the flesh, leaving you with a bone.")
		. += span_notice("You will then clean and polish the resulting bones with a polishing rag, making it ready to be attached to your armor.")

/obj/machinery/prop/yautja/bubbler/attackby(obj/potential_limb, mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		to_chat(user, span_notice("You have no idea what this does, and you figure it is not time to find out."))
		return

	if(!istype(potential_limb, /obj/item/limb))
		to_chat(user, span_notice("You cannot put this in [src]."))
		return
	var/obj/item/limb/current_limb = potential_limb

	if(!current_limb.flayed)
		to_chat(user, span_notice("This limb is not ready."))
		return
	icon_state = "vat_boiling"
	to_chat(user, span_warning("You place [current_limb] in and start the cauldron."))
	if(!do_after(user, 15 SECONDS, NONE, current_limb, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE))
		to_chat(user, span_notice("You pull [current_limb] back out of the cauldron."))
		icon_state = initial(icon_state)
		return
	icon_state = initial(icon_state)

	var/obj/item/armor_module/limb/skeleton/new_bone = new current_limb.bone_type(get_turf(src))
	if(istype(new_bone, /obj/item/armor_module/limb/skeleton/head))
		new_bone.desc = span_notice("This skull used to be [current_limb.name].")
	qdel(current_limb)

/obj/machinery/microwave/yautja
	name = "alien microwave"
	desc = "Dark alloy sinister machine that heats up cold food."
	icon = 'icons/obj/machines/yautja_machines.dmi'

/obj/machinery/processor/yautja
	name = "food grinder"
	icon = 'icons/obj/machines/yautja_machines.dmi'

/obj/machinery/grill/yautja
	name = "alien grill"
	desc = "For grilling the most delicious prey."
	icon = 'icons/obj/machines/yautja_machines.dmi'

/obj/machinery/griddle/yautja
	icon = 'icons/obj/machines/yautja_machines.dmi'

/obj/structure/xenoautopsy/tank/hugger/yautja
	icon = 'icons/obj/machines/yautja_machines.dmi'
	broken_state = /obj/structure/xenoautopsy/tank/escaped/yautja

/obj/structure/xenoautopsy/tank/escaped/yautja
	icon = 'icons/obj/machines/yautja_machines.dmi'

//YAUTJA SHIP - CURRENTLY USES STRATA DOORS
/obj/machinery/door/airlock/yautja
	name = "\improper Airlock"
	icon = 'icons/obj/doors/strata_doors.dmi'
	openspeed = 5
	req_access = null
	req_one_access = null
	no_panel = TRUE
	not_weldable = TRUE
	resistance_flags = RESIST_ALL

/obj/machinery/door/airlock/yautja/secure
	req_one_access = list(ACCESS_YAUTJA_SECURE, ACCESS_YAUTJA_ELDER, ACCESS_YAUTJA_ANCIENT)

/obj/machinery/door/airlock/yautja/secure/elder
	req_one_access = list(ACCESS_YAUTJA_ELDER, ACCESS_YAUTJA_ANCIENT)

/obj/machinery/door/airlock/yautja/secure/ancient
	req_one_access = list(ACCESS_YAUTJA_ANCIENT)

/obj/machinery/door/airlock/sandstone/runed
	name = "\improper Runed Sandstone Airlock"
	icon = 'icons/obj/doors/doorrunedsand.dmi'
	mineral = "runed sandstone"
	openspeed = 4 SECONDS
	resistance_flags = RESIST_ALL
	color = "#b29082"

/obj/machinery/door/poddoor/shutters/almayer/yautja
	name = "Armory Shutter"
	id = "Yautja Armory"
	resistance_flags = RESIST_ALL

/obj/machinery/door/poddoor/shutters/almayer/yautja/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_YAUTJA_ARMORY_OPENED, PROC_REF(open))

/obj/structure/closet/coffin/predator
	name = "strange coffin"
	desc = "It's a burial receptacle for the dearly departed. Seems to have weird markings on the side..?"
	icon = 'icons/obj/structures/closet.dmi'
	icon_state = "pred_coffin"
	icon_closed = "pred_coffin"
	icon_opened = "pred_coffin_open"

/obj/structure/bed/chair/hunter
	name = "hunter chair"
	desc = "An exquisitely crafted chair for a large humanoid hunter."
	icon = 'icons/obj/hunter/chair.dmi'
	icon_state = "chair"
	color = rgb(255,255,255)
	buildstacktype = null
	resistance_flags = UNACIDABLE
