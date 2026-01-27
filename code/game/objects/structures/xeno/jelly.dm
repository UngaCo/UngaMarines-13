/obj/item/resin_jelly
	name = "resin jelly"
	desc = "A foul, viscous resin jelly that doesnt seem to burn easily."
	icon = 'icons/Xeno/xeno_materials.dmi'
	icon_state = "resin_jelly"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 200, ACID = 0)
	var/immune_time = 15 SECONDS
	///Holder to ensure only one user per resin jelly.
	var/current_user

/obj/item/resin_jelly/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = MELEE, effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(xeno_attacker.xeno_caste.can_flags & CASTE_CAN_HOLD_JELLY)
		return attack_hand(xeno_attacker)
	if(xeno_attacker.do_actions || !isnull(current_user))
		return
	current_user = xeno_attacker
	activate_jelly(xeno_attacker)

/obj/item/resin_jelly/attack_self(mob/living/carbon/xenomorph/user)
	//Activates if the item itself is clicked in hand.
	if(!isxeno(user))
		return
	if(user.do_actions || !isnull(current_user))
		return
	current_user = user
	activate_jelly(user)

/obj/item/resin_jelly/attack(mob/living/carbon/xenomorph/M, mob/living/user)
	//Activates if active hand and clicked on mob in game.
	//Can target self so we need to check for that.
	if(!isxeno(user))
		return TRUE
	if(!isxeno(M))
		M.balloon_alert(user, "Cannot apply")
		return FALSE
	if(user.do_actions || !isnull(current_user))
		return FALSE
	current_user = M
	activate_jelly(M)
	user.temporarilyRemoveItemFromInventory(src)
	return FALSE

/obj/item/resin_jelly/proc/activate_jelly(mob/living/carbon/xenomorph/user)
	user.visible_message(span_notice("[user]'s chitin begins to gleam with an unseemly glow..."), span_xenonotice("We feel powerful as we are covered in [src]!"))
	user.emote("roar")
	user.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	SEND_SIGNAL(user, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED)
	qdel(src)

/obj/item/resin_jelly/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	if(isxenohivelord(thrower))
		RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(jelly_throw_hit))
	. = ..()

/obj/item/resin_jelly/proc/jelly_throw_hit(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isxeno(hit_atom))
		return
	var/mob/living/carbon/xenomorph/xenomorph_target = hit_atom
	if(xenomorph_target.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	xenomorph_target.visible_message(span_notice("[xenomorph_target] is splattered with jelly!"))
	INVOKE_ASYNC(src, PROC_REF(activate_jelly), xenomorph_target)

///////////////////////
/// Globadier Mines ///
///////////////////////

/obj/structure/xeno/acid_mine
	name = "acid mine"
	desc = "A weird bulb, filled with acid."
	icon = 'icons/obj/items/mine.dmi'
	icon_state = "acid_mine"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 5
	hit_sound = SFX_ALIEN_RESIN_BREAK
	/// The damage dealt to mobs nearby the detonation point of the mine
	var/acid_damage = 30

/obj/structure/xeno/acid_mine/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(oncrossed),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/xeno/acid_mine/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	detonate(blame_mob)
	return ..()

/// Checks if the mob walking over the mine is human, and calls detonate if so
/obj/structure/xeno/acid_mine/proc/oncrossed(datum/source, atom/movable/A, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ishuman(A))
		return
	if(CHECK_MULTIPLE_BITFIELDS(A.allow_pass_flags, HOVERING))
		return
	INVOKE_ASYNC(src, PROC_REF(detonate), A)

///Handles detonating the mine, and dealing damage to those nearby
/obj/structure/xeno/acid_mine/proc/detonate(triggerer)
	for(var/spatter_effect in filled_turfs(get_turf(src), 1, "square", pass_flags_checked = PASS_AIR))
		new /obj/effect/temp_visual/acid_splatter(spatter_effect)
	for(var/mob/living/carbon/human/human_victim AS in cheap_get_humans_near(src,1))
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_L_LEG, ACID,  penetration = 30)
		human_victim.apply_damage(acid_damage/2, BURN, BODY_ZONE_R_LEG, ACID,  penetration = 30)
		playsound(src, "sound/bullets/acid_impact1.ogg", 10)
	qdel(src)

/obj/structure/xeno/acid_mine/gas_mine
	name = "gas mine"
	desc = "A weird bulb, overflowing with acid. Small wisps of gas escape every so often."
	icon_state = "gas_mine"
	acid_damage = 40

/obj/structure/xeno/acid_mine/gas_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/acid/opaque/smog = new(get_turf(src))
	smog.set_up(1,src)
	smog.start()

//////////////////
/// Resin Mine ///
//////////////////

/obj/structure/xeno/acid_mine/resin_mine
	name = "resin mine"
	desc = "A translucent purple blob, insides lined with clear ampoules of resin."
	icon_state = "resin_mine"

/obj/structure/xeno/acid_mine/resin_mine/detonate(triggerer)
	var/cannotbuild = FALSE
	for(var/turf/resin_tile in filled_turfs(get_turf(src), 0.5, "circle", pass_flags_checked = PASS_AIR))
		cannotbuild = FALSE
		if((resin_tile.density || istype(resin_tile, /turf/open/space))) // No structures in space
			continue

		for(var/obj/O in resin_tile.contents)
			if(istype(O, /obj/alien/resin))
				cannotbuild = TRUE

		if(!cannotbuild)
			new /obj/alien/resin/sticky(resin_tile)

	for(var/mob/living/carbon/human/affected AS in cheap_get_humans_near(src,1))
		if(affected.stat == DEAD)
			continue
		var/throwloc = affected.loc
		for(var/x in 1 to 6)
			throwloc = get_step(throwloc, REVERSE_DIR(affected.dir))
		affected.throw_at(throwloc, 12, 2.5, src, TRUE)
	qdel(src)

//////////////////
/// Neuro Mine ///
//////////////////

/obj/structure/xeno/acid_mine/neuro_mine
	name = "neurotoxin mine"
	desc = "An oddly colored weed sac, filled with dense orange gas."
	icon_state = "neuro_mine"

/obj/structure/xeno/acid_mine/neuro_mine/detonate(triggerer)
	var/datum/effect_system/smoke_spread/xeno/neuro/medium/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()

	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, 5)
		to_chat(victim, span_userdanger("You are pricked by a spike on the mine!"))
	qdel(src)

//////////////////////
/// Lifetrade Mine ///
//////////////////////

/obj/structure/xeno/acid_mine/drain_mine
	name = "drain mine"
	desc = "A cyan blob that crackles with lifeblood."
	icon_state = "emp_mine"

/obj/structure/xeno/acid_mine/drain_mine/detonate(triggerer)
	if(ishuman(triggerer))
		var/mob/living/carbon/human/victim = triggerer
		victim.apply_status_effect(STATUS_EFFECT_LIFEDRAIN)
		new /obj/effect/temp_visual/telekinesis(get_turf(victim))
	var/datum/effect_system/smoke_spread/xeno/hemodile/gas = new(get_turf(src))
	gas.set_up(2, src)
	gas.start()
	qdel(src)
