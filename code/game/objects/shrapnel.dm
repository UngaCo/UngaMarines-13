/**
 * Fires a number of projectiles in a circle around an atom
 * Arguments:
 * * epicenter: [mandatory] turf the bullets are coming from
 * * shrapnel_number: [mandatory] number of shrapnel to fire
 * * shrapnel_direction: which way the shrapnel should initially go, goes everywhere by default
 * * shrapnel_spread: general spread of shrapnels with direction, used only if shrapnel_direction is defined
 * * shrapnel_type: the type of shrapnel that we fire
 * * on_hit_coefficient: how high is the chance of hitting mob in the epicenter
 */
/proc/create_shrapnel(turf/epicenter, shrapnel_number = 10, shrapnel_direction, shrapnel_spread = 45, datum/ammo/shrapnel_type = /datum/ammo/bullet/shrapnel, on_hit_coefficient = 15)
	var/initial_angle = 0
	var/angle_increment = 0

	if(shrapnel_direction)
		initial_angle = dir2angle(shrapnel_direction) - shrapnel_spread
		angle_increment = (shrapnel_spread * 2) / shrapnel_number
	else
		angle_increment = 360 / shrapnel_number
	var/angle_randomization = angle_increment * 0.5

	var/mob/living/carbon/epicenter_mob
	for(var/mob/living/carbon/central_mob in epicenter)
		if(!central_mob.lying_angle) // look for standing mobs first
			epicenter_mob = central_mob
			break
		else
			epicenter_mob = central_mob
			break

	for(var/i = 0; i < shrapnel_number; i++) // this is done in such way so angle increases with each shrapnel fired
		var/atom/movable/projectile/our_shrapnel = new(epicenter)
		our_shrapnel.generate_bullet(new shrapnel_type)

		if(epicenter_mob && prob(on_hit_coefficient))
			our_shrapnel.fire_at(epicenter_mob, null, epicenter, our_shrapnel.ammo.max_range, our_shrapnel.ammo.shell_speed, loc_override = epicenter)
		else
			var/angle = initial_angle + i * angle_increment + rand(-angle_randomization, angle_randomization)
			var/atom/target = get_angle_target_turf(epicenter, angle, our_shrapnel.ammo.max_range)
			our_shrapnel.fire_at(target, null, epicenter, our_shrapnel.ammo.max_range, our_shrapnel.ammo.shell_speed, angle, loc_override = epicenter)
