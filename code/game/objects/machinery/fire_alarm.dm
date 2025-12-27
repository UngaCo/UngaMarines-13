/// Fire alarm missing circuit
#define FIRE_ALARM_BUILD_NO_CIRCUIT 0
/// Fire alarm has circuit but is missing wires
#define FIRE_ALARM_BUILD_NO_WIRES 1
/// Fire alarm has all components but isn't completed
#define FIRE_ALARM_BUILD_SECURED 2

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/machines/fire_alarm.dmi'
	icon_state = "fire0"
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	mouse_over_pointer = MOUSE_HAND_POINTER
	///Does the fire alarm trigger by fire? Toggled by multitool
	var/detecting = TRUE
	///Are the wires exposed? Toggled by screwdriver
	var/wiresexposed = FALSE
	/// 2 = complete, 1 = no wires,  0 = circuit gone
	var/buildstage = FIRE_ALARM_BUILD_SECURED

//whoever made these the sprites on these inverted I will find you, fix this shit and change the offset
// todo: actually replace all of these in maps
// also remove the 	switch(dir) when you do
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/firealarm, (-32))

/obj/machinery/firealarm/Initialize(mapload, direction, building)
	. = ..()

	if(direction)
		setDir(direction)

	if(building)
		buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
		wiresexposed = TRUE

	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

	if(is_mainship_level(z))
		RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_alert_change))

	update_icon()

/// wrapper so we can update the icon on [COMSIG_SECURITY_LEVEL_CHANGED]
/obj/machinery/firealarm/proc/on_alert_change(datum/source, datum/security_level/next_level, datum/security_level/previous_level)
	SIGNAL_HANDLER
	update_icon()

/obj/machinery/firealarm/update_icon()
	. = ..()
	set_light(0)
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return

	var/area/A = get_area(src)
	if(A.fire_alarm)
		set_light_color(LIGHT_COLOR_EMISSIVE_ORANGE)
	else
		set_light_color(SSsecurity_level?.current_security_level?.fire_alarm_light_color || LIGHT_COLOR_WHITE)

	set_light(initial(light_range))

/obj/machinery/firealarm/update_icon_state()
	. = ..()
	var/area/A = get_area(src)
	icon_state = "fire[!A.fire_alarm]"

/obj/machinery/firealarm/update_overlays()
	. = ..()
	if(wiresexposed || (machine_stat & BROKEN))
		. += image(icon, "fire_ob[buildstage]")
		return
	if(CHECK_BITFIELD(machine_stat, NOPOWER))
		return
	. += emissive_appearance(icon, "fire_o[(is_mainship_level(z)) ? SSsecurity_level.get_current_level_as_text() : "green"]", src)
	. += mutable_appearance(icon, "fire_o[(is_mainship_level(z)) ? SSsecurity_level.get_current_level_as_text() : "green"]")
	var/area/A = get_area(src)
	if(A.fire_alarm)
		. += mutable_appearance(icon, "fire_o1")

/obj/machinery/firealarm/fire_act(burn_level, flame_color)
	if(!detecting)
		return
	alarm()

/obj/machinery/firealarm/emp_act(severity)
	. = ..()
	if(prob(50 / severity))
		alarm()

/obj/machinery/firealarm/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		return
	wiresexposed = !wiresexposed
	update_icon()

/obj/machinery/firealarm/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!wiresexposed)
		return
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		return
	detecting = !detecting
	if(detecting)
		user.visible_message(span_warning("[user] has reconnected [src]'s detecting unit!"), span_warning("You have reconnected [src]'s detecting unit."))
	else
		user.visible_message(span_warning("[user] has disconnected [src]'s detecting unit!"), span_warning("You have disconnected [src]'s detecting unit."))

/obj/machinery/firealarm/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!wiresexposed)
		return
	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		return
	user.visible_message(span_warning("[user] has cut the wires inside \the [src]!"), "You have cut the wires inside \the [src].")
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	buildstage = FIRE_ALARM_BUILD_NO_WIRES
	update_icon()

/obj/machinery/firealarm/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!wiresexposed)
		return
	if(buildstage != FIRE_ALARM_BUILD_NO_WIRES)
		return
	to_chat(user, "You start prying out the circuit!")
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return
	new /obj/item/circuitboard/firealarm(loc)
	buildstage = FIRE_ALARM_BUILD_NO_CIRCUIT
	update_icon()

/obj/machinery/firealarm/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!wiresexposed)
		return
	if(buildstage != FIRE_ALARM_BUILD_NO_CIRCUIT)
		return
	to_chat(user, "You remove the fire alarm assembly from the wall!")
	var/obj/item/frame/fire_alarm/frame = new /obj/item/frame/fire_alarm
	frame.forceMove(user.loc)
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	qdel(src)

/obj/machinery/firealarm/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!wiresexposed)
		return

	switch(buildstage)
		if(FIRE_ALARM_BUILD_NO_WIRES)
			if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.use(5))
					to_chat(user, span_notice("You wire \the [src]."))
					buildstage = FIRE_ALARM_BUILD_SECURED
					return
				else
					to_chat(user, span_warning("You need 5 pieces of cable to do wire \the [src]."))
					return
		if(FIRE_ALARM_BUILD_NO_CIRCUIT)
			if(istype(I, /obj/item/circuitboard/firealarm))
				to_chat(user, "You insert the circuit!")
				qdel(I)
				buildstage = FIRE_ALARM_BUILD_NO_WIRES
				update_icon()

/obj/machinery/firealarm/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(buildstage != FIRE_ALARM_BUILD_SECURED)
		return FALSE

	return TRUE

/obj/machinery/firealarm/attack_hand(mob/user)
	. = ..()
	if(. || buildstage != FIRE_ALARM_BUILD_SECURED)
		return .
	add_fingerprint(user, "firealarm set")
	alarm(user)

/obj/machinery/firealarm/attack_hand_alternate(mob/user)
	. = ..()
	if(. || buildstage != FIRE_ALARM_BUILD_SECURED)
		return .
	add_fingerprint(user, "firealarm reset")
	reset(user)

/obj/machinery/firealarm/attack_ai(mob/user)
	var/area/A = get_area(src)
	if(A.fire_alarm)
		return reset()
	alarm()

/obj/machinery/firealarm/proc/alarm(mob/user, silent = FALSE)
	var/area/A = get_area(src)
	A?.fire_alert()
	update_icon()
	if(user && !silent)
		balloon_alert(user, "triggered alarm!")
	playsound(loc, 'sound/ambience/signal.ogg', 50, 0)

/obj/machinery/firealarm/proc/reset(mob/user, silent = FALSE)
	var/area/A = get_area(src)
	A?.fire_reset()
	update_icon()
	if(user && !silent)
		balloon_alert(user, "reset alarm")
