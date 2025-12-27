// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line
	name = "Spray Acid"
	desc = "Spray a line of dangerous acid at your target."
	action_icon_state = "spray_acid_line"
	ability_cost = 250
	cooldown_duration = 30 SECONDS

/datum/action/ability/activable/xeno/spray_acid/line/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	xeno_owner.face_atom(target) //Face target so we don't look stupid

	if(xeno_owner.do_actions || !do_after(xeno_owner, 5, NONE, target, BUSY_ICON_DANGER))
		return

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/effects/refill.ogg', 50, 1)
	var/turflist = get_traversal_line(xeno_owner, target) //todo: use get_traversal_line and change spray_turfs to use get_dist_euclidean for range
	spray_turfs(turflist)
	add_cooldown()

	GLOB.round_statistics.spitter_acid_sprays++ //Statistics
	SSblackbox.record_feedback(FEEDBACK_TALLY, "round_statistics", 1, "spitter_acid_sprays")

/datum/action/ability/activable/xeno/spray_acid/line/proc/spray_turfs(list/turflist)
	set waitfor = FALSE

	if(isnull(turflist))
		return

	var/turf/prev_turf
	var/distance = 0

	for(var/X in turflist)
		var/turf/T = X

		if(!prev_turf && length(turflist) > 1)
			prev_turf = get_turf(owner)
			continue //So we don't burn the tile we be standin on

		for(var/obj/structure/barricade/B in prev_turf)
			if(get_dir(prev_turf, T) & B.dir)
				B.acid_spray_act(owner)

		if(T.density || isspaceturf(T))
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(owner))
				return // returned true if normal density applies
			if(O.density && !(O.allow_pass_flags & PASS_PROJECTILE) && !(O.atom_flags & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_turf.Adjacent(T) && (T.x != prev_turf.x || T.y != prev_turf.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_turf.x, T.y, prev_turf.z)
			var/turf/Tx = locate(T.x, prev_turf.y, prev_turf.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_turf.Adjacent(TB) && !TB.density && !isspaceturf(TB))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		for(var/obj/structure/barricade/B in TF)
			if(get_dir(TF, prev_turf) & B.dir)
				B.acid_spray_act(owner)

		acid_splat_turf(TF)

		distance++
		if(distance > 7 || blocked)
			break

		prev_turf = T
		sleep(0.2 SECONDS)

/datum/action/ability/activable/xeno/spray_acid/line/on_cooldown_finish() //Give acid spray a proper cooldown notification
	to_chat(owner, span_xenodanger("Our dermal pouches bloat with fresh acid; we can use acid spray again."))
	owner.playsound_local(owner, 'sound/voice/alien/drool2.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Scatterspit
// ***************************************
/datum/action/ability/activable/xeno/scatter_spit
	name = "Scatter Spit"
	desc = "Spits a spread of acid projectiles that splatter on the ground."
	action_icon_state = "scatter_spit"
	action_icon = 'icons/Xeno/actions/spitter.dmi'
	ability_cost = 280
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCATTER_SPIT,
	)

/datum/action/ability/activable/xeno/scatter_spit/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(xeno_owner.loc, 'sound/effects/blobattack.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/scatter/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter]

	var/atom/movable/projectile/newspit = new /atom/movable/projectile(get_turf(xeno_owner))
	newspit.generate_bullet(scatter_spit, scatter_spit.damage * SPIT_UPGRADE_BONUS(xeno_owner))
	newspit.def_zone = xeno_owner.get_limbzone_target()

	newspit.fire_at(target, xeno_owner, xeno_owner, newspit.ammo.max_range)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.spitter_scatter_spits++ //Statistics
	SSblackbox.record_feedback(FEEDBACK_TALLY, "round_statistics", 1, "spitter_scatter_spits")

/datum/action/ability/activable/xeno/scatter_spit/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our auxiliary sacks fill to bursting; we can use scatter spit again."))
	owner.playsound_local(owner, 'sound/voice/alien/drool1.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Sticky Grenade ************
// ***************************************
/datum/action/ability/activable/xeno/toxic_grenade/sticky
	name = "Slime grenade"
	desc = "Throws a lump of compressed acid to stick to a target, which will leave a trail of acid behind them."
	ability_cost = 75
	cooldown_duration = 45 SECONDS
	nade_type = /obj/item/explosive/grenade/sticky/xeno
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_GRENADE,
	)

/datum/action/ability/activable/xeno/toxic_grenade/sticky/grenade_act(atom/our_atom)
	var/obj/item/explosive/grenade/sticky/xeno/nade = new nade_type(get_turf(owner))
	nade.throw_at(our_atom, 5, 1, owner, TRUE)
	nade.activate(owner)
	owner.visible_message(span_warning("[owner] vomits up a sticky lump and throws it at [our_atom]!"), span_warning("We vomit up a sticky lump and throw it at [our_atom]!"))

/obj/item/explosive/grenade/sticky/xeno
	name = "\improper slime grenade"
	desc = "A fleshy mass oozing acid. It appears to be rapidly decomposing."
	greyscale_colors = "#42A500"
	greyscale_config = /datum/greyscale_config/xenogrenade
	self_sticky = TRUE
	arm_sound = 'sound/voice/alien/yell_alt.ogg'
	overlay_type = null
	var/acid_spray_damage = 15

/obj/item/explosive/grenade/sticky/xeno/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")

/obj/item/explosive/grenade/sticky/xeno/prime()
	for(var/turf/acid_tile AS in RANGE_TURFS(1, loc))
		new /obj/effect/temp_visual/acid_splatter(acid_tile) //SFX
		new /obj/effect/xenomorph/spray(acid_tile, 5 SECONDS, acid_spray_damage)
	playsound(loc, SFX_ACID_BOUNCE, 35)
	if(stuck_to)
		clean_refs()
	qdel(src)

/obj/item/explosive/grenade/sticky/xeno/stuck_to(atom/hit_atom)
	. = ..()
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(drop_acid))
	new /obj/effect/xenomorph/spray(get_turf(src), 5 SECONDS, acid_spray_damage)

///causes acid tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/xeno/proc/drop_acid(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	new /obj/effect/xenomorph/spray(get_turf(src), 5 SECONDS, acid_spray_damage)

/obj/item/explosive/grenade/sticky/xeno/clean_refs()
	UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()
