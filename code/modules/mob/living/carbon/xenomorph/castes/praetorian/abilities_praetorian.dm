/datum/action/ability/activable/xeno/scatter_spit/praetorian
	cooldown_duration = 1 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCATTER_SPIT,
	)

/datum/action/ability/activable/xeno/scatter_spit/praetorian/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(xeno_owner.loc, 'sound/effects/blobattack.ogg', 50, 1)

	var/datum/ammo/xeno/acid/heavy/scatter/praetorian/scatter_spit = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/scatter/praetorian]

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
// *********** Acid spray
// ***************************************

/datum/action/ability/activable/xeno/spray_acid/cone
	name = "Spray Acid Cone"
	desc = "Spray a cone of dangerous acid at your target."
	ability_cost = 300
	cooldown_duration = 20 SECONDS

/datum/action/ability/activable/xeno/spray_acid/cone/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(!do_after(xeno_owner, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	GLOB.round_statistics.praetorian_acid_sprays++
	SSblackbox.record_feedback(FEEDBACK_TALLY, "round_statistics", 1, "praetorian_acid_sprays")

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/effects/refill.ogg', 25, 1)
	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] spews forth a wide cone of acid!"), \
	span_xenowarning("We spew forth a cone of acid!"), null, 5)

	start_acid_spray_cone(target, xeno_owner.xeno_caste.acid_spray_range)
	add_cooldown()

	var/datum/action/ability/activable/xeno/spray = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/line/short]
	if(spray)
		spray.add_cooldown(10 SECONDS)

/datum/action/ability/activable/xeno/spray_acid/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/spray_acid/ai_should_use(atom/target)
	if(owner.do_actions) //Chances are we're already spraying acid, don't override it
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 3))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

GLOBAL_LIST_INIT(acid_spray_hit, typecacheof(list(/obj/structure/barricade, /obj/hitbox, /obj/structure/razorwire)))

#define CONE_PART_MIDDLE (1<<0)
#define CONE_PART_LEFT (1<<1)
#define CONE_PART_RIGHT (1<<2)
#define CONE_PART_DIAG_LEFT (1<<3)
#define CONE_PART_DIAG_RIGHT (1<<4)
#define CONE_PART_MIDDLE_DIAG (1<<5)

///Start the acid cone spray in the correct direction
/datum/action/ability/activable/xeno/spray_acid/cone/proc/start_acid_spray_cone(turf/T, range)
	var/facing = angle_to_dir(Get_Angle(owner, T))
	owner.setDir(facing)
	switch(facing)
		if(NORTH, SOUTH, EAST, WEST)
			do_acid_cone_spray(get_step(owner.loc, facing), range, facing, CONE_PART_MIDDLE|CONE_PART_LEFT|CONE_PART_RIGHT, owner, TRUE)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			do_acid_cone_spray(get_step(owner.loc, facing), owner.loc, range, facing, CONE_PART_MIDDLE_DIAG, owner, TRUE)
			do_acid_cone_spray(get_step(owner.loc, facing), range + 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, owner, TRUE)

///Check if it's possible to create a spray, and if yes, check if the spray must continue
/datum/action/ability/activable/xeno/spray_acid/cone/proc/do_acid_cone_spray(turf/T, distance_left, facing, direction_flag, source_spray, skip_timer = FALSE)
	if(distance_left <= 0)
		return
	if(T.density)
		return
	var/is_blocked = FALSE
	for(var/obj/O in T)
		if(!O.CanPass(source_spray, get_turf(source_spray)))
			is_blocked = TRUE
			O.acid_spray_act(owner)
			break
	if(is_blocked)
		return

	var/obj/effect/xenomorph/spray/spray = new(T, xeno_owner.xeno_caste.acid_spray_duration, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner)
	var/turf/next_normal_turf = get_step(T, facing)
	for(var/atom/movable/A AS in T)
		A.acid_spray_act(owner)
		if(((A.density && !(A.allow_pass_flags & PASS_PROJECTILE) && !(A.atom_flags & ON_BORDER)) || !A.Exit(source_spray, facing)) && !isxeno(A))
			is_blocked = TRUE
	if(!is_blocked)
		if(!skip_timer)
			addtimer(CALLBACK(src, PROC_REF(continue_acid_cone_spray), T, next_normal_turf, distance_left, facing, direction_flag, spray), 3)
			return
		continue_acid_cone_spray(T, next_normal_turf, distance_left, facing, direction_flag, spray)

///Call the next steps of the cone spray,
/datum/action/ability/activable/xeno/spray_acid/cone/proc/continue_acid_cone_spray(turf/current_turf, turf/next_normal_turf, distance_left, facing, direction_flag, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE))
		do_acid_cone_spray(next_normal_turf, distance_left - 1 , facing, CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_RIGHT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, 90)), distance_left - 1, facing, CONE_PART_RIGHT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_LEFT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, -90)), distance_left - 1, facing, CONE_PART_LEFT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_LEFT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, 45)), distance_left - 1, turn(facing, 45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_RIGHT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, -45)), distance_left - 1, turn(facing, -45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE_DIAG))
		do_acid_cone_spray(next_normal_turf, distance_left - 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, spray)
		do_acid_cone_spray(next_normal_turf, distance_left - 2, facing, (distance_left < 5) ? CONE_PART_MIDDLE : CONE_PART_MIDDLE_DIAG, spray)

// ***************************************
// *********** Dash
// ***************************************
/datum/action/ability/activable/xeno/charge/dash
	name = "Dash"
	desc = "Instantly dash to the selected tile."
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	ability_cost = 100
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DASH,
	)
	charge_range = PRAE_CHARGEDISTANCE
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	///The last tile we dashed through, used when swapping with a human
	var/turf/last_turf

/datum/action/ability/activable/xeno/charge/dash/use_ability(atom/A)
	if(!A)
		return
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))

	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown

	add_cooldown()
	succeed_activate()

	last_turf = get_turf(owner)
	owner.pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	owner.throw_at(A, charge_range, 2, owner)

	add_cooldown()
	succeed_activate()

/datum/action/ability/activable/xeno/charge/dash/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target))) //we leap past xenos
		return
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.ParalyzeNoChain(0.1 SECONDS)

/datum/action/ability/activable/xeno/charge/dash/charge_complete()
	. = ..()
	xeno_owner.pass_flags = initial(xeno_owner.pass_flags)

// ***************************************
// *********** Short acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/line/short
	name = "Spray Acid"
	desc = "Spray a short line of dangerous acid at your target."
	ability_cost = 100
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SHORT_SPRAY_ACID,
	)

/datum/action/ability/activable/xeno/spray_acid/line/short/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	xeno_owner.face_atom(target) //Face target so we don't look stupid

	if(xeno_owner.do_actions)
		return

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/effects/refill.ogg', 50, 1)
	var/turflist = get_traversal_line(xeno_owner, target)
	spray_turfs(turflist)
	add_cooldown()

	GLOB.round_statistics.spitter_acid_sprays++ //Statistics
	SSblackbox.record_feedback(FEEDBACK_TALLY, "round_statistics", 1, "spitter_acid_sprays")

	var/datum/action/ability/activable/xeno/spray = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/spray_acid/cone]
	if(spray)
		spray.add_cooldown(10 SECONDS)

/datum/action/ability/activable/xeno/spray_acid/line/short/spray_turfs(list/turflist)
	set waitfor = FALSE

	if(isnull(turflist))
		return

	var/turf/prev_turf
	var/distance = 0

	for(var/xeno_owner in turflist)
		var/turf/T = xeno_owner

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
		if(distance > 3 || blocked)
			break

		prev_turf = T
		sleep(0.2 SECONDS)

/datum/action/ability/activable/xeno/spray_acid/line/short/acid_splat_turf(turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		. = new /obj/effect/xenomorph/spray(T, 3 SECONDS, xeno_owner.xeno_caste.acid_spray_damage, owner)

		for(var/i in T)
			var/atom/A = i
			if(!A)
				continue
			A.acid_spray_act(owner)

// ***************************************
// *********** Acid dash
// ***************************************
/datum/action/ability/activable/xeno/charge/acid_dash
	name = "Acid Dash"
	desc = "Instantly dash, tackling the first marine in your path. If you manage to tackle someone, gain another weaker cast of the ability."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH,
	)
	charge_range = PRAE_CHARGEDISTANCE
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	///The last tile we dashed through, used when swapping with a human
	var/turf/last_turf
	///List of pass_flags given by this action
	var/charge_pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE

/datum/action/ability/activable/xeno/charge/acid_dash/use_ability(atom/A)
	if(!A)
		return
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(acid_steps)) //We drop acid on every tile we pass through

	xeno_owner.visible_message(span_danger("[xeno_owner] slides towards \the [A]!"), \
	span_danger("We dash towards \the [A], spraying acid down our path!") )
	xeno_owner.emote("roar")
	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	last_turf = get_turf(owner)
	xeno_owner.add_pass_flags(charge_pass_flags, type)
	owner.throw_at(A, charge_range, 2, owner)

/datum/action/ability/activable/xeno/charge/acid_dash/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target))) //we leap past xenos
		return
	recast_available = TRUE
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.ParalyzeNoChain(0.5 SECONDS)

	to_chat(carbon_victim, span_userdanger("The [owner] tackles us, sending us behind them!"))
	owner.visible_message(span_xenodanger("\The [owner] tackles [carbon_victim], swapping location with them!"), \
		span_xenodanger("We push [carbon_victim] in our acid trail!"), visible_message_flags = COMBAT_MESSAGE)

/datum/action/ability/activable/xeno/charge/acid_dash/charge_complete()
	. = ..()
	if(recast_available)
		addtimer(CALLBACK(src, PROC_REF(charge_complete)), 2 SECONDS) //Delayed recursive call, this time you won't gain a recast so it will go on cooldown in 2 SECONDS.
		recast = TRUE
	else
		recast = FALSE
		add_cooldown()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	xeno_owner.remove_pass_flags(charge_pass_flags, type)
	recast_available = FALSE

///Drops an acid puddle on the current owner's tile, will do 0 damage if the owner has no acid_spray_damage
/datum/action/ability/activable/xeno/charge/acid_dash/proc/acid_steps(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	last_turf = OldLoc
	new /obj/effect/xenomorph/spray(get_turf(xeno_owner), 5 SECONDS, xeno_owner.xeno_caste.acid_spray_damage) //Add a modifier here to buff the damage if needed
	for(var/obj/O in get_turf(xeno_owner))
		O.acid_spray_act(xeno_owner)

// ***************************************
// *********** Dodge
// ***************************************
/datum/action/ability/xeno_action/dodge
	name = "Dodge"
	desc = "Flood your body with adrenaline, gaining a speed boost upon activation and the ability to pass through mobs. Enemies automatically receive bump attacks when passed."
	action_icon_state = "dodge"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	ability_cost = 100
	cooldown_duration = 18 SECONDS
	use_state_flags = ABILITY_USE_BUSY
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DODGE,
	)
	/// The increase of speed when ability is active.
	var/speed_buff = -0.3
	/// How long the ability will last?
	var/duration = 8 SECONDS
	///List of pass_flags given by this action
	var/dodge_pass_flags = PASS_MOB|PASS_XENO
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/xeno_action/dodge/action_activate(atom/A)
	owner.balloon_alert(owner, "Dodge ready!")
	toggle_particles(TRUE)

	owner.add_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED, TRUE, 0, NONE, TRUE, speed_buff)
	owner.allow_pass_flags |= (PASS_MOB|PASS_XENO)
	xeno_owner.add_pass_flags(dodge_pass_flags, type)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	addtimer(CALLBACK(src, PROC_REF(remove_effects)), duration)

	succeed_activate()
	add_cooldown()

/// Automatically bumps living non-xenos if bump attacks are on.
/datum/action/ability/xeno_action/dodge/proc/on_move(datum/source)
	if(owner.stat == DEAD)
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK) || owner.next_move > world.time)
		return FALSE

	var/turf/current_turf = get_turf(owner)
	for(var/mob/living/living_mob in current_turf)
		if(living_mob.stat == DEAD)
			continue
		if(isxeno(living_mob))
			var/mob/living/carbon/xenomorph/xenomorph_mob = living_mob
			if(owner.issamexenohive(xenomorph_mob))
				continue
		owner.Bump(living_mob)
		return

/// Removes the movespeed modifier and various pass_flags that was given by the dodge ability.
/datum/action/ability/xeno_action/dodge/proc/remove_effects()
	owner.balloon_alert(owner, "Dodge inactive!")
	toggle_particles(FALSE)

	owner.remove_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED)
	owner.allow_pass_flags &= ~(PASS_MOB|PASS_XENO)
	xeno_owner.remove_pass_flags(dodge_pass_flags, type)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/// Toggles particles on or off, adjusting their positioning to fit the buff's owner.
/datum/action/ability/xeno_action/dodge/proc/toggle_particles(toggle)
	var/particle_x = abs(xeno_owner.pixel_x)
	if(!toggle)
		QDEL_NULL(particle_holder)
		return
	particle_holder = new(xeno_owner, /particles/baton_pass)
	particle_holder.pixel_x = particle_x
	particle_holder.pixel_y = -3

// ***************************************
// *********** Impale
// ***************************************
/datum/action/ability/activable/xeno/impale
	name = "Impale"
	desc = "Skewer an object next to you with your tail. The more debuffs on a living target, the greater the damage done. Penetrates the armor of marked targets."
	action_icon_state = "impale"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	ability_cost = 150
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_IMPALE,
	)

/datum/action/ability/activable/xeno/impale/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(A) && !ishitbox(A) && !isvehicle(A) && !ismachinery(A))
		if(!silent)
			A.balloon_alert(owner, "cannot impale")
		return FALSE
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xenomorph_target = A
		if(owner.issamexenohive(xenomorph_target))
			A.balloon_alert(owner, "cannot impale ally")
			return FALSE
	if(!A.Adjacent(owner))
		A.balloon_alert(owner, "too far")
		return FALSE

	if(isliving(A))
		var/mob/living/living_target = A
		if(living_target.stat == DEAD)
			living_target.balloon_alert(owner, "already dead")
			return FALSE

/datum/action/ability/activable/xeno/impale/use_ability(atom/target_atom)
	. = ..()

	xeno_owner.face_atom(target_atom)
	xeno_owner.do_attack_animation(target_atom, ATTACK_EFFECT_REDSTAB)
	playsound(xeno_owner, get_sfx(SFX_ALIEN_TAIL_ATTACK), 30, TRUE)
	xeno_owner.visible_message(span_danger("\The [xeno_owner] violently spears \the [target_atom] with their tail!"))
	if(!ishuman(target_atom))
		target_atom.attack_alien(xeno_owner, xeno_owner.xeno_caste.melee_damage * DANCER_NONHUMAN_IMPALE_MULT)
	else
		var/mob/living/carbon/human/human_victim = target_atom
		var/marked = human_victim.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		var/buff_multiplier = min(DANCER_MAX_IMPALE_MULT, determine_buff_mult(human_victim))
		var/adj_damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * buff_multiplier)
		human_victim.apply_damage(adj_damage, BRUTE, blocked = MELEE, penetration = (marked ? DANCER_IMPALE_PENETRATION : 0))
		human_victim.Shake(duration = 0.5 SECONDS)
		//you got shishkebabbed really bad
		if(buff_multiplier > 1.70)
			xeno_owner.emote("roar")
			human_victim.knockback(xeno_owner, 1, 1)
			human_victim.emote("scream")
	succeed_activate()
	add_cooldown()

/// Determines the total damage multiplier of impale based on the presence of several debuffs.
/datum/action/ability/activable/xeno/impale/proc/determine_buff_mult(mob/living/carbon/human/living_target)
	var/adjusted_mult = 1.20
	//tier 1 debuffs
	if(living_target.has_status_effect(STATUS_EFFECT_STAGGER))
		adjusted_mult += 0.25
	if(living_target.IsSlowed())
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_CONFUSED))
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_IMMOBILIZED))
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_SHATTER))
		adjusted_mult += 0.25
	if(living_target.has_status_effect(STATUS_EFFECT_MELTING))
		adjusted_mult += 0.25
	//big bonus if target has a "helpless" debuff
	if(living_target.has_status_effect(STATUS_EFFECT_PARALYZED) || living_target.has_status_effect(STATUS_EFFECT_STUN) || living_target.has_status_effect(STATUS_EFFECT_KNOCKDOWN))
		adjusted_mult += 0.5
	return adjusted_mult

// ***************************************
// *********** Tail Trip
// ***************************************
/datum/action/ability/activable/xeno/tail_trip
	name = "Tail Trip"
	desc = "Twirl your tail around low to the ground, knocking over and disorienting any adjacent marines. Marked enemies receive stronger debuffs and are briefly stunned."
	action_icon_state = "tail_trip"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	ability_cost = 75
	cooldown_duration = 8 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_TRIP,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/tail_trip/use_ability(atom/target_atom)
	. = ..()

	xeno_owner.add_filter("dancer_tail_trip", 2, gauss_blur_filter(1)) //Add cool SFX
	var/obj/effect/temp_visual/tail_swing/swing = new
	xeno_owner.vis_contents += swing

	xeno_owner.spin(0.6 SECONDS, 1)
	xeno_owner.emote("tail")
	xeno_owner.enable_throw_parry(0.6 SECONDS)
	xeno_owner.visible_message(span_danger("\The [xeno_owner] sweeps its tail in a low circle!"))

	var/damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier

	var/list/inrange = orange(1, xeno_owner)

	for (var/mob/living/carbon/human/living_target in inrange)
		if(living_target.stat == DEAD)
			continue
		to_chat(living_target, span_xenowarning("Our legs are struck by \the [xeno_owner]'s tail!"))
		var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		if(buffed)
			living_target.ParalyzeNoChain(1.5 SECONDS)
			shake_camera(living_target, 2, 1)
		living_target.AdjustKnockdown(buffed ? 1 SECONDS : 0.5 SECONDS)
		living_target.adjust_stagger(buffed ? 3 SECONDS : 1.5 SECONDS)
		living_target.apply_damage(damage, STAMINA, updating_health = TRUE)
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/datum, remove_filter), "dancer_tail_trip"), 0.6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(remove_swing), swing), 3 SECONDS)
	succeed_activate()
	add_cooldown()

///Garbage collects the swing attack vis_overlay created during use_ability
/datum/action/ability/activable/xeno/tail_trip/proc/remove_swing(swing_visual)
	xeno_owner.vis_contents -= swing_visual
	QDEL_NULL(swing_visual)

/obj/effect/temp_visual/tail_swing
	icon = 'icons/effects/96x96.dmi'
	icon_state = "tail_swing"
	pixel_x = -18
	pixel_y = -32
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART

// ***************************************
// *********** Tail Hook
// ***************************************
/datum/action/ability/activable/xeno/tail_hook
	name = "Tail Hook"
	action_icon_state = "tail_hook"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Swing your tail high, sending the hooked edge gouging into any targets within 2 tiles. Hooked marines have their movement slowed and are dragged, spinning, towards you. Marked marines are slowed for longer and briefly knocked over."
	cooldown_duration = 12 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAILHOOK,
	)

/datum/action/ability/activable/xeno/tail_hook/use_ability(atom/target_atom)
	. = ..()

	var/obj/effect/temp_visual/tail_hook/hook = new
	xeno_owner.vis_contents += hook
	xeno_owner.spin(0.8 SECONDS, 1)
	xeno_owner.enable_throw_parry(0.6 SECONDS)
	xeno_owner.emote("tail")
	xeno_owner.visible_message(span_danger("\The [xeno_owner] swings the hook on its tail through the air!"))

	var/damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * 0.5
	var/list/inrange = orange(2, xeno_owner)

	for(var/mob/living/carbon/human/living_target in inrange)
		var/start_turf = get_step(xeno_owner, get_cardinal_dir(xeno_owner, living_target))
		//no hooking through solid obstacles
		if(check_path(xeno_owner, start_turf, PASS_THROW) != start_turf)
			continue
		if(living_target.stat == DEAD)
			continue
		to_chat(living_target, span_xenowarning("\The [xeno_owner] hooks into our flesh and yanks us towards them!"))
		var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		living_target.apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE)
		living_target.Shake(duration = 0.1 SECONDS)
		living_target.spin(2 SECONDS, 1)

		living_target.throw_at(xeno_owner, 1, 3, xeno_owner)
		living_target.adjust_slowdown(buffed ? 0.9 : 0.3)
		if(buffed)
			living_target.AdjustKnockdown(0.1 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(remove_swing), hook), 3 SECONDS) //Remove cool SFX
	succeed_activate()
	add_cooldown()

///Garbage collects the swing attack vis_overlay created during use_ability
/datum/action/ability/activable/xeno/tail_hook/proc/remove_swing(swing_visual)
	xeno_owner.vis_contents -= swing_visual
	QDEL_NULL(swing_visual)

/obj/effect/temp_visual/tail_hook
	icon = 'icons/effects/128x128.dmi'
	icon_state = "tail_hook"
	pixel_x = -32
	pixel_y = -46
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART

// ***************************************
// *********** Baton Pass
// ***************************************
/datum/action/ability/activable/xeno/baton_pass
	name = "Baton Pass"
	action_icon_state = "baton_pass"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Dose adjacent xenomorphs with your adrenaline, increasing their movement speed for 6 seconds. Less effect on quick xenos."
	cooldown_duration = 35 SECONDS
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BATONPASS,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY

/datum/action/ability/activable/xeno/baton_pass/use_ability(atom/target)

	var/obj/effect/temp_visual/baton_pass/baton = new
	xeno_owner.vis_contents += baton
	xeno_owner.spin(0.8 SECONDS, 1)

	playsound(xeno_owner, SFX_ALIEN_TAIL_SWIPE, 25, 1)
	xeno_owner.visible_message(span_danger("\The [xeno_owner] empowers nearby xenos with increased speed!"))

	for(var/mob/living/carbon/xenomorph/xeno_target in orange(1, xeno_owner))
		if(xeno_target.stat == DEAD)
			continue
		if(xeno_target.hivenumber != xeno_owner.hivenumber)
			continue
		xeno_target.apply_status_effect(STATUS_EFFECT_XENO_BATONPASS)

	succeed_activate()
	add_cooldown()

///Garbage collects the baton vis_overlay created during use_ability
/datum/action/ability/activable/xeno/baton_pass/proc/remove_baton(baton_visual)
	xeno_owner.vis_contents -= baton_visual
	QDEL_NULL(baton_visual)

/obj/effect/temp_visual/baton_pass
	icon = 'icons/effects/96x96.dmi'
	icon_state = "baton_pass"
	pixel_x = -18
	pixel_y = -14
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
