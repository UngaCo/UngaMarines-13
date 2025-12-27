/obj/item/clothing/gloves/yautja
	name = "ancient alien bracers"
	desc = "A pair of strange, alien bracers."

	icon = 'icons/obj/hunter/pred_gear.dmi'
	icon_state = "bracer"
	worn_icon_list = list(
		slot_gloves_str = 'icons/mob/hunter/pred_gear.dmi'
	)

	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_flags = ITEM_PREDATOR
	cold_protection_flags = HANDS
	heat_protection_flags = HANDS
	armor_protection_flags = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	resistance_flags = UNACIDABLE
	w_class = WEIGHT_CLASS_GIGANTIC

	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 20, FIRE = 20, ACID = 20)

	var/notification_sound = TRUE // Whether the bracer pings when a message comes or not
	var/charge = 1500
	var/charge_max = 1500
	/// The amount charged per process
	var/charge_rate = 30
	/// Cooldown on draining power from APC
	var/charge_cooldown = 3 MINUTES
	var/cloaked = 0
	var/cloak_timer = 0
	var/cloak_malfunction = 0
	/// Determines the alpha level of the cloaking device.
	var/cloak_alpha = 50
	/// If TRUE will change the mob invisibility level, providing 100% invisibility. Exclusively for events.
	var/true_cloak = FALSE

	var/translator_type = "Modern"
	var/exploding = 0
	var/inject_timer = 0
	var/healing_capsule_timer = 0
	var/explosion_type = 1 //0 is BIG explosion, 1 ONLY gibs the user.

	var/caster_deployed = FALSE
	var/obj/item/weapon/gun/energy/yautja/plasma_caster/caster

	var/wristblades_deployed = FALSE
	var/obj/item/weapon/wristblades/left_wristblades
	var/obj/item/weapon/wristblades/right_wristblades

	var/obj/item/weapon/yautja/combistick/combistick

	var/disc_timer = 0
	var/max_disc_cap = 2
	var/list/obj/item/explosive/grenade/spawnergrenade/smartdisc/discs = list()

	var/mob/living/carbon/human/real_owner //Pred spawned on, or thrall given to.
	var/mob/living/carbon/human/owner
	var/obj/item/clothing/gloves/yautja/linked_bracer //Bracer linked to this one (thrall or mentor).
	var/obj/item/card/id/bracer_chip/embedded_id

	var/datum/action/predator_action/bracer/pred_buy/claim_equipment = new

	var/datum/action/predator_action/bracer/cloaker/action_cloaker
	var/datum/action/predator_action/bracer/caster/action_caster
	var/datum/action/predator_action/bracer/wristblades/action_wristblades

	var/list/actions_to_add = list()

	/// What minimap icon this bracer should have
	var/minimap_icon = "predator"
	COOLDOWN_DECLARE(bracer_recharge)

/obj/item/clothing/gloves/yautja/Destroy() // FUCKING SHITCODE
	left_wristblades = null
	right_wristblades = null
	combistick = null
	discs.Cut()
	real_owner = null
	owner = null
	QDEL_NULL(caster)
	QDEL_NULL(embedded_id)
	QDEL_LIST(actions_to_add)
	STOP_PROCESSING(SSobj, src)
	if(linked_bracer)
		linked_bracer.linked_bracer = null
		linked_bracer = null
	return ..()

/obj/item/clothing/gloves/yautja/dropped(mob/living/carbon/human/user)
	STOP_PROCESSING(SSobj, src)
	item_flags = initial(item_flags)
	if(istype(user) && user.gloves == src)
		move_chip_to_bracer()
		if(cloaked)
			decloak(user)
		UnregisterSignal(user, list(COMSIG_MOB_REVIVE, COMSIG_MOB_DEATH, COMSIG_ATOM_TELEPORT))
		SSminimaps.remove_marker(user)
		for(var/datum/action/action in actions_to_add + action_cloaker + action_caster + action_wristblades)
			action.remove_action(user)
		if(!user.hunter_data?.claimed_equipment)
			claim_equipment.remove_action(user)
	return ..()

/obj/item/clothing/gloves/yautja/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLOVES)
		START_PROCESSING(SSobj, src)
		owner = user
		if(!real_owner)
			real_owner = user

		toggle_lock_internal(user, TRUE)
		RegisterSignals(user, list(COMSIG_MOB_REVIVE, COMSIG_MOB_DEATH), PROC_REF(update_minimap_icon))
		RegisterSignal(user, COMSIG_ATOM_TELEPORT, PROC_REF(owner_teleported))
		INVOKE_NEXT_TICK(src, PROC_REF(update_minimap_icon), user)
		for(var/datum/action/action in actions_to_add + action_cloaker + action_caster + action_wristblades)
			action.give_action(user)
		if(!user.hunter_data?.claimed_equipment)
			claim_equipment.give_action(user)
	return ..()

/obj/item/clothing/gloves/yautja/unequipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLOVES)
		move_chip_to_bracer()
		if(cloaked)
			decloak(user)
		UnregisterSignal(user, list(COMSIG_MOB_REVIVE, COMSIG_MOB_DEATH, COMSIG_ATOM_TELEPORT))
		SSminimaps.remove_marker(user)
		for(var/datum/action/action in actions_to_add + action_cloaker + action_caster + action_wristblades)
			action.remove_action(user)
		if(!user.hunter_data?.claimed_equipment)
			claim_equipment.remove_action(user)
	return ..()

/obj/item/clothing/gloves/yautja/pickup(mob/living/user)
	. = ..()
	if(!isyautja(user))
		to_chat(user, span_warning("The bracer feels cold against your skin, heavy with an unfamiliar, almost alien weight."))

/obj/item/clothing/gloves/yautja/proc/owner_teleported()
	SIGNAL_HANDLER

	if(cloaked)
		decloak(owner)
	update_minimap_icon()

//We use this to determine whether we should activate the given verb, or a random verb
//0 - do nothing, 1 - random function, 2 - this function
/obj/item/clothing/gloves/yautja/proc/check_random_function(mob/living/carbon/human/user, forced = FALSE, always_delimb = FALSE)
	if(!istype(user))
		return TRUE

	if(forced || HAS_TRAIT(user, TRAIT_YAUTJA_TECH))
		return FALSE

	if(user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS))) //let's do this here to avoid to_chats to dead guys
		return TRUE

	var/workingProbability = 20
	var/randomProbability = 10
	if(issynth(user)) // Synths are smart, they can figure this out pretty well
		workingProbability = 25
		randomProbability = 7
	else if(isresearcher(user)) // Researchers are smart as well, they can figure this out
		workingProbability = 40
		randomProbability = 4

	to_chat(user, span_notice("You press a few buttons..."))
	//Add a little delay so the user wouldn't be just spamming all the buttons
	user.next_move = world.time + 3
	if(do_after(usr, 3, NONE, src, BUSY_ICON_FRIENDLY))
		if(prob(randomProbability))
			return activate_random_verb(user)
		if(!prob(workingProbability))
			to_chat(user, span_warning("You fiddle with the buttons but nothing happens..."))
			return TRUE

	if(always_delimb)
		return delimb_user(user)

	return FALSE

//This is used to punish people that fiddle with technology they don't understand
/obj/item/clothing/gloves/yautja/proc/delimb_user(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(isyautja(user))
		return

	var/datum/limb/O = user.get_limb(check_zone("r_arm"))
	O.drop_limb()
	O = user.get_limb(check_zone("l_arm"))
	O.drop_limb()

	to_chat(user, span_notice("The device emits a strange noise and falls off... Along with your arms!"))
	playsound(user,'sound/weapons/wristblades_on.ogg', 15, 1)
	return TRUE

//We use this to activate random verbs for non-Yautja
/obj/item/clothing/gloves/yautja/proc/activate_random_verb(mob/user)
	var/option = rand(1, 11)
	//we have options from 1 to 8, but we're giving the user a higher probability of being punished if they already rolled this bad
	switch(option)
		if(1)
			. = wristblades_internal(user, TRUE)
		if(2)
			. = track_gear_internal(user, TRUE)
		if(3)
			. = cloaker_internal(user, TRUE)
		if(4)
			. = caster_internal(user, TRUE)
		if(5)
			. = injectors_internal(user, TRUE)
		if(6)
			. = call_disc_internal(user, TRUE)
		if(7)
			. = translate_internal(user, TRUE)
		if(8)
			. = call_combi_internal(user, TRUE)
		else
			. = delimb_user(user)

/obj/item/clothing/gloves/yautja/proc/call_combi_internal(mob/living/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	if(get_dist(combistick, src) <= 7 && isturf(combistick.loc))
		if(combistick in user.contents) //Can't yank if they are wearing it
			return FALSE
		if(user.put_in_active_hand(combistick))//Try putting it in our active hand, or, if it's full...
			if(!drain_power(user, 70)) //We should only drain power if we actually yank the chain back. Failed attempts can quickly drain the charge away.
				return TRUE
			user.visible_message(span_warning("<b>[user] yanks [combistick]'s chain back!</b>"), span_warning("<b>You yank [combistick]'s chain back!</b>"))
			playsound(user, SFX_CHAIN_SWING, 25)
		else if(user.put_in_inactive_hand(combistick))///...Try putting it in our inactive hand.
			if(!drain_power(user, 70)) //We should only drain power if we actually yank the chain back. Failed attempts can quickly drain the charge away.
				return TRUE
			user.visible_message(span_warning("<b>[user] yanks [combistick]'s chain back!</b>"), span_warning("<b>You yank [combistick]'s chain back!</b>"))
			playsound(user, SFX_CHAIN_SWING, 25)
		else //If neither hand can hold it, you must not have a free hand.
			to_chat(user, span_warning("You need a free hand to do this!</b>"))

/obj/item/clothing/gloves/yautja/proc/call_disc_internal(mob/living/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	if(disc_timer)
		to_chat(user, span_warning("Your bracers need some time to recuperate first."))
		return FALSE

	if(!drain_power(user, 70))
		return FALSE

	disc_timer = TRUE
	addtimer(VARSET_CALLBACK(src, disc_timer, FALSE), 10 SECONDS)

	for(var/obj/item/explosive/grenade/spawnergrenade/smartdisc/disc in discs)
		if(disc.spawned_item)
			if(get_dist(disc.spawned_item, src) <= 7)
				to_chat(user, span_warning("The [disc.spawned_item] skips back towards you!"))
				disc.spawned_item.drop_real_disc()
		else
			if(get_dist(disc, src) <= 10)
				if(isturf(disc.loc))
					disc.boomerang(user)
					playsound(disc, 'sound/effects/smartdisk_throw.ogg', 25)
	playsound(src, 'sound/effects/smartdisk_return.ogg', 30)
	return TRUE

/obj/item/clothing/gloves/yautja/proc/translate_internal(mob/living/carbon/human/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	if(user.client.prefs.muted & MUTE_IC)
		to_chat(user, span_danger("You cannot translate (muted)."))
		return

	user.create_typing_indicator()
	var/msg = sanitize(input(user, "Your bracer beeps and waits patiently for you to input your message.", "Translator", "") as text)
	user.remove_typing_indicator()
	if(!msg || !user.client)
		return

	if(!drain_power(user, 50))
		return

	log_say("[user.name != "Unknown" ? user.name : "([user.real_name])"] \[Yautja Translator\]: [msg] (CKEY: [user.key])")

	var/list/heard = list()
	for(var/CHM in get_hearers_in_view(7, user))
		if(ismob(CHM))
			heard += CHM

	var/span_class = "yautja_translator"
	if(translator_type != "Modern")
		if(translator_type == "Retro")
			span_class = "retro_translator"
		msg = replacetext(msg, "a", "@")
		msg = replacetext(msg, "e", "3")
		msg = replacetext(msg, "i", "1")
		msg = replacetext(msg, "o", "0")
		msg = replacetext(msg, "s", "5")
		msg = replacetext(msg, "l", "1")
		msg = replacetext(msg, "а", "@")
		msg = replacetext(msg, "е", "3")
		msg = replacetext(msg, "ч", "4")
		msg = replacetext(msg, "о", "0")
		msg = replacetext(msg, "з", "3")
		msg = replacetext(msg, "г", "r")
		msg = replacetext(msg, "ь", "b")
		msg = replacetext(msg, "в", "8")
		msg = replacetext(msg, "и", "u")
		msg = replacetext(msg, "к", "k")
		msg = replacetext(msg, "ш", "w")
		msg = replacetext(msg, "м", "m")
		msg = replacetext(msg, "п", "n")

	var/voice_name = "A strange voice"
	if(user.name == user.real_name && user.alpha == initial(user.alpha))
		voice_name = "<b>[user.name]</b>"

	for(var/mob/Q as anything in heard)
		if(Q.stat)
			continue //Unconscious
		Q.create_chat_message(user, /datum/language/common, msg,)
		to_chat(Q, "[span_info("[voice_name] says,")] <span class='[span_class]'>'[msg]'</span>")

/obj/item/clothing/gloves/yautja/proc/injectors_internal(mob/living/user, forced = FALSE, power_to_drain = 1000)
	. = check_random_function(user, forced)
	if(.)
		return

	if(user.get_active_held_item())
		to_chat(user, span_warning("Your active hand must be empty!"))
		return FALSE

	if(inject_timer)
		to_chat(user, span_warning("You recently activated the stabilising crystal. Be patient."))
		return FALSE

	if(!drain_power(user, power_to_drain))
		return FALSE

	inject_timer = TRUE
	owner.update_action_buttons()
	addtimer(CALLBACK(src, PROC_REF(injectors_ready)), 2 MINUTES)

	to_chat(user, span_notice("You feel a faint hiss and a crystalline injector drops into your hand."))
	var/obj/item/reagent_containers/hypospray/autoinjector/yautja/O = new(user)
	user.put_in_active_hand(O)
	playsound(src, 'sound/machines/click.ogg', 15, 1)
	return TRUE

/obj/item/clothing/gloves/yautja/proc/injectors_ready()
	if(ismob(loc))
		to_chat(loc, span_notice("Your bracers beep faintly and inform you that a new stabilising crystal is ready to be created."))
	inject_timer = FALSE
	owner.update_action_buttons()

/obj/item/clothing/gloves/yautja/hunter/verb/healing_capsule()
	set name = "Create Healing Capsule"
	set category = "Yautja"
	set desc = "Create a healing capsule for your healing gun."
	set src in usr
	. = healing_capsule_internal(usr, FALSE)

/obj/item/clothing/gloves/yautja/proc/healing_capsule_internal(mob/living/user, forced = FALSE)
	if(user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return FALSE

	. = check_random_function(user, forced)
	if(.)
		return

	if(user.get_active_held_item())
		to_chat(user, span_warning("Your active hand must be empty!"))
		return FALSE

	if(healing_capsule_timer)
		to_chat(usr, span_warning("Your bracer is still generating a new healing capsule!"))
		return FALSE

	if(!drain_power(user, 800))
		return FALSE

	healing_capsule_timer = TRUE
	addtimer(CALLBACK(src, PROC_REF(healing_capsule_ready)), 4 MINUTES)

	to_chat(user, span_notice("You feel your bracer churn as it pops out a healing capsule."))
	var/obj/item/tool/surgery/healing_gel/O = new(user)
	user.put_in_active_hand(O)
	playsound(src, 'sound/machines/click.ogg', 15, 1)
	return TRUE

/obj/item/clothing/gloves/yautja/proc/healing_capsule_ready()
	if(ismob(loc))
		to_chat(loc, span_notice("Your bracers beep faintly and inform you that a new healing capsule is ready to be created."))
	healing_capsule_timer = FALSE

/obj/item/clothing/gloves/yautja/proc/wristblades_internal(mob/living/carbon/human/user, forced = FALSE, power_to_drain = 50)
	. = check_random_function(user, forced)
	if(.)
		return

	if(wristblades_deployed)
		if(left_wristblades.loc == user)
			user.transferItemToLoc(left_wristblades, src, TRUE)
		if(right_wristblades.loc == user)
			user.transferItemToLoc(right_wristblades, src, TRUE)
		wristblades_deployed = FALSE
		to_chat(user, span_notice("You retract your [left_wristblades.name]."))
	else
		if(!drain_power(user, power_to_drain))
			return

		var/deploying_into_left_hand = user.hand ? TRUE : FALSE
		if(user.get_active_held_item())
			to_chat(user, span_warning("Your hand must be free to activate your wristblade!"))
			return
		var/datum/limb/hand = user.get_limb(deploying_into_left_hand ? "l_hand" : "r_hand")
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, span_warning("You can't hold that!"))
			return
		var/is_offhand_full = FALSE
		var/datum/limb/off_hand = user.get_limb(deploying_into_left_hand ? "r_hand" : "l_hand")
		if(user.get_inactive_held_item() || (!istype(off_hand) || !off_hand.is_usable()))
			is_offhand_full = TRUE
		if(deploying_into_left_hand)
			user.put_in_active_hand(left_wristblades)
			if(!is_offhand_full)
				user.put_in_inactive_hand(right_wristblades)
		else
			user.put_in_active_hand(right_wristblades)
			if(!is_offhand_full)
				user.put_in_inactive_hand(left_wristblades)
		wristblades_deployed = TRUE
		to_chat(user, span_notice("You activate your [left_wristblades]."))
		playsound(user, 'sound/weapons/wristblades_on.ogg', 15, TRUE)

/obj/item/clothing/gloves/yautja/proc/caster_internal(mob/living/carbon/human/user, forced = FALSE, power_to_drain = 50)
	. = check_random_function(user, forced)
	if(.)
		return

	if(caster_deployed)
		user.transferItemToLoc(caster, src, TRUE)
		caster_deployed = FALSE
	else
		if(!drain_power(user, power_to_drain))
			return
		if(user.get_active_held_item())
			to_chat(user, span_warning("Your hand must be free to activate your wristblade!"))
			return
		var/datum/limb/hand = user.get_limb(user.hand ? "l_hand" : "r_hand")
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, span_warning("You can't hold that!"))
			return
		user.put_in_active_hand(caster)
		caster_deployed = TRUE
		to_chat(user, span_notice("You activate your plasma caster. It is in [caster.mode] mode."))
		playsound(src, 'sound/weapons/pred_plasmacaster_on.ogg', 15, TRUE)

/obj/item/clothing/gloves/yautja/proc/cloaker_internal(mob/living/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	var/mob/living/carbon/human/M = user
	var/new_alpha = cloak_alpha

	if(!istype(M) || user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return FALSE

	if(cloaked) //Turn it off.
		if(cloak_timer > world.time)
			to_chat(M, span_warning("Your cloaking device is busy! Time left: <B>[max(round((cloak_timer - world.time) * 0.1), 1)]</b> seconds."))
			return FALSE
		decloak(user)
	else //Turn it on!
		if(exploding)
			to_chat(M, span_warning("Your bracer is much too busy violently exploding to activate the cloaking device."))
			return FALSE

		if(cloak_malfunction > world.time)
			to_chat(M, span_warning("Your cloak is malfunctioning and can't be enabled right now!"))
			return FALSE

		if(cloak_timer > world.time)
			to_chat(M, span_warning("Your cloaking device is still recharging! Time left: <B>[max(round((cloak_timer - world.time) * 0.1), 1)]</b> seconds."))
			return FALSE

		if(!drain_power(M, 50))
			return FALSE

		cloaked = TRUE

		action_cloaker.set_toggle(TRUE)

		RegisterSignal(M, COMSIG_HUMAN_EXTINGUISH, PROC_REF(wrapper_fizzle_camouflage))
		RegisterSignal(M, COMSIG_ATOM_BULLET_ACT, PROC_REF(bullet_act_sim))

		cloak_timer = world.time + 1.5 SECONDS
		if(true_cloak)
			M.invisibility = 35
			M.see_invisible = 35
			new_alpha = 75

		ADD_TRAIT(M, TRAIT_STEALTH, TRAIT_STEALTH)
		ADD_TRAIT(M, TRAIT_LIGHT_STEP, TRAIT_LIGHT_STEP)
		log_game("[key_name_admin(usr)] has enabled their cloaking device.")
		M.visible_message(span_warning("[M] vanishes into thin air!"), span_notice("You are now invisible to normal detection."))
		playsound(M.loc,'sound/effects/pred_cloakon.ogg', 30)
		animate(M, alpha = new_alpha, time = 1.5 SECONDS, easing = SINE_EASING|EASE_OUT)

		var/datum/atom_hud/xeno_infection/XI = GLOB.huds[DATA_HUD_XENO_INFECTION]
		XI.remove_from_hud(M)
		anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

//Any projectile can decloak a predator. It does defeat one free bullet though.
/obj/item/clothing/gloves/yautja/proc/bullet_act_sim(mob/living/carbon/human/H, atom/movable/projectile/proj)
	var/ammo_flags = proj.ammo.ammo_behavior_flags
	if(ammo_flags & (AMMO_SNIPER|AMMO_ENERGY|AMMO_XENO)) //<--- These will auto uncloak.
		decloak(H) //Continue on to damage.
	else if(prob(20))
		decloak(H)
		return

/obj/item/clothing/gloves/yautja/proc/wrapper_fizzle_camouflage()
	SIGNAL_HANDLER

	var/mob/wearer = src.loc
	wearer.visible_message(span_danger("[wearer]'s cloak fizzles out!"), span_danger("Your cloak fizzles out!"))

	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(5, 4, src)
	sparks.start()

	INVOKE_ASYNC(src, PROC_REF(decloak), wearer, TRUE)

/obj/item/clothing/gloves/yautja/proc/track_gear_internal(mob/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	var/mob/living/carbon/human/M = user

	var/dead_on_planet = 0
	var/dead_on_almayer = 0
	var/dead_low_orbit = 0
	var/gear_on_planet = 0
	var/gear_on_almayer = 0
	var/gear_low_orbit = 0
	var/closest = 10000
	var/direction = -1
	var/atom/areaLoc = null
	for(var/obj/item/I as anything in GLOB.loose_yautja_gear)
		var/atom/loc = get_true_location(I)
		if(!I)
			continue
		if(I.anchored)
			continue
		if(is_honorable_carrier(recursive_holder_check(I)))
			continue
		if(istype(get_area(I), /area/yautja))
			continue
		if(is_reserved_level(loc.z))
			gear_low_orbit++
		else if(is_mainship_level(loc.z))
			gear_on_almayer++
		else if(is_ground_level(loc.z))
			gear_on_planet++
		if(M.z == loc.z)
			var/dist = get_dist(M,loc)
			if(dist < closest)
				closest = dist
				direction = get_dir(M,loc)
				areaLoc = loc
	for(var/mob/living/carbon/human/Y as anything in GLOB.yautja_mob_list)
		if(Y.stat != DEAD)
			continue
		if(istype(get_area(Y), /area/yautja))
			continue
		if(is_reserved_level(Y.z))
			dead_low_orbit++
		else if(is_mainship_level(Y.z))
			dead_on_almayer++
		else if(is_ground_level(Y.z))
			dead_on_planet++
		if(M.z == Y.z)
			var/dist = get_dist(M,Y)
			if(dist < closest)
				closest = dist
				direction = get_dir(M,Y)
				areaLoc = loc

	var/output = FALSE
	if(dead_on_planet || dead_on_almayer || dead_low_orbit)
		output = TRUE
		to_chat(M, span_notice("Your bracer shows a readout of deceased Yautja bio signatures[dead_on_planet ? ", <b>[dead_on_planet]</b> in the hunting grounds" : ""][dead_on_almayer ? ", <b>[dead_on_almayer]</b> in orbit" : ""][dead_low_orbit ? ", <b>[dead_low_orbit]</b> in low orbit" : ""]."))
	if(gear_on_planet || gear_on_almayer || gear_low_orbit)
		output = TRUE
		to_chat(M, span_notice("Your bracer shows a readout of Yautja technology signatures[gear_on_planet ? ", <b>[gear_on_planet]</b> in the hunting grounds" : ""][gear_on_almayer ? ", <b>[gear_on_almayer]</b> in orbit" : ""][gear_low_orbit ? ", <b>[gear_low_orbit]</b> in low orbit" : ""]."))
	if(closest < 900)
		output = TRUE
		var/areaName = get_area_name(areaLoc)
		if(closest == 0)
			to_chat(M, span_notice("You are directly on top of the closest signature."))
		else
			to_chat(M, span_notice("The closest signature is [closest > 10 ? "approximately <b>[round(closest, 10)]</b>" : "<b>[closest]</b>"] paces <b>[dir2text(direction)]</b> in <b>[areaName]</b>."))
	if(!output)
		to_chat(M, span_notice("There are no signatures that require your attention."))


/obj/item/clothing/gloves/yautja/proc/explode(mob/living/carbon/victim)
	set waitfor = FALSE

	if(exploding)
		return

	exploding = TRUE
	var/turf/T = get_turf(src)
	if(explosion_type == SD_TYPE_BIG && victim.stat == CONSCIOUS && is_ground_level(T.z))
		playsound(src, 'sound/voice/predator/deathlaugh.ogg', 100, 0, 17)

	playsound(src, 'sound/effects/pred_countdown.ogg', 100, 0, 17)
	message_admins(font_size_xl("<a href='byond://?_src_=holder;[HrefToken(TRUE)];admincancelpredsd=1;bracer=[REF(src)];victim=[REF(victim)]'>CLICK TO CANCEL THIS PRED SD</a>"))

	our_socialistic_do_after(victim, rand(72, 80))

	T = get_turf(src)
	if(istype(T) && exploding)
		victim.apply_damage(50, BRUTE, "chest")
		if(victim)
			victim.gib() // kills the pred
			qdel(victim)
		if(explosion_type == SD_TYPE_BIG && is_ground_level(T.z))
			cell_explosion(T, 700, 100)
		else
			cell_explosion(T, 300, 100)

//No moduled do after??? skull issue tgmc!
/obj/item/clothing/gloves/yautja/proc/our_socialistic_do_after(mob/user, delay)
	if(!user)
		return FALSE

	delay *= user.do_after_coefficent()

	var/datum/progressbar/P = new /datum/progressbar(user, delay, user, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE)

	LAZYINCREMENT(user.do_actions, src)
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		P?.update(world.time - starttime)
		if(loc != user)
			. = FALSE
			break
	if(P)
		qdel(P)
	LAZYDECREMENT(user.do_actions, src)

/obj/item/clothing/gloves/yautja/proc/change_explosion_type()
	if(explosion_type == SD_TYPE_SMALL && exploding)
		to_chat(usr, span_warning("Why would you want to do this?"))
		return

	if(alert("Which explosion type do you want?","Explosive Bracers", "Small", "Big") == "Big")
		explosion_type = SD_TYPE_BIG
		log_attack("[key_name_admin(usr)] has changed their Self-Destruct to Large")
	else
		explosion_type = SD_TYPE_SMALL
		log_attack("[key_name_admin(usr)] has changed their Self-Destruct to Small")
		return

/obj/item/clothing/gloves/yautja/proc/activate_suicide_internal(mob/user, forced = FALSE)
	. = check_random_function(user, forced, TRUE)
	if(.)
		return

	var/mob/living/carbon/human/M = user

	if(cloaked)
		to_chat(M, span_warning("Not while you're cloaked. It might disrupt the sequence."))
		return
	if(M.stat == DEAD)
		to_chat(M, span_warning("Little too late for that now!"))
		return
	if(M.health < -50)
		to_chat(M, span_warning("As you fall into unconsciousness you fail to activate your self-destruct device before you collapse."))
		return
	if(M.stat)
		to_chat(M, span_warning("Not while you're unconcious..."))
		return

	var/obj/item/grab/G = M.get_active_held_item()
	if(istype(G))
		var/mob/living/carbon/human/victim = G.grabbed_thing
		if(victim.stat == DEAD)
			var/obj/item/clothing/gloves/yautja/hunter/bracer = victim.gloves
			var/message = "Are you sure you want to detonate this [victim.species]'s bracer?"
			if(isyautja(victim))
				message = "Are you sure you want to send this [victim.species] into the great hunting grounds?"
			if(istype(bracer))
				if(forced || alert(message,"Explosive Bracers", "Yes", "No") == "Yes")
					if(M.get_active_held_item() == G && victim && victim.gloves == bracer && !bracer.exploding)
						var/area/A = get_area(M)
						var/turf/T = get_turf(M)
						if(A)
							message_admins(font_size_huge("ALERT: [M] ([M.key]) triggered the predator self-destruct sequence of [victim] ([victim.key]) in [A.name] [ADMIN_JMP(T)]</font>"))
							log_attack("[key_name(M)] triggered the predator self-destruct sequence of [victim] ([victim.key]) in [A.name]")
						if (!bracer.exploding)
							bracer.explode(victim)
						M.visible_message(span_warning("[M] presses a few buttons on [victim]'s wrist bracer."),span_danger("You activate the timer. May [victim]'s final hunt be swift."))
						message_all_yautja("[M.real_name] has triggered [victim.real_name]'s bracer's self-destruction sequence.")
			else
				to_chat(M, span_warning("<b>This [victim.species] does not have a bracer attached.</b>"))
			return

	if(M.gloves != src && !forced)
		return

	if(exploding)
		if(forced || alert("Are you sure you want to stop the countdown?","Bracers", "Yes", "No") == "Yes")
			if(M.gloves != src)
				return
			if(M.stat == DEAD)
				to_chat(M, span_warning("Little too late for that now!"))
				return
			if(M.stat)
				to_chat(M, span_warning("Not while you're unconcious..."))
				return
			exploding = FALSE
			to_chat(M, span_notice("Your bracers stop beeping."))
			message_all_yautja("[M.real_name] has cancelled their bracer's self-destruction sequence.")
			message_admins("[key_name(M)] has deactivated their Self-Destruct.")
		return
	if(istype(M.wear_mask,/obj/item/clothing/mask/facehugger) || (M.status_flags & XENO_HOST))
		to_chat(M, span_warning("Strange...something seems to be interfering with your bracer functions..."))
		return
	if(forced || alert("Detonate the bracers? Are you sure?\n\nNote: If you activate SD for any non-accidental reason during or after a fight, you commit to the SD. By initially activating the SD, you have accepted your impending death to preserve any lost honor.","Explosive Bracers", "Yes", "No") == "Yes")
		if(M.gloves != src)
			return
		if(M.stat == DEAD)
			to_chat(M, span_warning("Little too late for that now!"))
			return
		if(M.stat)
			to_chat(M, span_warning("Not while you're unconcious..."))
			return
		if(exploding)
			return
		to_chat(M, span_danger("You set the timer. May your journey to the great hunting grounds be swift."))
		var/area/A = get_area(M)
		var/turf/T = get_turf(M)
		message_admins(font_size_huge("ALERT: [M] ([M.key]) triggered their predator self-destruct sequence [A ? "in [A.name]":""] [ADMIN_JMP(T)]"))
		log_attack("[key_name(M)] triggered their predator self-destruct sequence in [A ? "in [A.name]":""]")
		message_all_yautja("[M.real_name] has triggered their bracer's self-destruction sequence.")
		explode(M)

/obj/item/clothing/gloves/yautja/proc/move_chip_to_bracer()
	if(!embedded_id || !embedded_id.loc)
		return

	if(embedded_id.loc == src)
		return

	if(ismob(embedded_id.loc))
		var/mob/M = embedded_id.loc
		M.UnEquip(embedded_id, TRUE, src)
	else
		embedded_id.forceMove(src)

/obj/item/clothing/gloves/yautja/process()
	if(!ishuman(loc))
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/human/human_holder = loc

	if(charge < charge_max)
		var/charge_increase = charge_rate
		if(is_ground_level(human_holder.z))
			charge_increase = charge_rate * 0.25
		else if(is_mainship_level(human_holder.z))
			charge_increase = charge_rate * 0.5

		charge = min(charge + charge_increase, charge_max)
		var/perc_charge = (charge / charge_max * 100)
		human_holder.update_power_display(perc_charge)

	//Non-Yautja have a chance to get stunned with each power drain
	if(!cloaked)
		return
	if(human_holder.stat == DEAD)
		decloak(human_holder, TRUE)
	if(!HAS_TRAIT(human_holder, TRAIT_YAUTJA_TECH) && !human_holder.hunter_data.thralled && prob(15))
		decloak(human_holder)
		shock_user(human_holder)

/// handles decloaking only on HUNTER gloves
/obj/item/clothing/gloves/yautja/proc/decloak()
	return

/// Called to update the minimap icon of the predator
/obj/item/clothing/gloves/yautja/proc/update_minimap_icon()
	if(!ishuman(owner))
		return

	var/turf/wearer_turf = get_turf(owner)
	if(!wearer_turf)
		return

	SSminimaps.remove_marker(owner)

	if(!isyautja(owner))
		SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "bracer_stolen", MINIMAP_BLIPS_LAYER))
		if(owner.stat >= DEAD)
			if(HAS_TRAIT(owner, TRAIT_UNDEFIBBABLE))
				SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
			else
				SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "defibbable", MINIMAP_BLIPS_LAYER))
	else
		SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, minimap_icon, MINIMAP_BLIPS_LAYER))
		if(owner?.stat >= DEAD)
			SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))

/*
*This is the main proc for checking AND draining the bracer energy. It must have human passed as an argument.
*It can take a negative value in amount to restore energy.
*Also instantly updates the yautja power HUD display.
*/
/obj/item/clothing/gloves/yautja/proc/drain_power(mob/living/carbon/human/human, amount)
	if(!human)
		return FALSE
	if(charge < amount)
		to_chat(human, span_warning("Your bracers lack the energy. They have only <b>[charge]/[charge_max]</b> remaining and need <B>[amount]</b>."))
		return FALSE

	charge -= amount
	var/perc = (charge / charge_max * 100)
	human.update_power_display(perc)

	//Non-Yautja have a chance to get stunned with each power drain
	if(!HAS_TRAIT(human, TRAIT_YAUTJA_TECH) && !human.hunter_data.thralled)
		if(prob(15))
			if(cloaked)
				decloak(human)
				cloak_timer = world.time + 5 SECONDS
			shock_user(human)
			return FALSE

	return TRUE

/obj/item/clothing/gloves/yautja/proc/shock_user(mob/living/carbon/human/M)
	if(!HAS_TRAIT(M, TRAIT_YAUTJA_TECH) && !M.hunter_data.thralled)
		//Spark
		playsound(M, 'sound/effects/sparks2.ogg', 60, 1)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		M.visible_message(span_warning("[src] beeps and sends a shock through [M]'s body!"))
		//Stun and knock out, scream in pain
		M.apply_effect(2, EFFECT_STUN)
		M.apply_effect(2, EFFECT_PARALYZE)
		if(!M.species || !(M.species.species_flags & NO_PAIN))
			M.emote("scream")
		//Apply a bit of burn damage
		M.apply_damage(5, BURN, "l_arm", 0, 0, 0, src)
		M.apply_damage(5, BURN, "r_arm", 0, 0, 0, src)

/obj/item/clothing/gloves/yautja/examine(mob/user)
	. = ..()
	. += span_notice("They currently have <b>[charge]/[charge_max]</b> charge.")


// Toggle the notification sound
/obj/item/clothing/gloves/yautja/verb/toggle_notification_sound()
	set name = "Toggle Bracer Sound"
	set desc = "Toggle your bracer's notification sound."
	set category = "Yautja"
	set src in usr

	notification_sound = !notification_sound
	to_chat(usr, span_notice("The bracer's sound is now turned [notification_sound ? "on" : "off"]."))

/obj/item/clothing/gloves/yautja/proc/buy_gear(mob/living/carbon/human/wearer)
	if(wearer.gloves != src)
		to_chat(wearer, span_warning("You need to be wearing your thrall bracers to do this."))
		return

	if(wearer.hunter_data.claimed_equipment)
		to_chat(wearer, span_warning("You've already claimed your equipment."))
		return

	if(wearer.stat || (wearer.lying_angle && !wearer.resting && !wearer.has_status_effect(STATUS_EFFECT_SLEEPING)) || (wearer.has_status_effect(STATUS_EFFECT_PARALYZED) || wearer.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)) || wearer.lying_angle || wearer.buckled)
		to_chat(wearer, span_warning("You're not able to do that right now."))
		return

	if(!istype(get_area(wearer), /area/yautja))
		to_chat(wearer, span_warning("Not here. Only on the ship."))
		return

	var/sure = alert("An array of powerful weapons are displayed to you. Pick your gear carefully. If you cancel at any point, you will not claim your equipment.", "Sure?", "Begin the Hunt", "No, not now")
	if(sure != "Begin the Hunt")
		return

	var/list/melee = list(YAUTJA_GEAR_GLAIVE = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "glaive"), YAUTJA_GEAR_WHIP = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "whip"),YAUTJA_GEAR_SWORD = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "clansword"),YAUTJA_GEAR_SCYTHE = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "predscythe"), YAUTJA_GEAR_STICK = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "combistick"), YAUTJA_GEAR_SCIMS = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "scim"))
	var/list/other = list(YAUTJA_GEAR_LAUNCHER = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "spikelauncher"), YAUTJA_GEAR_PISTOL = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "plasmapistol"), YAUTJA_GEAR_DISC = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "disc"), YAUTJA_GEAR_FULL_ARMOR = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "fullarmor_ebony"), YAUTJA_GEAR_SHIELD = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "shield"), YAUTJA_GEAR_DRONE = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "falcon_drone"))
	var/list/restricted = list(YAUTJA_GEAR_LAUNCHER, YAUTJA_GEAR_PISTOL, YAUTJA_GEAR_FULL_ARMOR, YAUTJA_GEAR_SHIELD, YAUTJA_GEAR_DRONE) //Can only select them once each.

	var/list/secondaries = list()
	var/total_secondaries = 2

	var/main_weapon = show_radial_menu(wearer, wearer, melee)

	if(main_weapon == YAUTJA_GEAR_SCYTHE)
		var/list/scythe_variants = list(YAUTJA_GEAR_SCYTHE = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "predscythe"), YAUTJA_GEAR_SCYTHE_ALT = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "predscythe_alt"))
		main_weapon = show_radial_menu(wearer, wearer, scythe_variants)

	if(main_weapon == YAUTJA_GEAR_GLAIVE)
		var/list/glaive_variants = list(YAUTJA_GEAR_GLAIVE = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "glaive"), YAUTJA_GEAR_GLAIVE_ALT = image(icon = 'icons/obj/hunter/pred_gear.dmi', icon_state = "glaive_alt"))
		main_weapon = show_radial_menu(wearer, wearer, glaive_variants)

	if(!main_weapon)
		return
	for(var/i = 1 to total_secondaries)
		var/secondary = show_radial_menu(wearer, wearer, other)
		if(!secondary)
			return
		secondaries += secondary
		if(secondary in restricted)
			other -= secondary

	wearer.hunter_data.claimed_equipment = TRUE

	switch(main_weapon)
		if(YAUTJA_GEAR_GLAIVE)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/twohanded/yautja/glaive(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_GLAIVE_ALT)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/twohanded/yautja/glaive/alt(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_WHIP)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/yautja/chain(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_SWORD)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/yautja/sword(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_SCYTHE)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/yautja/scythe(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_SCYTHE_ALT)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/yautja/scythe/alt(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_STICK)
			wearer.equip_to_slot_if_possible(new /obj/item/weapon/yautja/combistick(wearer.loc), SLOT_S_STORE, warning = TRUE)
		if(YAUTJA_GEAR_SCIMS)
			if(wristblades_deployed)
				wristblades_internal(usr, TRUE)
			qdel(left_wristblades)
			qdel(right_wristblades)
			left_wristblades = new /obj/item/weapon/wristblades/scimitar(src)
			right_wristblades = new /obj/item/weapon/wristblades/scimitar(src)

	for(var/choice in secondaries)
		switch(choice)
			if(YAUTJA_GEAR_LAUNCHER)
				wearer.equip_to_slot_if_possible(new /obj/item/weapon/gun/energy/yautja/spike(wearer.loc), SLOT_IN_BELT, warning = TRUE)
			if(YAUTJA_GEAR_PISTOL)
				wearer.equip_to_slot_if_possible(new /obj/item/weapon/gun/energy/yautja/plasmapistol(wearer.loc), SLOT_IN_BELT, warning = TRUE)
			if(YAUTJA_GEAR_DISC)
				wearer.equip_to_slot_if_possible(new /obj/item/explosive/grenade/spawnergrenade/smartdisc(wearer.loc), SLOT_IN_BELT, warning = TRUE)
			if(YAUTJA_GEAR_FULL_ARMOR)
				if(wearer.wear_suit)
					wearer.dropItemToGround(wearer.wear_suit)
				wearer.equip_to_slot_if_possible(new /obj/item/clothing/suit/armor/yautja/hunter/full(wearer.loc, 0, wearer.client.prefs.predator_armor_material), SLOT_WEAR_SUIT, warning = TRUE)
			if(YAUTJA_GEAR_SHIELD)
				wearer.equip_to_slot_if_possible(new /obj/item/weapon/shield/riot/yautja(wearer.loc), SLOT_BACK, warning = TRUE)
			if(YAUTJA_GEAR_DRONE)
				wearer.equip_to_slot_if_possible(new /obj/item/clothing/falcon_drone(wearer.loc), SLOT_HEAD, warning = TRUE)

	claim_equipment.remove_action(wearer)

/obj/item/clothing/gloves/yautja/thrall
	name = "thrall bracers"
	desc = "A pair of strange alien bracers, adapted for human biology."

	color = "#b85440"
	minimap_icon = "thrall"

/obj/item/clothing/gloves/yautja/thrall/update_minimap_icon()
	if(!ishuman(owner))
		return

	var/turf/wearer_turf = get_turf(owner)
	if(!wearer_turf)
		return

	SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, minimap_icon, MINIMAP_BLIPS_LAYER))
	if(owner.stat >= DEAD)
		if(HAS_TRAIT(owner, TRAIT_UNDEFIBBABLE))
			SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
		else
			SSminimaps.add_marker(owner, MINIMAP_FLAG_YAUTJA, image('icons/UI_icons/map_blips.dmi', null, "defibbable", MINIMAP_BLIPS_LAYER))

/obj/item/clothing/gloves/yautja/hunter
	name = "clan bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."

	soft_armor = list(MELEE = 20, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 30, BIO = 25, FIRE = 25, ACID = 25)

	charge = 3000
	charge_max = 3000

	cloak_alpha = 4

	action_cloaker = new
	action_caster = new
	action_wristblades = new

	actions_to_add = list(
		new /datum/action/predator_action/bracer/translate,
		new /datum/action/predator_action/bracer/injectors,
		new /datum/action/predator_action/bracer/call_disc,
		new /datum/action/predator_action/bracer/yank_combistick,
		new /datum/action/predator_action/bracer/activate_suicide
	)

	var/name_active = TRUE
	var/caster_material = "ebony"

	var/owner_rank = CLAN_RANK_UNBLOODED_INT

/obj/item/clothing/gloves/yautja/hunter/Initialize(mapload, new_translator_type, new_caster_material, new_owner_rank)
	. = ..()
	if(new_owner_rank)
		owner_rank = new_owner_rank
	embedded_id = new(src)
	if(new_translator_type)
		translator_type = new_translator_type
	if(new_caster_material)
		caster_material = new_caster_material
	caster = new(src, FALSE, caster_material)
	left_wristblades = new(src)
	right_wristblades = new(src)

/obj/item/clothing/gloves/yautja/hunter/emp_act(severity)
	charge = max(charge - (severity * 500), 0)
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		if(wearer.gloves == src)
			wearer.visible_message(span_danger("You hear a hiss and crackle!"), span_danger("Your bracers hiss and spark!"), span_danger("You hear a hiss and crackle!"))
			if(cloaked)
				decloak(wearer)
		else
			var/turf/our_turf = get_turf(src)
			our_turf.visible_message(span_danger("You hear a hiss and crackle!"), span_danger("You hear a hiss and crackle!"))

/obj/item/clothing/gloves/yautja/hunter/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_GLOVES)
		move_chip_to_bracer()
	else if(embedded_id?.registered_name)
		embedded_id.set_user_data(user)

/obj/item/clothing/gloves/yautja/hunter/process()
	if(!ishuman(loc))
		STOP_PROCESSING(SSobj, src)
		return

	var/mob/living/carbon/human/human = loc

	if(cloaked)
		charge = max(charge - 10, 0)
		if(charge <= 0)
			decloak(loc)
		//Non-Yautja have a chance to get stunned with each power drain
		if(!isyautja(human))
			if(prob(15))
				decloak(human)
				shock_user(human)
		return
	return ..()

/obj/item/clothing/gloves/yautja/hunter/on_enter_storage(obj/item/storage/S)
	if(ishuman(loc))
		var/mob/living/carbon/human/human = loc
		if(cloaked)
			decloak(human)
	. = ..()

/obj/item/clothing/gloves/yautja/hunter/verb/check_auto_targets()
	set name = "Track Yautja Targets"
	set desc = "Find Yauja Targets."
	set category = "Yautja"
	set src in usr
	. = check_auto_targets_text(usr, FALSE)

/obj/item/clothing/gloves/yautja/hunter/proc/check_auto_targets_text(mob/user, forced = FALSE)
	. = check_random_function(user, forced)
	if(.)
		return

	. = span_info("Current priority targets:")
	if(length(user.hunter_data.targets))
		for(var/datum/huntdata/data in user.hunter_data.targets)
			. += span_warning("[data.owner.real_name] located in [get_area_name(data.owner)] and have [data.owner.life_kills_total + data.owner.life_value + 3] honor\n")
	else
		. += span_notice("NONE")
	to_chat(user, .)

/obj/item/clothing/gloves/yautja/hunter/verb/track_gear()
	set name = "Track Yautja Gear"
	set desc = "Find Yauja Gear."
	set category = "Yautja"
	set src in usr
	. = track_gear_internal(usr, FALSE)

/obj/item/clothing/gloves/yautja/hunter/decloak(mob/user, forced)
	if(!user)
		return

	UnregisterSignal(user, COMSIG_HUMAN_EXTINGUISH)
	UnregisterSignal(user, COMSIG_ATOM_BULLET_ACT)

	if(forced)
		cloak_malfunction = world.time + 10 SECONDS

	cloaked = FALSE

	REMOVE_TRAIT(user, TRAIT_STEALTH, TRAIT_STEALTH)
	REMOVE_TRAIT(user, TRAIT_LIGHT_STEP, TRAIT_LIGHT_STEP)
	log_game("[key_name_admin(usr)] has disabled their cloaking device.")
	user.visible_message(span_warning("[user] shimmers into existence!"), span_warning("Your cloaking device deactivates."))
	playsound(user.loc, 'sound/effects/pred_cloakoff.ogg', 35)
	user.alpha = initial(user.alpha)
	if(true_cloak)
		user.invisibility = initial(user.invisibility)
		user.see_invisible = initial(user.see_invisible)
	cloak_timer = world.time + 5 SECONDS

	var/datum/atom_hud/xeno_infection/XI = GLOB.huds[DATA_HUD_XENO_INFECTION]
	XI.add_to_hud(user)

	action_cloaker.set_toggle(FALSE)

	anim(user.loc, user, 'icons/mob/mob.dmi', null, "uncloak", null, user.dir)

/obj/item/clothing/gloves/yautja/hunter/verb/remove_tracked_item()
	set name = "Remove Item from Tracker"
	set desc = "Remove an item from the Yautja tracker."
	set category = "Yautja"
	set src in usr
	. = remove_tracked_item_internal(usr, FALSE)

/obj/item/clothing/gloves/yautja/hunter/proc/remove_tracked_item_internal(mob/living/user, forced = FALSE)
	if(user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return FALSE

	. = check_random_function(user, forced)
	if(.)
		return

	var/obj/item/tracked_item = user.get_active_held_item()
	if(!tracked_item)
		to_chat(user, span_warning("You need the item in your active hand to remove it from the tracker!"))
		return FALSE
	if(!(tracked_item in GLOB.tracked_yautja_gear))
		to_chat(user, span_warning("\The [tracked_item] isn't on the tracking system."))
		return FALSE
	tracked_item.RemoveElement(/datum/element/yautja_tracked_item)
	to_chat(user, span_notice("You remove \the <b>[tracked_item]</b> from the tracking system."))
	playsound(user.loc, 'sound/items/pred_bracer.ogg', 75, 1)
	return TRUE


/obj/item/clothing/gloves/yautja/hunter/verb/add_tracked_item()
	set name = "Add Item to Tracker"
	set desc = "Add an item to the Yautja tracker."
	set category = "Yautja"
	set src in usr
	. = add_tracked_item_internal(usr, FALSE)

/obj/item/clothing/gloves/yautja/hunter/proc/add_tracked_item_internal(mob/living/user, forced = FALSE)
	if(user.stat || (user.lying_angle && !user.resting && !user.has_status_effect(STATUS_EFFECT_SLEEPING)) || (user.has_status_effect(STATUS_EFFECT_PARALYZED) || user.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return FALSE

	. = check_random_function(user, forced)
	if(.)
		return

	var/obj/item/untracked_item = user.get_active_held_item()
	if(!untracked_item)
		to_chat(user, span_warning("You need the item in your active hand to remove it from the tracker!"))
		return FALSE
	if(untracked_item in GLOB.tracked_yautja_gear)
		to_chat(user, span_warning("\The [untracked_item] is already being tracked."))
		return FALSE
	untracked_item.AddElement(/datum/element/yautja_tracked_item)
	to_chat(user, span_notice("You add \the <b>[untracked_item]</b> to the tracking system."))
	playsound(user.loc, 'sound/items/pred_bracer.ogg', 75, 1)
	return TRUE

/obj/item/clothing/gloves/yautja/hunter/verb/bracername()
	set name = "Toggle Bracer Name"
	set desc = "Toggle whether fellow Yautja that examine you will be able to see your name."
	set category = "Yautja"
	set src in usr

	var/mob/living/mob = usr
	if(mob.stat || (mob.lying_angle && !mob.resting && !mob.has_status_effect(STATUS_EFFECT_SLEEPING)) || (mob.has_status_effect(STATUS_EFFECT_PARALYZED) || mob.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return

	name_active = !name_active
	to_chat(usr, span_notice("\The [src] will [name_active ? "now" : "no longer"] show your name when fellow Yautja examine you."))

/obj/item/clothing/gloves/yautja/hunter/verb/idchip()
	set name = "Toggle ID Chip"
	set desc = "Reveal/Hide your embedded bracer ID chip."
	set category = "Yautja"
	set src in usr

	var/mob/living/mob = usr
	if(mob.stat || (mob.lying_angle && !mob.resting && !mob.has_status_effect(STATUS_EFFECT_SLEEPING)) || (mob.has_status_effect(STATUS_EFFECT_PARALYZED) || mob.has_status_effect(STATUS_EFFECT_UNCONSCIOUS)))
		return

	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !HAS_TRAIT(usr, TRAIT_YAUTJA_TECH))
		to_chat(usr, span_warning("You do not know how to use this."))
		return

	if(H.wear_id == embedded_id)
		to_chat(H, span_notice("You retract your ID chip."))
		playsound(src, 'sound/machines/click.ogg', 15, 1)
		move_chip_to_bracer()
	else if(H.wear_id)
		to_chat(H, span_warning("Something is obstructing the deployment of your ID chip!"))
	else
		to_chat(H, span_notice("You expose your ID chip."))
		playsound(src, 'sound/machines/click.ogg', 15, 1)
		if(!H.equip_to_slot_if_possible(embedded_id, SLOT_WEAR_ID, override_nodrop = TRUE))
			to_chat(H, span_warning("Something went wrong during your chip's deployment! (Make a Bug Report about this)"))
			move_chip_to_bracer()

/// Verb to let Yautja attempt the unlocking.
/obj/item/clothing/gloves/yautja/hunter/verb/toggle_lock()
	set name = "Toggle Bracer Lock"
	set desc = "Toggle the lock on your bracers, allowing them to be removed."
	set category = "Yautja"
	set src in usr

	if(usr.stat)
		to_chat(usr, span_warning("You can't do that right now..."))
		return FALSE
	if(!HAS_TRAIT(usr, TRAIT_YAUTJA_TECH))
		to_chat(usr, span_warning("You have no idea how to use this..."))
		return FALSE

	attempt_toggle_lock(usr, FALSE)
	return TRUE

/// Handles all the locking and unlocking of bracers.
/obj/item/clothing/gloves/yautja/proc/attempt_toggle_lock(mob/user, force_lock)
	if(!user)
		return FALSE

	if(!(equip_slot_flags & ITEM_SLOT_GLOVES))
		return FALSE

	var/obj/item/grab/held_mob = user.get_active_held_item()
	if(!istype(held_mob))
		log_attack("[key_name_admin(usr)] has [HAS_TRAIT(src, TRAIT_NODROP) ? "unlocked" : "locked"] their own bracer.")
		toggle_lock_internal(user)
		return TRUE

	var/mob/living/carbon/human/victim = held_mob.grabbed_thing
	var/obj/item/clothing/gloves/yautja/hunter/bracer = victim.gloves
	if(isyautja(victim) && !(victim.stat == DEAD))
		to_chat(user, span_warning("You cannot unlock the bracer of a living hunter!"))
		return FALSE

	if(!istype(bracer))
		to_chat(user, span_warning("<b>This [victim.species] does not have a bracer attached.</b>"))
		return FALSE

	if(alert("Are you sure you want to unlock this [victim.species]'s bracer?", "Unlock Bracers", "Yes", "No") != "Yes")
		return FALSE

	if(user.get_active_held_item() == held_mob && victim && victim.gloves == bracer)
		user.visible_message(span_warning("[user] presses a few buttons on [victim]'s wrist bracer."), span_danger("You unlock the bracer."))
		bracer.toggle_lock_internal(victim)
		return TRUE

/// The actual unlock/lock function.
/obj/item/clothing/gloves/yautja/proc/toggle_lock_internal(mob/wearer, force_lock)
	if(HAS_TRAIT(src, TRAIT_NODROP) && !force_lock)
		REMOVE_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
		if(!isyautja(wearer))
			to_chat(wearer, span_warning("The bracer beeps pleasantly, releasing it's grip on your forearm."))
		else
			to_chat(wearer, span_warning("With an angry blare the bracer releases your forearm."))
		playsound(src, 'sound/items/air_release.ogg', 15, 1)
		return TRUE

	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	if(isyautja(wearer))
		to_chat(wearer, span_warning("The bracer clamps securely around your forearm and beeps in a comfortable, familiar way."))
	else
		to_chat(wearer, span_warning("The bracer clamps painfully around your forearm and beeps angrily. It won't come off!"))
	playsound(src, 'sound/machines/click.ogg', 15, 1)
	return TRUE
