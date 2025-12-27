/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/clothing/glasses_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/glasses_right.dmi',
	)
	w_class = WEIGHT_CLASS_SMALL
	active = TRUE
	inventory_flags = COVEREYES
	equip_slot_flags = ITEM_SLOT_EYES
	armor_protection_flags = EYES
	/// If TRUE it will help with near-sightness
	var/prescription = FALSE
	// If TRUE we are able to toggle the glasses and spawn with toggle action
	var/toggleable = FALSE
	/// The deactivated icon_state of our goggles
	var/deactive_state = ""
	/// Flags for stuff like mesons and thermals
	var/vision_flags = NONE
	var/invis_view = SEE_INVISIBLE_LIVING
	var/invis_override = 0 //Override to allow glasses to set higher than normal see_invis
	/// A percentage of how much rgb to "max" on the lighting plane
	/// This lets us brighten darkness without washing out bright color
	var/lighting_cutoff = null
	/// Similar to lighting_cutoff, except it has individual r g and b components in the same 0-100 scale
	var/list/color_cutoffs = null
	// If TRUE we will change our on-mob image layer to GOGGLES instead of GLASSES
	var/goggles_layer = FALSE
	///Sound played on activate() when turning on
	var/activation_sound = 'sound/items/googles_on.ogg'
	///Sound played on activate() when turning off
	var/deactivation_sound = 'sound/items/googles_off.ogg'
	///Color to use for the HUD tint; leave null if no tint
	var/tint

/obj/item/clothing/glasses/examine_descriptor(mob/user)
	return "eyewear"

/obj/item/clothing/glasses/examine_tags(mob/user)
	. = ..()
	if(prescription)
		.["prescription"] = "It will help reduce symptoms of nearsightedness when worn."

/obj/item/clothing/glasses/Initialize(mapload)
	if(toggleable)
		actions_types = list(/datum/action/item_action/toggle)
	. = ..()
	if(toggleable && active)	//For glasses that spawn active
		active = FALSE
		activate()

/obj/item/clothing/glasses/update_icon_state()
	. = ..()
	icon_state = active ? initial(icon_state) : deactive_state

/obj/item/clothing/glasses/update_clothing_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_glasses()

//Glasses can still be toggled if held in the hand if the player wishes to
/obj/item/clothing/glasses/attack_self(mob/user)
	if(toggleable && can_interact(user))
		activate(user)

//Just call the activate() directly instead of needing to call attack_self()
/obj/item/clothing/glasses/ui_action_click(mob/user, datum/action/item_action/action)
	//In case someone in the future adds a non-toggle action to a child type
	if(istype(action, /datum/action/item_action/toggle))
		activate(user)
		//Always return TRUE for toggles so that the UI button icon updates
		return TRUE

	return activate(user)

///Toggle the functions of the glasses
/obj/item/clothing/glasses/proc/activate(mob/user)
	active = !active

	if(active && activation_sound)
		playsound(get_turf(src), activation_sound, 15)
	else if(!active && deactivation_sound)
		playsound(get_turf(src), deactivation_sound, 15)

	update_icon()	//Found out the hard way this has to be before update_inv_glasses()
	user?.update_inv_glasses()
	user?.update_sight()

	return active	//For the UI button update

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing! Can be used as safety googles."
	icon_state = "purple"
	worn_icon_state = "glasses"

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	worn_icon_state = "eyepatch"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/eyepatch/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	var/obj/item/clothing/glasses/eyepatch
	if(istype(I, /obj/item/clothing/glasses/hud/health))
		eyepatch = new /obj/item/clothing/glasses/hud/medpatch
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the eyepatch."))
	else if(istype(I, /obj/item/clothing/glasses/meson))
		eyepatch = new /obj/item/clothing/glasses/meson/eyepatch
		to_chat(user, span_notice("You fasten the meson projector to the inside of the eyepatch."))
	if(istype(I, /obj/item/clothing/glasses/night/imager_goggles))
		eyepatch = new /obj/item/clothing/glasses/night/imager_goggles/eyepatch
		to_chat(user, span_notice("You fasten the optical scanner to the inside of the eyepatch."))
	if(!eyepatch)
		return
	qdel(I)
	qdel(src)
	user.put_in_hands(eyepatch)
	update_icon()

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	armor_protection_flags = NONE

/obj/item/clothing/glasses/regular
	name = "\improper regulation prescription glasses"
	desc = "The Corps may call them Regulation Prescription Glasses but you know them as Rut Prevention Glasses."
	icon_state = "glasses"
	worn_icon_state = "glasses"
	prescription = TRUE

/obj/item/clothing/glasses/regular/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/clothing/glasses/hud/health))
		var/obj/item/clothing/glasses/hud/medglasses/our_glasses = new
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
		qdel(I)
		qdel(src)
		user.put_in_hands(our_glasses)

		update_icon()

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	worn_icon_state = "hipster_glasses"

/obj/item/clothing/glasses/green
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "green"
	worn_icon_state = "green"

/obj/item/clothing/glasses/mgoggles
	name = "marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	icon_state = "mgoggles"
	worn_icon_state = "mgoggles"
	soft_armor = list(MELEE = 40, BULLET = 40, LASER = 0, ENERGY = 15, BOMB = 35, BIO = 10, FIRE = 30, ACID = 30)
	equip_slot_flags = ITEM_SLOT_EYES|ITEM_SLOT_MASK
	goggles_layer = TRUE
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/glasses/mgoggles/attackby(obj/item/our_item, mob/user, params)
	. = ..()
	if(.)
		return
	var/obj/item/clothing/glasses/our_glasses

	if(istype(our_item, /obj/item/clothing/glasses/night/imager_goggles))
		if(prescription)
			our_glasses = new /obj/item/clothing/glasses/night/optgoggles/prescription
		else
			our_glasses = new /obj/item/clothing/glasses/night/optgoggles
		to_chat(user, span_notice("You fasten the optical imaging scanner to the inside of the goggles."))

	else if(istype(our_item, /obj/item/clothing/glasses/hud/health))
		if(prescription)
			our_glasses = new /obj/item/clothing/glasses/hud/medgoggles/prescription
		else
			our_glasses = new /obj/item/clothing/glasses/hud/medgoggles
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the goggles."))

	else if(istype(our_item, /obj/item/clothing/glasses/meson))
		if(prescription)
			our_glasses = new /obj/item/clothing/glasses/meson/enggoggles/prescription
		else
			our_glasses = new /obj/item/clothing/glasses/meson/enggoggles
		to_chat(user, span_notice("You fasten the optical meson scanner to the inside of the goggles."))

	if(!our_glasses)
		return

	qdel(our_item)
	qdel(src)
	user.put_in_hands(our_glasses)
	update_icon()

/obj/item/clothing/glasses/mgoggles/prescription
	name = "prescription marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet. Contains prescription lenses in case you weren't sure if they were lame or not."
	prescription = TRUE

/obj/item/clothing/glasses/m42_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	toggleable = TRUE

//welding goggles

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	worn_icon_state = "welding-g"
	toggleable = TRUE
	inventory_flags = COVEREYES
	eye_protection = 2
	activation_sound = null
	deactivation_sound = null

/obj/item/clothing/glasses/welding/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_5, TRUE)

/obj/item/clothing/glasses/welding/verb/verbtoggle()
	set category = "IC.Clothing"
	set name = "Adjust welding goggles"
	set src in usr

	if(!usr.incapacitated())
		activate(usr)

/obj/item/clothing/glasses/welding/activate(mob/user)
	. = ..()
	if(active)
		flip_down(user)
	else
		flip_up(user)

	//This sends a signal that toggles the tint component's effects
	toggle_worn_icon_state(user)

///Toggle the welding goggles on
/obj/item/clothing/glasses/welding/proc/flip_up(mob/user)
	DISABLE_BITFIELD(inventory_flags, COVEREYES)
	DISABLE_BITFIELD(armor_protection_flags, EYES)
	eye_protection = 0
	update_icon()
	if(user)
		to_chat(user, "You push [src] up out of your face.")

///Toggle the welding goggles off
/obj/item/clothing/glasses/welding/proc/flip_down(mob/user)
	ENABLE_BITFIELD(inventory_flags, COVEREYES)
	ENABLE_BITFIELD(armor_protection_flags, EYES)
	eye_protection = initial(eye_protection)
	update_icon()
	if(user)
		to_chat(user, "You flip [src] down to protect your eyes.")

/obj/item/clothing/glasses/welding/update_icon_state()
	icon_state = "[initial(icon_state)][!active ? "up" : ""]"

/obj/item/clothing/glasses/welding/flipped/Initialize(mapload)	//spawn in flipped up.
	. = ..()
	activate()
	AddComponent(/datum/component/clothing_tint, TINT_5, FALSE)

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	worn_icon_state = "rwelding-g"

/obj/item/clothing/glasses/welding/superior/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_4)

//sunglasses

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	worn_icon_state = "sunglasses"
	eye_protection = 1

/obj/item/clothing/glasses/sunglasses/Initialize(mapload)
	. = ..()
	if(eye_protection)
		AddComponent(/datum/component/clothing_tint, TINT_3)

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	worn_icon_state = "blindfold"
	eye_protection = 2

/obj/item/clothing/glasses/sunglasses/blindfold/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_BLIND)

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	worn_icon_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake
	desc = "A pair of designer sunglasses. Doesn't seem like it'll block flashes."
	eye_protection = 0

/obj/item/clothing/glasses/sunglasses/fake/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	var/obj/item/clothing/glasses/our_glasses
	if(istype(I, /obj/item/clothing/glasses/hud/health))
		our_glasses = new /obj/item/clothing/glasses/hud/medsunglasses
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
	else if(istype(I, /obj/item/clothing/glasses/meson))
		our_glasses = new /obj/item/clothing/glasses/meson/sunglasses
		to_chat(user, span_notice("You fasten the optical meson scaner to the inside of the glasses."))
	else if(istype(I, /obj/item/clothing/glasses/night/m56_goggles))
		our_glasses = new /obj/item/clothing/glasses/night/sunglasses
		to_chat(user, span_notice("You fasten the KTLD sight to the inside of the glasses."))
	else if(istype(I, /obj/item/clothing/glasses/night/imager_goggles))
		our_glasses = new /obj/item/clothing/glasses/night/imager_goggles/sunglasses
		to_chat(user, span_notice("You fasten the optical imager scaner to the inside of the glasses."))
	if(!our_glasses)
		return
	qdel(I)
	qdel(src)
	user.put_in_hands(our_glasses)
	update_icon()

/obj/item/clothing/glasses/sunglasses/fake/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake/big
	name = "designer sunglasses"
	desc = "A pair of larger than average designer sunglasses. Doesn't seem like it'll block flashes."
	icon_state = "bigsunglasses"
	worn_icon_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/fake/big/prescription
	name = "prescription designer sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/sa
	name = "spatial agent's sunglasses"
	desc = "Glasses worn by a spatial agent."
	eye_protection = 2
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM

/obj/item/clothing/glasses/sunglasses/sa/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_NONE)

/obj/item/clothing/glasses/sunglasses/sa/nodrop
	desc = "Glasses worn by a spatial agent. cannot be dropped"
	item_flags = DELONDROP

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"

/obj/item/clothing/glasses/sunglasses/sechud/mp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/clothing_tint, TINT_NONE)

/obj/item/clothing/glasses/sunglasses/aviator
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses."
	icon_state = "aviator"
	worn_icon_state = "aviator"

/obj/item/clothing/glasses/sunglasses/aviator/yellow
	name = "aviator sunglasses"
	desc = "A pair of aviator sunglasses. Comes with yellow lens."
	icon_state = "aviator_yellow"
	worn_icon_state = "aviator_yellow"

/obj/item/clothing/glasses/orange
	name = "orange glasses"
	desc = "A pair of orange glasses."
	icon_state = "orange"
	worn_icon_state = "orange"
	species_exception = list(/datum/species/robot)

/obj/item/clothing/glasses/orange/attackby(obj/item/our_item, mob/user, params)
	. = ..()
	if(.)
		return
	var/obj/item/clothing/glasses/our_glasses
	if(istype(our_item, /obj/item/clothing/glasses/hud/health))
		our_glasses = new /obj/item/clothing/glasses/hud/orange_glasses
		to_chat(user, span_notice("You fasten the medical hud projector to the inside of the glasses."))
	else if(istype(our_item, /obj/item/clothing/glasses/night/imager_goggles))
		our_glasses = new /obj/item/clothing/glasses/night/imager_goggles/orange_glasses
		to_chat(user, span_notice("You fasten the optical imager scaner to the inside of the glasses."))
	else if(istype(our_item, /obj/item/clothing/glasses/meson))
		our_glasses = new /obj/item/clothing/glasses/meson/orange_glasses
		to_chat(user, span_notice("You fasten the optical meson scaner to the inside of the glasses."))
	if(!our_glasses)
		return
	qdel(our_item)
	qdel(src)
	user.put_in_hands(our_glasses)
	update_icon()

/obj/item/clothing/glasses/meson/orange_glasses
	name = "Orange glasses"
	desc = "A pair of orange glasses. This pair has been fitted with an optical meson scanner."
	worn_icon_list = list(
		slot_glasses_str = 'icons/mob/clothing/eyes.dmi')
	icon_state = "meson_orange"
	worn_icon_state = "meson_orange"
	deactive_state = "deactivated_orange"

/obj/item/clothing/glasses/night/imager_goggles/orange_glasses
	name = "Orange glasses"
	desc = "A pair of orange glasses. This pair has been fitted with an internal optical imager scanner."
	worn_icon_list = list(
		slot_glasses_str = 'icons/mob/clothing/eyes.dmi')
	icon_state = "optical_orange"
	worn_icon_state = "optical_orange"
	deactive_state = "deactivated_orange"

/obj/item/clothing/glasses/hud/orange_glasses
	name = "Orange glasses"
	desc = "A pair of orange glasses. This pair has been fitted with an internal HealthMate HUD projector."
	worn_icon_list = list(
		slot_glasses_str = 'icons/mob/clothing/eyes.dmi')
	icon_state = "med_orange"
	worn_icon_state = "med_orange"
	deactive_state = "deactivated_orange"
	toggleable = TRUE
	hud_type = DATA_HUD_MEDICAL_ADVANCED
