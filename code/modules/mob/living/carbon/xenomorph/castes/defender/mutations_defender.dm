#define STATUS_EFFECT_BRITTLE_UPCLOSE /datum/status_effect/defender/brittle_upclose
#define STATUS_EFFECT_BREATHTAKING_SPIN /datum/status_effect/defender/breathtaking_spin
#define STATUS_EFFECT_POWER_SPIN /datum/status_effect/defender/power_spin
#define STATUS_EFFECT_SHARPENING_CLAWS /datum/status_effect/defender/sharpening_claws


/datum/xeno_mutation/defender
	category = "Enhancement"
	caste_restrictions = list("defender")

/datum/status_effect/defender
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	/// The xenomorph that owns this status effect.
	var/mob/living/carbon/xenomorph/xenomorph_owner


/datum/xeno_mutation/defender/brittle_upclose
	name = "Brittle Upclose"
	desc = "Стаггер игнорируется и резист к пулям увеличен ценой сильной уязвимости к ближним атакам."
	cost = 7.5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_BRITTLE_UPCLOSE
	buff_desc = "No stagger; +10 bullet soft armor; -40 melee soft armor"

/atom/movable/screen/alert/status_effect/defender/brittle_upclose
	name = "Brittle Upclose"
	desc = "No stagger; +10 bullet soft armor; -40 melee soft armor"
	icon_state = "xenobuff_attack"

/datum/status_effect/defender/brittle_upclose
	id = "upgrade_brittle_upclose"
	alert_type = /atom/movable/screen/alert/status_effect/defender/brittle_upclose

	/// The amount of bullet armor to increase by.
	var/bullet_armor_increase_initial = 10
	/// The amount of melee armor to increase by.
	var/melee_armor_reduction_initial = -40

/datum/status_effect/defender/brittle_upclose/on_apply()
	xenomorph_owner = owner
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(get_melee_armor(), get_bullet_armor())
	RegisterSignal(xenomorph_owner, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(pre_projectile_hit))
	ADD_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)
	return TRUE

/datum/status_effect/defender/brittle_upclose/on_remove()
	xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.modifyRating(get_melee_armor(), get_bullet_armor())
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_PROJECTILE_HIT))
	REMOVE_TRAIT(xenomorph_owner, TRAIT_STAGGER_RESISTANT, MUTATION_TRAIT)
	return ..()

/// When hit by a non-friendly projectile at pointblank range, have the projectile deal additional damage.
/datum/status_effect/defender/brittle_upclose/proc/pre_projectile_hit(datum/source, atom/movable/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER
	if(xenomorph_owner.issamexenohive(proj.firer))
		return
	if(proj.distance_travelled >= 2)
		return
	proj.damage *= (1 + (get_bullet_armor() / 100)) // Effectively negates the bonus bullet armor.

/// Returns the amount of bullet armor that should be given.
/datum/status_effect/defender/brittle_upclose/proc/get_bullet_armor(include_initial = TRUE)
	return (include_initial ? bullet_armor_increase_initial : 0)

/// Returns the amount of melee armor that should be given.
/datum/status_effect/defender/brittle_upclose/proc/get_melee_armor(include_initial = TRUE)
	return (include_initial ? melee_armor_reduction_initial : 0)

//
//
//

/datum/xeno_mutation/defender/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe теперь наносит только урон стамине и не парализует, но наносит в 2 раза больше урона."
	cost = 5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_BREATHTAKING_SPIN
	buff_desc = "Tail Swipe doubles damage, but deals stamina damage only and doesnt paralyze."

/atom/movable/screen/alert/status_effect/defender/breathtaking_spin
	name = "Breathtaking Spin"
	desc = "Tail Swipe doubles damage, but deals stamina damage only and doesnt paralyze."
	icon_state = "xenobuff_attack"

/datum/status_effect/defender/breathtaking_spin
	id = "upgrade_breathtaking_spin"
	alert_type = /atom/movable/screen/alert/status_effect/defender/breathtaking_spin

	/// The amount to increase Tail Swipe's damage multiplier by.
	var/damage_multiplier_initial = 2

/datum/status_effect/defender/breathtaking_spin/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.damage_multiplier += get_damage_multiplier(0)
	tail_sweep.damage_type = STAMINA
	tail_sweep.paralyze_duration -= initial(tail_sweep.paralyze_duration)
	return TRUE

/datum/status_effect/defender/breathtaking_spin/on_remove()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.damage_multiplier -= get_damage_multiplier(0)
	tail_sweep.damage_type = initial(tail_sweep.damage_type)
	tail_sweep.paralyze_duration += initial(tail_sweep.paralyze_duration)
	return ..()

/// Returns the amount to increase Tail Swipe's damage multiplier by.
/datum/status_effect/defender/breathtaking_spin/proc/get_damage_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? damage_multiplier_initial : 0)

//
//
//

/datum/xeno_mutation/defender/power_spin
	name = "Power Spin"
	desc = "Tail Swipe отталкивает на тайл дальше и накладывает 3 секунды стаггера."
	cost = 5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_POWER_SPIN
	buff_desc = "+1 knockback and 3 sec stagger from Tail Swipe"

/atom/movable/screen/alert/status_effect/defender/power_spin
	name = "Power Spin"
	desc = "+1 knockback and 3 sec stagger from Tail Swipe"
	icon_state = "xenobuff_attack"

/datum/status_effect/defender/power_spin
	id = "upgrade_power_spin"
	alert_type = /atom/movable/screen/alert/status_effect/defender/power_spin

	/// The amount to increase Tail Swipe's knockback by.
	var/knockback_amount = 1
	/// The amount of deciseconds to increase Tail Swipe's stagger duration by.
	var/stagger_amount = 3 SECONDS

/datum/status_effect/defender/power_spin/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.knockback_distance += knockback_amount
	tail_sweep.stagger_duration += stagger_amount
	return TRUE

/datum/status_effect/defender/power_spin/on_remove()
	var/datum/action/ability/xeno_action/tail_sweep/tail_sweep = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/tail_sweep]
	if(!tail_sweep)
		return
	tail_sweep.knockback_distance -= knockback_amount
	tail_sweep.stagger_duration -= stagger_amount
	return ..()

//
//
//

/datum/xeno_mutation/defender/sharpening_claws
	name = "Sharpening Claws"
	desc = "Урон базовых атак увеличивается на 10% за каждые 5 потерянной брони."
	cost = 5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_SHARPENING_CLAWS
	buff_desc = "+10% damage from each 5 sunder loss, stackable"

/atom/movable/screen/alert/status_effect/defender/sharpening_claws
	name = "Sharpening Claws"
	desc = "+10% damage from each 5 sunder loss, stackable"
	icon_state = "xenobuff_attack"

/datum/status_effect/defender/sharpening_claws
	id = "upgrade_sharpening_claws"
	alert_type = /atom/movable/screen/alert/status_effect/defender/sharpening_claws

	/// The amount of sunder used to determine the final multiplier.
	var/sunder_repeating_threshold = 5
	/// The amount to increase the melee damage modifier by for each time the sunder threshold is passed.
	var/modifier_per_threshold = 0.1
	/// The amount that the melee damage modifier has been increased by so far.
	var/modifier_so_far = 0

/datum/status_effect/defender/sharpening_claws/on_apply()
	xenomorph_owner = owner
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE, PROC_REF(on_sunder_change))
	return TRUE

/datum/status_effect/defender/sharpening_claws/on_remove()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_SUNDER_CHANGE)
	return ..()

/// Changes melee damage modifier based on the difference between old and current sunder values.
/datum/status_effect/defender/sharpening_claws/proc/on_sunder_change(datum/source, old_sunder, new_sunder)
	SIGNAL_HANDLER
	var/new_modifier = round(new_sunder / sunder_repeating_threshold) * modifier_per_threshold
	if(new_modifier == modifier_so_far)
		return
	xenomorph_owner.xeno_melee_damage_modifier += (new_modifier - modifier_so_far)
	modifier_so_far = new_modifier
