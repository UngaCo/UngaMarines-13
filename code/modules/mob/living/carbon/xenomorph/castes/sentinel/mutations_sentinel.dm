#define STATUS_EFFECT_COMFORTING_ACID /datum/status_effect/sentinel/comforting_acid
#define STATUS_EFFECT_HEALING_STING /datum/status_effect/sentinel/healing_sting
#define STATUS_EFFECT_ACIDIC_SLASHER /datum/status_effect/sentinel/acidic_slasher
#define STATUS_EFFECT_FAR_STING /datum/status_effect/sentinel/far_sting
#define STATUS_EFFECT_TOXIC_COMPATIBILITY /datum/status_effect/sentinel/toxic_compatibility
#define STATUS_EFFECT_TOXIC_BLOOD /datum/status_effect/sentinel/toxic_blood

/datum/xeno_mutation/sentinel
	category = "Enhancement"
	caste_restrictions = list("sentinel")

/datum/status_effect/sentinel
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	/// The xenomorph that owns this status effect.
	var/mob/living/carbon/xenomorph/xenomorph_owner

/*
/datum/xeno_mutation/sentinel
	name = ""
	desc = ""
	cost =
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_
	buff_desc = ""

/atom/movable/screen/alert/status_effect/sentinel
	name = ""
	desc = ""
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel
	id = "upgrade_"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel

/datum/status_effect/sentinel/.../on_apply()
	xenomorph_owner = owner
	return TRUE

/datum/status_effect/sentinel/.../on_remove()
	return ..()
*/

/datum/xeno_mutation/sentinel/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash пассивно лечит 2 здоровья за каждый стак Intoxicated"
	cost = 15
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_COMFORTING_ACID
	buff_desc = "Toxic Slash heals 2 hp per Intoxicated stack"

/atom/movable/screen/alert/status_effect/sentinel/comforting_acid
	name = "Comforting Acid"
	desc = "Toxic Slash heals 2 hp per Intoxicated stack"
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/comforting_acid
	id = "upgrade_comforting_acid"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/comforting_acid

	/// For the first structure, the health to heal.
	var/healing_initial = 2

/datum/status_effect/sentinel/comforting_acid/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack += healing_initial
	return TRUE

/datum/status_effect/sentinel/comforting_acid/on_remove()
	var/datum/action/ability/xeno_action/toxic_slash/slash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/toxic_slash]
	if(!slash_ability)
		return
	slash_ability.healing_per_stack -= healing_initial
	return ..()

//
//
//

/datum/xeno_mutation/sentinel/healing_sting
	name = "Healing Sting"
	desc = "Drain Sting лечит в 2 раза больше, лишнее здоровье будет считаться как оверхил."
	cost = 10
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_HEALING_STING
	buff_desc = "200% health from Drain Sting, with overheal"

/atom/movable/screen/alert/status_effect/sentinel/healing_sting
	name = "Healing Sting"
	desc = "200% health from Drain Sting, with overheal"
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/healing_sting
	id = "upgrade_healing_sting"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/healing_sting

	/// The multiplier to add to Drain Sting's healing.
	var/multiplier_initial = 1

/datum/status_effect/sentinel/healing_sting/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier += multiplier_initial
	return TRUE

/datum/status_effect/sentinel/healing_sting/on_remove()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.heal_multiplier -= multiplier_initial
	return ..()

//
//
//

/datum/xeno_mutation/sentinel/acidic_slasher
	name = "Acidic Slasher"
	desc = "Скорость атак увеличена, теперь они накладывают 3 стака Intoxicated, но урон уменьшен вдвое"
	cost = 7.5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_ACIDIC_SLASHER
	buff_desc = "-0.1 attack delay; +3 Intoxicated stacks per slash; -50% damage"

/atom/movable/screen/alert/status_effect/sentinel/acidic_slasher
	name = "Acidic Slasher"
	desc = "-0.1 attack delay; +3 Intoxicated stacks per slash; -50% damage"
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/acidic_slasher
	id = "upgrade_acidic_slasher"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/acidic_slasher

	/// The amount of deciseconds to decrease their next move by.
	var/attack_speed_decrease = 1
	/// The amount of intoxicated to apply.
	var/intoxicated_stacks = 3
	/// The amount to decrease the melee damage modifier by.
	var/melee_damage_modifier = 0.5

/datum/status_effect/sentinel/acidic_slasher/on_apply()
	xenomorph_owner = owner
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))
	xenomorph_owner.xeno_melee_damage_modifier -= melee_damage_modifier
	xenomorph_owner.next_move_adjust -= attack_speed_decrease
	return TRUE

/datum/status_effect/sentinel/acidic_slasher/on_remove()
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING)
	xenomorph_owner.xeno_melee_damage_modifier += melee_damage_modifier
	xenomorph_owner.next_move_adjust += attack_speed_decrease
	return ..()

/// Applies a variable amount of Intoxicated stacks to those that they attack.
/datum/status_effect/sentinel/acidic_slasher/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	if(!debuff)
		target.apply_status_effect(STATUS_EFFECT_INTOXICATED, intoxicated_stacks)
		return
	debuff.add_stacks(intoxicated_stacks)

//
//
//

/datum/xeno_mutation/sentinel/far_sting
	name = "Far Sting"
	desc = "Drain Sting может быть использован на 1 тайл дальше, но с меньшей эффективностью"
	cost = 10
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_FAR_STING
	buff_desc = "+1 range for Drain Sting, but with 75% power in max range"

/atom/movable/screen/alert/status_effect/sentinel/far_sting
	name = "Far Sting"
	desc = ""
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/far_sting
	id = "upgrade_far_sting"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/far_sting

	/// For the first structure, the range to increase by.
	var/range_initial = 1
	/// For each structure, the effectiveness of Drain Sting at a range that isn't upclose.
	var/effectiveness_initial = 0.75

/datum/status_effect/sentinel/far_sting/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range += range_initial
	sting_ability.ranged_effectiveness += effectiveness_initial
	return TRUE

/datum/status_effect/sentinel/far_sting/on_remove()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.targetable_range -= range_initial
	sting_ability.ranged_effectiveness -= effectiveness_initial
	return ..()

//
//
//

/datum/xeno_mutation/sentinel/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Каждые 3u ксенореагентов в цели будут считаться как стак Intoxicated при Drain Sting."
	cost = 5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_TOXIC_COMPATIBILITY
	buff_desc = "Each 3u xenoreagents == 1 Intoxicated stack for Drain Sting"

/atom/movable/screen/alert/status_effect/sentinel/toxic_compatibility
	name = "Toxic Compatibility"
	desc = "Each 3u xenoreagents == 1 Intoxicated stack for Drain Sting"
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/toxic_compatibility
	id = "upgrade_toxic_compatibility"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/toxic_compatibility

	///The additional amount of xeno-chemicals to convert to one stack of Intoxicated.
	var/amount_chem = 3

/datum/status_effect/sentinel/toxic_compatibility/on_apply()
	xenomorph_owner = owner
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.chemical_potency = (1 / amount_chem) * SENTINEL_DRAIN_MULTIPLIER
	return TRUE

/datum/status_effect/sentinel/toxic_compatibility/on_remove()
	var/datum/action/ability/activable/xeno/drain_sting/sting_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/drain_sting]
	if(!sting_ability)
		return
	sting_ability.chemical_potency = initial(sting_ability.chemical_potency)

//
//
//

/datum/xeno_mutation/sentinel/toxic_blood
	name = "Toxic Blood"
	desc = "За каждые полученные 40 урона, 1 стак Intoxicated будет накладываться на ближайших людей."
	cost = 5
	icon_state = "xenobuff_generic"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_TOXIC_BLOOD
	buff_desc = "Every 40 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."

/atom/movable/screen/alert/status_effect/sentinel/toxic_blood
	name = "Toxic Blood"
	desc = "Every 40 damage you take, 1 stacks of Intoxicated will be applied to nearby humans."
	icon_state = "xenobuff_attack"

/datum/status_effect/sentinel/toxic_blood
	id = "upgrade_toxic_blood"
	alert_type = /atom/movable/screen/alert/status_effect/sentinel/toxic_blood

	/// For the first structure, the damage needed to be taken.
	var/damage_initial = 40
	/// The amount of damage taken so far before threshold is calculated.
	var/damage_taken_so_far = 0
	/// The amount of intoxicated stacks to apply.
	var/intoxicated_stacks_to_apply = 1

/datum/status_effect/sentinel/toxic_blood/on_apply()
	xenomorph_owner = owner
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	return TRUE

/datum/status_effect/sentinel/toxic_blood/on_remove()
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_MOB_STAT_CHANGED))
	return ..()

/// Apply intoxicated stacks to nearby alive humans if the damage threshold is reached.
/datum/status_effect/sentinel/toxic_blood/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xenomorph_owner.stat == DEAD) // It is fine to be unconscious!
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far < damage_initial)
		return
	damage_taken_so_far = 0
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(xenomorph_owner, 1))
		if(nearby_human.stat == DEAD)
			continue
		var/datum/status_effect/stacking/intoxicated/debuff = nearby_human.has_status_effect(STATUS_EFFECT_INTOXICATED)
		if(!debuff)
			nearby_human.apply_status_effect(STATUS_EFFECT_INTOXICATED, intoxicated_stacks_to_apply)
			continue
		debuff.add_stacks(intoxicated_stacks_to_apply)
