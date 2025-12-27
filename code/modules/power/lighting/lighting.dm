///Power usage mult by luminosity
#define LIGHTING_POWER_FACTOR 10

/obj/machinery/light
	name = "light fixture"
	desc = "A lighting fixture."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube_empty"
	base_icon_state = "tube"
	anchored = TRUE
	layer = FLY_LAYER
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	light_system = STATIC_LIGHT //do not change this, byond and potato pcs no like
	obj_flags = CAN_BE_HIT
	/// Power usage and light range when on
	var/brightness = 8
	/// Basically the light_power of the emitted light source
	var/bulb_power = 1
	/// Light colour
	var/bulb_colour = COLOR_WHITE
	/// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/status = LIGHT_OK
	///is our light flickering?
	var/flickering = FALSE
	/// The type of light item
	var/light_type = /obj/item/light_bulb/tube
	///what's the duration that the light switches between on and off while flickering
	var/flicker_time = 2 SECONDS
	/// The bulb item name in this light
	var/fitting = "tube"
	/// Count of number of times switched on/off. this is used to calc the probability the light burns out
	var/switchcount = 0
	/// True if rigged to explode
	var/rigged = FALSE
	///holds the state of our flickering
	var/light_flicker_state = FALSE
	///if true randomize the time we turn on and off
	var/random_flicker = FALSE
	///upper bounds of potential flicker time when randomized
	var/flicker_time_upper_max = 10 SECONDS
	///lower bounds of potential flicker time when randomized
	var/flicker_time_lower_min = 0.2 SECONDS
	///looping sound for flickering lights
	var/datum/looping_sound/flickeringambient/lightambient
	/// Used for mapping to set custom pixel_x
	var/pixel_x_offset
	/// Used for mapping to set custom pixel_y
	var/pixel_y_offset
	/// Is our security level red or higher? Used for emergency_update()
	var/security_level_high = FALSE

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload, ...)
	. = ..()

	GLOB.nightfall_toggleable_lights += src

	switch(fitting)
		if("tube")
			if(prob(2))
				broken(TRUE)
		if("bulb")
			if(prob(5))
				broken(TRUE)

	update_offsets()
	update(FALSE)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	var/area/A = get_area(src)
	turn_light(null, (A.lightswitch && A.power_light))

/obj/machinery/light/Destroy()
	QDEL_NULL(lightambient)
	GLOB.nightfall_toggleable_lights -= src
	return ..()

/obj/machinery/light/setDir(newdir)
	. = ..()
	update_offsets()

/obj/machinery/light/update_overlays()
	. = ..()
	switch(status)		// set icon_states
		if(LIGHT_OK)
			. += "[base_icon_state]_[light_on]"
		if(LIGHT_BURNED)
			. += "[base_icon_state]_burned"
		if(LIGHT_BROKEN)
			. += "[base_icon_state]_broken"

/obj/machinery/light/ex_act(severity)
	if(severity >= EXPLODE_HEAVY)
		qdel(src)
		return
	broken()

/obj/machinery/light/fire_act(exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673))) //0% at <400C, 100% at >500C
		broken()

/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	if(flickering)
		lightambient.start(src)
		addtimer(CALLBACK(src, PROC_REF(flicker)), flicker_time)
	turn_light(null, (A.lightswitch && A.power_light))

/obj/machinery/light/turn_light(mob/user, toggle_on)
	if (status != LIGHT_OK)
		return
	. = ..()
	light_on = toggle_on
	update(TRUE, toggle_on)

/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += "It is turned [light_on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."
	if(flickering)
		. += "The fixture seems to be damaged and the cabling is partially broken."

/obj/machinery/light/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/lightreplacer))
		if(!isliving(user))
			return

		var/mob/living/living_user = user
		var/obj/item/lightreplacer/lightreplacer = I
		lightreplacer.ReplaceLight(src, living_user)
		return

	if(istype(I, /obj/item/light_bulb))
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return

		var/obj/item/light_bulb/L = I
		if(!istype(L, light_type))
			to_chat(user, "This type of light requires a [fitting].")
			return

		status = L.status
		to_chat(user, "You insert \the [L].")
		switchcount = L.switchcount
		rigged = L.rigged
		brightness = L.brightness
		turn_light(user, TRUE)
		update()
		if(!user.temporarilyRemoveItemFromInventory(L))
			return

		qdel(L)

		if(light_on && rigged)
			explode()
		return

	if(status == LIGHT_EMPTY && has_power() && (I.atom_flags & CONDUCT))
		to_chat(user, "You stick \the [I] into the light socket!")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread(src)
		s.set_up(3, 1, loc)
		s.start()
		if(prob(75))
			electrocute_mob(user, get_area(src), src, rand(7, 10) * 0.1)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user, def_zone)
	. = ..()
	if(QDELETED(src))
		return
	if(status != LIGHT_OK && status != LIGHT_BURNED)
		return
	if(!prob(1 + I.force * 5))
		return
	visible_message("[user] smashed the light!", "You hit the light, and it smashes!")
	if(light_on && (I.atom_flags & CONDUCT) && prob(12))
		electrocute_mob(user, get_area(src), src, 0.3)
	broken()

/obj/machinery/light/screwdriver_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(status != LIGHT_EMPTY)
		balloon_alert(user, "Remove bulb first")
		return TRUE

	playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
	user.visible_message("[user] opens [src]'s casing.", \
		"You open [src]'s casing.", "You hear a noise.")
	var/obj/machinery/light_construct/newlight
	switch(fitting)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(loc)
			newlight.icon_state = "bulb-construct-stage2"
		else //we'll assume tube as the default in case of shitcodery
			newlight = new /obj/machinery/light_construct(loc)
			newlight.icon_state = "tube-construct-stage2"
	newlight.setDir(dir)
	newlight.stage = 2
	qdel(src)
	return TRUE

/obj/machinery/light/attack_ai(mob/user)
	flicker(1)

//Xenos smashing lights
/obj/machinery/light/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = MELEE, effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	if(status == LIGHT_BROKEN)
		return FALSE
	xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_SMASH)
	xeno_attacker.visible_message(span_danger("\The [xeno_attacker] smashes [src]!"), \
	span_danger("We smash [src]!"), null, 5)
	broken()

/obj/machinery/light/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			visible_message(span_warning("[user] smashed the light!"), null, "You hear a tinkle of breaking glass")
			broken()
			return

	// make it burn hands if not wearing fire-insulated gloves
	if(light_on)
		var/prot = 0
		var/mob/living/carbon/human/H = user
		var/datum/limb/limb_check = H.get_limb(H.hand? "l_hand" : "r_hand")

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || isrobot(H) || (limb_check.limb_status & LIMB_ROBOT))
			to_chat(user, "You remove the light [fitting].")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return				// if burned, don't remove the light
	else
		to_chat(user, "You remove the light [fitting].")

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light_bulb/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = brightness

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()

	if(!user.put_in_active_hand(L))	//succesfully puts it in our active hand
		L.forceMove(loc) //if not, put it on the ground
	status = LIGHT_EMPTY
	update()

///Sets the correct offsets for the object and light based on dir
/obj/machinery/light/proc/update_offsets()
	switch(dir)
		if(NORTH)
			light_pixel_y = 15
			light_pixel_x = 0
			pixel_y = 20
			pixel_x = 0
		if(SOUTH)
			light_pixel_y = -15
			light_pixel_x = 0
			pixel_y = 0
			pixel_x = 0
		if(WEST)
			light_pixel_y = 0
			light_pixel_x = 15
			pixel_y = 0
			pixel_x = -10
		if(EAST)
			light_pixel_y = 0
			light_pixel_x = -15
			pixel_y = 0
			pixel_x = 10
	if(!isnull(pixel_x_offset))
		pixel_x = pixel_x_offset
	if(!isnull(pixel_y_offset))
		pixel_y = pixel_y_offset

///update the light state then icon
/obj/machinery/light/proc/update(trigger = TRUE, toggle_on = TRUE)
	var/area/active_area = get_area(src)
	if(!active_area.lightswitch || !active_area.power_light || status != LIGHT_OK || !toggle_on)
		use_power = IDLE_POWER_USE
		set_light(0)
		active_power_usage = (luminosity * LIGHTING_POWER_FACTOR)
		update_icon()
		return

	var/new_base_icon_state = initial(base_icon_state)
	var/new_light_color = color ? color : bulb_colour
	var/new_light_range = brightness
	var/new_light_power = bulb_power

	var/matching = light && new_light_range == light.light_range && new_light_power == light.light_power && new_light_color == light.light_color
	if(matching) // is this check really needed?
		return

	if(active_area.fire_alarm)
		new_base_icon_state = "[initial(base_icon_state)]_red"
		new_light_color = COLOR_FIRE_LIGHT_RED
		new_light_range = 9
		new_light_power = 0.5
	else if(security_level_high)
		new_base_icon_state = "[initial(base_icon_state)]_red"
		new_light_color = COLOR_SOMEWHAT_LIGHTER_RED
		new_light_range = 7.5
		if(prob(75)) //randomize light range on most lights, patchy lighting gives a sense of danger
			var/rangelevel = pick(5.5,6.0,6.5,7.0)
			if(prob(15))
				rangelevel -= pick(0.5,1.0,1.5,2.0)
			new_light_range = rangelevel

	switchcount++
	if(trigger)
		if(rigged && (status == LIGHT_OK))
			explode()
			return
		if(prob(min(60, (switchcount ^ 2) * 0.01)))
			broken()
			return

	use_power = ACTIVE_POWER_USE
	active_power_usage = (luminosity * LIGHTING_POWER_FACTOR)

	base_icon_state = new_base_icon_state
	light_color = new_light_color
	light_range = new_light_range
	light_power = new_light_power
	update_light()
	update_appearance(UPDATE_ICON)

///Returns true if area is powered and has lights toggled on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

///flicker lights on and off
/obj/machinery/light/proc/flicker(toggle_flicker = FALSE)
	if(!has_power())
		lightambient.stop(src)
		return
	if(toggle_flicker)
		if(status != LIGHT_OK)
			addtimer(CALLBACK(src, PROC_REF(flicker), TRUE), flicker_time)
			return
		flickering = !flickering
		if(flickering)
			lightambient.start(src)
		else
			lightambient.stop(src)
	if(random_flicker)
		flicker_time = rand(flicker_time_lower_min, flicker_time_upper_max)
	if(status != LIGHT_OK)
		lightambient.stop(src)
		flickering = FALSE
		addtimer(CALLBACK(src, PROC_REF(flicker), TRUE), flicker_time)
		return
	light_flicker_state = !light_flicker_state
	if(!light_flicker_state)
		flick("[base_icon_state]_flick_off", src)
		//delay the power change long enough to get the flick() animation off
		addtimer(CALLBACK(src, PROC_REF(flicker_power_state)), 0.3 SECONDS)
	else
		flick("[base_icon_state]_flick_on", src)
		addtimer(CALLBACK(src, PROC_REF(flicker_power_state)), 0.3 SECONDS)
		flicker_time = flicker_time * 2 //for effect it's best if the amount of time we spend off is more than the time we spend on
	if(!flickering)
		return
	addtimer(CALLBACK(src, PROC_REF(flicker)), flicker_time)

///proc to toggle power on and off for light
/obj/machinery/light/proc/flicker_power_state(turn_on = TRUE, turn_off = FALSE)
	if(!light_flicker_state)
		pick(playsound(loc, 'sound/effects/lightfizz.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz2.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz3.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz4.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz5.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz6.ogg', 10, TRUE))
		update(FALSE)
	else
		pick(playsound(loc, 'sound/effects/lightfizz.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz2.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz3.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz4.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz5.ogg', 10, TRUE), playsound(loc, 'sound/effects/lightfizz6.ogg', 10, TRUE))
		turn_light(null, FALSE)

///break the light and make sparks if was on
/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		if(status == LIGHT_OK && has_power())
			var/datum/effect_system/spark_spread/spark_spread = new /datum/effect_system/spark_spread(src)
			spark_spread.set_up(3, 1, loc)
			spark_spread.start()
	status = LIGHT_BROKEN
	update()

///Fixes the light
/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	brightness = initial(brightness)
	update()

///Blows up the light
/obj/machinery/light/proc/explode()
	broken()	// break it first to give a warning
	addtimer(CALLBACK(src, PROC_REF(delayed_explosion)), 0.5 SECONDS)

/obj/machinery/light/proc/delayed_explosion()
	cell_explosion(loc, 70, 30)
	qdel(src)

/obj/machinery/light/punch_act(mob/living/carbon/xenomorph/xeno, ...)
	. = ..()
	attack_alien(xeno)

/obj/machinery/light/mainship/Initialize(mapload)
	. = ..()
	GLOB.mainship_lights += src
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_alert_change))
	var/area/A = get_area(src)
	RegisterSignal(A, COMSIG_AREA_FIRE_ALARM_SET, PROC_REF(on_fire_alarm))

/obj/machinery/light/mainship/Destroy()
	. = ..()
	GLOB.mainship_lights -= src

/// Changes the light's appearance based on the security level when [COMSIG_SECURITY_LEVEL_CHANGED] sends a signal
/obj/machinery/light/mainship/proc/on_alert_change(datum/source, datum/security_level/new_level, datum/security_level/previous_level)
	SIGNAL_HANDLER
	var/most_recent_level_red_lights = ((previous_level.sec_level_flags & SEC_LEVEL_FLAG_RED_LIGHTS))
	if(!(new_level.sec_level_flags & SEC_LEVEL_FLAG_RED_LIGHTS) && most_recent_level_red_lights)
		security_level_high = FALSE
		update()
	else if((new_level.sec_level_flags & SEC_LEVEL_FLAG_RED_LIGHTS) && !most_recent_level_red_lights)
		security_level_high = TRUE
		update()

/obj/machinery/light/mainship/proc/on_fire_alarm(datum/source)
	SIGNAL_HANDLER
	update()

/obj/machinery/light/mainship/small
	icon_state = "bulb_empty"
	base_icon_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light_bulb/bulb

/obj/machinery/light/floor
	name = "floor light fixture"
	desc = "A small lighting fixture."
	icon_state = "floortube_empty"
	base_icon_state = "floortube"
	brightness = 6
	layer = MAP_SWITCH(LOWER_RUNE_LAYER, LOW_OBJ_LAYER)
	plane = FLOOR_PLANE

/obj/machinery/light/floor/update_offsets()
	return

/obj/machinery/light/red
	base_icon_state = "tube_red"
	light_color = LIGHT_COLOR_FLARE
	brightness = 3
	bulb_power = 0.5
	bulb_colour = LIGHT_COLOR_FLARE

/obj/machinery/light/small
	icon_state = "bulb_empty"
	base_icon_state = "bulb"
	fitting = "bulb"
	brightness = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light_bulb/bulb

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/light_bulb/tube/large
	brightness = 12

/obj/machinery/light/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)

/obj/machinery/light/small/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE)
