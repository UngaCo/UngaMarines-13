/*
	Cellular automaton explosions!

	Often in life, you can't have what you wish for. This is one massive, huge,
	gigantic, gaping exception. With this, you get EVERYTHING you wish for.

	This thing is AWESOME. It's made with super simple rules, and it still produces
	highly complex explosions because it's simply emergent behavior from the rules.
	If that didn't amaze you (it should), this also means the code is SUPER short,
	and because cellular automata is handled by a subsystem, this doesn't cause
	lagspikes at all.

	Enough nerd enthusiasm about this. Here's how it actually works:

		1. You start the explosion off with a given power

		2. The explosion begins to propagate outwards in all 8 directions

		3. Each time the explosion propagates, it loses power_falloff power

		4. Each time the explosion propagates, atoms in the tile the explosion is in
		may reduce the power of the explosion by their explosive resistance

	That's it. There are some special rules, though, namely:

		* If the explosion occured in a wall, the wave is strengthened
		with power *= reflection_multiplier and reflected back in the
		direction it came from

		* If two explosions meet, they will either merge into an amplified
		or weakened explosion
*/

/datum/automata_cell/explosion
	// Explosions only spread outwards and don't need to know their neighbors to propagate properly
	neighbor_type = NEIGHBORS_NONE
	/// Power of the explosion at this cell
	var/power = 0
	/// How much will the power drop off when the explosion propagates?
	var/power_falloff = 20
	/// Falloff shape is used to determines whether or not the falloff will change during the explosion traveling.
	var/falloff_shape = EXPLOSION_FALLOFF_SHAPE_LINEAR
	// How much power does the explosion gain (or lose) by bouncing off walls?
	var/reflection_power_multiplier = 0.4
	/// Diagonal cells have a small delay when branching off from a non-diagonal cell. This helps the explosion look circular
	var/delay = 0
	/// Which direction is the explosion traveling?
	/// Note that this will be null for the epicenter
	var/direction = null
	/// Whether or not the explosion should merge with other explosions
	var/should_merge = TRUE
	/// Workaround to account for the fact that this is subsystemized
	/// See on_turf_entered
	var/list/atom/exploded_atoms = list()
	/// The visual effect of our explosion
	var/obj/effect/particle_effect/shockwave/shockwave = null

// If we're on a fake z teleport, teleport over
/datum/automata_cell/explosion/birth()
	shockwave = new(in_turf)

/datum/automata_cell/explosion/death()
	exploded_atoms = null
	if(shockwave)
		QDEL_NULL(shockwave)

// Compare directions. If the other explosion is traveling in the same direction,
// the explosion is amplified. If not, it's weakened
/datum/automata_cell/explosion/merge(datum/automata_cell/explosion/our_explosion)
	// Non-merging explosions take priority
	if(!should_merge)
		return TRUE

	// The strongest of the two explosions should survive the merge
	// This prevents a weaker explosion merging with a strong one,
	// the strong one removing all the weaker one's power and just killing the explosion
	var/is_stronger = (power >= our_explosion.power)
	var/datum/automata_cell/explosion/survivor = is_stronger ? src : our_explosion
	var/datum/automata_cell/explosion/dying = is_stronger ? our_explosion : src

	// Two epicenters merging, or a new epicenter merging with a traveling wave
	//if((!survivor.direction && !dying.direction) || (survivor.direction && !dying.direction))
	if(!dying.direction && (!survivor.direction || survivor.direction))
		survivor.power += dying.power

	// A traveling wave hitting the epicenter weakens it
	if(!survivor.direction && dying.direction)
		survivor.power -= dying.power

	// Two traveling waves meeting each other
	// Note that we don't care about waves traveling perpendicularly to us
	// I.e. they do nothing

	// Two waves traveling the same direction amplifies the explosion
	if(survivor.direction == dying.direction)
		survivor.power += dying.power

	// Two waves travling towards each other weakens the explosion
	if(survivor.direction == REVERSE_DIR(dying.direction))
		survivor.power -= dying.power

	return is_stronger

/// Get a list of all directions the explosion should propagate to before dying
/datum/automata_cell/explosion/proc/get_propagation_dirs(reflected)
	// If the cell is the epicenter, propagate in all directions
	if(isnull(direction))
		return GLOB.alldirs

	var/list/propagation_dirs = list()
	var/our_dir = reflected ? REVERSE_DIR(direction) : direction

	if(our_dir in GLOB.diagonals)
		propagation_dirs += list(our_dir, turn(our_dir, 45), turn(our_dir, -45))
	else
		propagation_dirs += our_dir

	return propagation_dirs

/// If you need to set vars on the new cell other than the basic ones
/datum/automata_cell/explosion/proc/setup_new_cell(datum/automata_cell/explosion/our_explosion)
	if(!our_explosion.shockwave)
		return
	our_explosion.shockwave.alpha = our_explosion.power

/datum/automata_cell/explosion/update_state(list/turf/neighbors)
	if(delay > 0)
		delay--
		return
	// The resistance here will affect the damage taken and the falloff in the propagated explosion
	var/resistance = max(0, in_turf.get_explosion_resistance(direction))

	// Blow stuff up
	INVOKE_ASYNC(in_turf, TYPE_PROC_REF(/atom, ex_act), power, direction)
	for(var/atom/our_atom as anything in in_turf)
		if(our_atom in exploded_atoms)
			continue
		if(our_atom.gc_destroyed)
			continue
		resistance += max(0, our_atom.get_explosion_resistance())
		exploded_atoms += our_atom
		INVOKE_ASYNC(our_atom, TYPE_PROC_REF(/atom, ex_act), power, direction)

	var/reflected = FALSE

	// Epicenter is inside a wall if direction is null.
	// Prevent it from slurping the entire explosion
	if(!isnull(direction))
		// Bounce off the wall in the opposite direction, don't keep phasing through it
		// Notice that since we do this after the ex_act()s,
		// explosions will not bounce if they destroy a wall!
		if(power < resistance)
			reflected = TRUE
			power *= reflection_power_multiplier
		else
			power -= resistance

	if(power <= 0)
		qdel(src)
		return

	var/turf/old_turf = in_turf
	// Propagate the explosion
	var/list/to_spread = get_propagation_dirs(reflected)
	for(var/our_dir as anything in to_spread)
		// Diagonals are longer, that should be reflected in the power falloff
		var/dir_falloff = 1
		if(our_dir in GLOB.diagonals)
			dir_falloff = 1.414

		else if(isnull(direction))
			dir_falloff = 0

		var/new_power = power - (power_falloff * dir_falloff)

		// Explosion is too weak to continue
		if(new_power <= 0)
			continue

		var/new_falloff = power_falloff
		// Handle our falloff function.
		switch(falloff_shape)
			if(EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL)
				new_falloff += new_falloff * dir_falloff
			if(EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF)
				new_falloff += (new_falloff * 0.5) * dir_falloff

		if(our_dir == direction || our_dir == REVERSE_DIR(direction))
			var/turf/new_turf = get_step(in_turf, our_dir)
			transfer_turf(new_turf)
			shockwave.Move(new_turf, our_dir, 0)
			power = new_power
			setup_new_cell(src)
		else
			var/datum/automata_cell/explosion/our_explosion = propagate(our_dir, old_turf)
			if(our_explosion)
				our_explosion.power = new_power
				our_explosion.power_falloff = new_falloff
				our_explosion.falloff_shape = falloff_shape
				our_explosion.direction = our_dir
				if(!direction && (our_dir in GLOB.diagonals))
					our_explosion.delay = 1
				setup_new_cell(our_explosion)
	if(isnull(direction) || old_turf == in_turf)
		qdel(src)

/datum/automata_cell/explosion/propagate(dir, turf/start_turf)
	if(!dir)
		return

	var/turf/our_turf = get_step(start_turf, dir)
	if(QDELETED(our_turf))
		return

	return new /datum/automata_cell/explosion(our_turf)

/*
The issue is that between the cell being birthed and the cell processing,
someone could potentially move through the cell unharmed.

To prevent that, we track all atoms that enter the explosion cell's turf
and blow them up immediately once they do.

When the cell processes, we simply don't blow up atoms that were tracked
as having entered the turf.
*/
/datum/automata_cell/explosion/proc/on_turf_entered(atom/movable/our_atom)
	if(our_atom in exploded_atoms)// Once is enough
		return

	exploded_atoms += our_atom

	// Note that we don't want to make it a directed ex_act because
	// it could toss them back and make them get hit by the explosion again
	if(our_atom.gc_destroyed)
		return

	INVOKE_ASYNC(our_atom, TYPE_PROC_REF(/atom, ex_act), power, null)

/// Spawns a cellular automaton of an explosion
/proc/cell_explosion(turf/epicenter, power, falloff, falloff_shape = EXPLOSION_FALLOFF_SHAPE_LINEAR, orig_range, direction, color, silent, adminlog = TRUE)
	if(!istype(epicenter))
		epicenter = get_turf(epicenter)

	if(!epicenter)
		return

	if(power > EXPLOSION_MAX_POWER)
		stack_trace("Something exploded with force of [power]. Overriding to capacity of [EXPLOSION_MAX_POWER].")
		power = EXPLOSION_MAX_POWER

	falloff = max(falloff, power * 0.01)
	if(adminlog)
		log_game("Explosion with power of [power] and falloff of [falloff] at [AREACOORD(epicenter)]!")
		if(is_mainship_level(epicenter.z))
			message_admins("Explosion with power of [power] and falloff of [falloff] in [ADMIN_VERBOSEJMP(epicenter)]!")

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	var/far_dist = power * 0.1
	if(!silent)
		var/frequency = GET_RAND_FREQUENCY
		var/sound/explosion_sound
		var/sound/far_explosion_sound

		//no need to loop this for every mob
		if(power > EXPLODE_HEAVY)
			explosion_sound = SFX_EXPLOSION_LARGE
			far_explosion_sound = SFX_EXPLOSION_LARGE_DISTANT
		else if(power > EXPLODE_LIGHT)
			explosion_sound = SFX_EXPLOSION_MED
			far_explosion_sound = SFX_EXPLOSION_LARGE_DISTANT
		else
			explosion_sound = SFX_EXPLOSION_SMALL
			far_explosion_sound = SFX_EXPLOSION_SMALL_DISTANT

		//there should be a use of client_by_zlevel, but due to the nature of explosions this is difficult to implement
		for(var/mob/our_mob as anything in GLOB.player_list|GLOB.aiEyes)
			// Double check for client
			var/turf/mob_turf = get_turf(our_mob)
			if(mob_turf?.z != epicenter.z)
				continue
			var/dist = get_dist(mob_turf, epicenter)
			if(dist <= max(round(power, 1)))
				our_mob.playsound_local(epicenter, explosion_sound, 75, 1, frequency, falloff = 5)
				if(is_mainship_level(epicenter.z))
					our_mob.playsound_local(epicenter, SFX_EXPLOSION_CREAK, 40, 1, frequency, falloff = 5)//ship groaning under explosion effect
			// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
			else if(dist <= far_dist)
				var/far_volume = clamp(far_dist, 30, 60) // Volume is based on explosion size and dist
				far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
				our_mob.playsound_local(epicenter, far_explosion_sound, far_volume, 1, frequency, falloff = 5)
				if(is_mainship_level(epicenter.z))
					our_mob.playsound_local(epicenter, SFX_EXPLOSION_CREAK, far_volume * 3, 1, frequency, falloff = 5)//ship groaning under explosion effect
	if(!orig_range)
		orig_range = round(power / falloff)
	new /obj/effect/temp_visual/explosion(epicenter, orig_range, color, power)
	var/datum/automata_cell/explosion/our_explosion = new /datum/automata_cell/explosion(epicenter)
	our_explosion.power = power
	our_explosion.power_falloff = falloff
	our_explosion.falloff_shape = falloff_shape
	our_explosion.direction = direction

/obj/effect/particle_effect/shockwave
	name = "shockwave"
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = FLY_LAYER
	animate_movement = NO_STEPS

/atom/proc/get_explosion_resistance()
	return 0

/mob/living/get_explosion_resistance()
	if(!density)
		return 0
	switch(mob_size)
		if(MOB_SIZE_SMALL)
			return 0
		if(MOB_SIZE_HUMAN)
			return 25
		if(MOB_SIZE_XENO)
			return 30
		if(MOB_SIZE_BIG)
			return 50
		else
			return 0

/atom/movable/proc/explosion_throw(severity, direction)
	if(QDELETED(src))
		return
	if(anchored || !isturf(loc))
		return

	if(!direction)
		direction = pick(GLOB.alldirs)
	var/range = min(round(severity * 0.07, 1), 14)
	if(!direction)
		range = round(range * 0.5, 1)

	if(range < 1)
		return

	var/speed = max(range, 3)
	var/atom/target = get_ranged_target_turf(src, direction, range)

	if(range >= 2)
		var/scatter = range * 0.25
		var/scatter_x = rand(-scatter, scatter)
		var/scatter_y = rand(-scatter, scatter)
		target = locate(target.x + round(scatter_x, 1), target.y + round(scatter_y, 1), target.z) //Locate an adjacent turf.

	//time for the explosion to destroy windows, walls, etc which might be in the way
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, throw_at), target, range, speed, null, TRUE, targetted_throw = FALSE)

/mob/explosion_throw(severity, direction)
	if(severity <= 0)
		return
	if(anchored || !isturf(loc))
		return

	var/weight = 1
	switch(mob_size)
		if(MOB_SIZE_SMALL)
			weight = 4
		if(MOB_SIZE_HUMAN)
			weight = 1
		if(MOB_SIZE_XENO)
			weight = 0.66
		if(MOB_SIZE_BIG)
			weight = 0.25
	var/range = round(severity * weight * 0.02, 1)
	if(!direction)
		range = round(range * 0.66, 1)
		direction = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

	if(range <= 0)
		return

	var/speed = max(range * 1.5, 4)
	var/atom/target = get_ranged_target_turf(src, direction, range)
	var/spin = FALSE

	if(range > 1)
		spin = TRUE
	if(range >= 2)
		var/scatter = range * 0.25
		var/scatter_x = rand(-scatter, scatter)
		var/scatter_y = rand(-scatter, scatter)
		target = locate(target.x + round(scatter_x, 1),target.y + round(scatter_y, 1), target.z) //Locate an adjacent turf.

	//time for the explosion to destroy windows, walls, etc which might be in the way
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, throw_at), target, range, speed, null, spin, targetted_throw = FALSE)
