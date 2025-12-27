/datum/xeno_mutation
	var/name = "Unknown Mutation"
	var/desc = "A mysterious mutation"
	var/category = "Survival"
	var/cost
	///Дополнительная стоимость для определенных каст (может быть отрицательной)
	var/list/cost_change = list()
	var/icon_state

	///Тир, очередь в дереве, 1 если дерева нет
	var/tier = 1
	///Предыдущая мутация в дереве
	var/parent_name
	///Следующая мутация в дереве
	var/child_name
	///Статус эффект, который мутация применяет (бафф)
	var/status_effect_type
	///Способность, которая добавляется при покупке мутации (опционально)
	var/ability_type
	///Описание баффа, желательно числа и цифры
	var/buff_desc = ""
	///Касты, которым будет доступна данная мутация
	var/list/caste_restrictions = list()


/datum/xeno_mutation/proc/is_available(mob/living/carbon/xenomorph/xeno)
	if(length(caste_restrictions) > 0)
		var/current_caste = lowertext(xeno.xeno_caste.caste_name)
		return current_caste in caste_restrictions
	return TRUE

/datum/xeno_mutation/proc/is_purchased(mob/living/carbon/xenomorph/xeno)
	if(name in xeno.purchased_mutations)
		return TRUE
	return is_higher_tier_purchased(xeno)

/datum/xeno_mutation/proc/is_higher_tier_purchased(mob/living/carbon/xenomorph/xeno)
	if(child_name && (child_name in xeno.purchased_mutations))
		return TRUE
	if(child_name)
		var/datum/xeno_mutation/child_mutation = get_xeno_mutation_by_name(child_name)
		if(child_mutation && child_mutation.is_higher_tier_purchased(xeno))
			return TRUE
	return FALSE

/datum/xeno_mutation/proc/is_unlocked(mob/living/carbon/xenomorph/xeno)
	if(!parent_name)
		return TRUE
	return parent_name in xeno.purchased_mutations

/datum/xeno_mutation/proc/to_list(mob/living/carbon/xenomorph/xeno)
	return list(
		"name" = name,
		"desc" = desc,
		"category" = category,
		"cost" = get_mutation_cost_for_caste(src, xeno.xeno_caste.caste_name),
		"icon" = icon_state,
		"available" = is_available(xeno),
		"purchased" = is_purchased(xeno),
		"tier" = tier,
		"parent" = parent_name,
		"children" = child_name ? list(child_name) : list(),
		"unlocked" = is_unlocked(xeno),
		"buff_desc" = buff_desc,
		"caste_restriction" = caste_restrictions
	)


//////////////////////////////////////////////////////////////////////////////////////
/////////////////MUTATIONS////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////


//
// Carapace mutations
//

/datum/xeno_mutation/carapace_one
	name = "Carapace I"
	desc = "Слабо увеличивает броню всех типов."
	category = "Survival"
	cost = 5
	cost_change = list("crusher" = 5, "queen" = 5, "king" = 5, "behemoth" = 5)
	icon_state = "carapace"
	tier = 1
	parent_name = null
	child_name = "Carapace II"
	status_effect_type = STATUS_EFFECT_CARAPACE
	buff_desc = "+2.5 soft armor"

/datum/xeno_mutation/carapace/two
	name = "Carapace II"
	desc = "Больше брони?.."
	cost = 10
	icon_state = "carapace_two"
	tier = 2
	parent_name = "Carapace I"
	child_name = "Carapace III"
	status_effect_type = STATUS_EFFECT_CARAPACE_TWO
	buff_desc = "+5 soft armor"

/datum/xeno_mutation/carapace/three
	name = "Carapace III"
	desc = "Nanomachines, son."
	cost = 15
	icon_state = "carapace_three"
	tier = 3
	parent_name = "Carapace II"
	child_name = null
	status_effect_type = STATUS_EFFECT_CARAPACE_THREE
	buff_desc = "+10 soft armor"


//
// Regeneration mutations
//


/datum/xeno_mutation/regeneration
	name = "Regeneration I"
	desc = "Незначительно увеличивает регенерацию."
	category = "Survival"
	cost = 10
	cost_change = list("queen" = 5, "king" = 5, "behemoth" = 5, "gorger" = 5)
	icon_state = "regeneration"
	tier = 1
	parent_name = null
	child_name = "Regeneration II"
	status_effect_type = STATUS_EFFECT_REGENERATION
	buff_desc = "+0.8% health and sunder regen"

/datum/xeno_mutation/regeneration/two
	name = "Regeneration II"
	desc = "Еще больше регенерации."
	cost = 10
	icon_state = "regeneration_two"
	tier = 2
	parent_name = "Regeneration I"
	child_name = null
	status_effect_type = STATUS_EFFECT_REGENERATION_TWO
	buff_desc = "+1.6% health and sunder regen"


//
// Vampirism mutations
//

/datum/xeno_mutation/vampirism
	name = "Vampirism"
	desc = "Регенерирует часть здоровья при базовых атаках."
	category = "Survival"
	cost = 15
	cost_change = list("queen" = 5, "king" = 5, "behemoth" = 5, "gorger" = 5)
	icon_state = "vampirism"
	tier = 1
	parent_name = null
	child_name = "Leech"
	status_effect_type = STATUS_EFFECT_VAMPIRISM
	buff_desc = "1% HP per slash"

/datum/xeno_mutation/vampirism/two
	name = "Leech"
	desc = "Регенерирует СКОЛЬКО?..."
	cost = 25
	icon_state = "leech"
	tier = 2
	parent_name = "Vampirism"
	child_name = null
	status_effect_type = STATUS_EFFECT_VAMPIRISM_TWO
	buff_desc = "3% HP per slash"


//
// Celerity mutation
//

/datum/xeno_mutation/celerity
	name = "Celerity"
	desc = "Увеличивает твою скорость."
	category = "Offensive"
	cost = 10
	cost_change = list("runner" = 5, "hunter" = 5, "ravager" = 5, "defiler" = 5)
	icon_state = "celerity"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_CELERITY
	buff_desc = "+10% speed"


//
// Ionize mutations
//

/datum/xeno_mutation/ionize
	name = "Ionize I"
	desc = "Незначительно увеличивает максимальную ёмкость плазмы"
	category = "Specialized"
	cost = 10
	cost_change = list("drone" = 5, "hivelord" = 5, "warlock" = 5, "queen" = 5, "king" = 5)
	icon_state = "ionize"
	tier = 1
	parent_name = null
	child_name = "Ionize II"
	status_effect_type = STATUS_EFFECT_IONIZE
	buff_desc = "+15% max plasma"

/datum/xeno_mutation/ionize/two
	name = "Ionize II"
	desc = "Увеличивает эффект прошлой мутации и добавляет регенерацию."
	cost = 20
	icon_state = "ionize_two"
	tier = 2
	parent_name = "Ionize I"
	child_name = null
	status_effect_type = STATUS_EFFECT_IONIZE_TWO
	buff_desc = "+30% max plasma, +10% plasma regen"

//
//Crush mutation
//

/datum/xeno_mutation/crush
	name = "Crush"
	desc = "Незначительно увеличивает пробитие базовой атаки по объектам."
	category = "Offensive"
	cost = 5
	cost_change = list("behemoth" = 5)
	icon_state = "crush"
	tier = 1
	parent_name = null
	child_name = null
	status_effect_type = STATUS_EFFECT_CRUSH
	buff_desc = "+5 penetration"

//
//Toxin mutations
//

/datum/xeno_mutation/toxin
	name = "Toxin I"
	desc = "Позволяет вводить выбранный реагент при атаке."
	category = "Offensive"
	cost = 10
	cost_change = list("runner" = 5, "defiler" = 5)
	icon_state = "toxin"
	tier = 1
	parent_name = null
	child_name = "Toxin II"
	ability_type = /datum/action/ability/xeno_action/mutation/toxin
	buff_desc = "0.5 chosen xeno-toxin per slash"

/datum/xeno_mutation/toxin/two
	name = "Toxin II"
	desc = "Увеличивает ввод реагента и открывает sanguinal."
	cost = 15
	icon_state = "toxin_two"
	tier = 2
	parent_name = "Toxin I"
	child_name = null
	ability_type = /datum/action/ability/xeno_action/mutation/toxin
	buff_desc = "1 chosen xeno-toxin per slash + sanguinal"

//
//Pheromones mutations
//

/datum/xeno_mutation/pheromones
	name = "Pheromones I"
	desc = "Позволяет выделять слабые феромоны."
	category = "Specialized"
	cost = 5
	cost_change = list("hivemind" = 5, "queen" = 5, "king" = 5)
	icon_state = "pheromones"
	tier = 1
	parent_name = null
	child_name = "Pheromones II"
	ability_type = /datum/action/ability/xeno_action/mutation/pheromones
	buff_desc = "1.5 pheromone power"

/datum/xeno_mutation/pheromones/two
	name = "Pheromones II"
	desc = "Позволяет выделять средние феромоны."
	cost = 10
	icon_state = "pheromones_two"
	tier = 2
	parent_name = "Pheromones I"
	child_name = "Pheromones III"
	ability_type = /datum/action/ability/xeno_action/mutation/pheromones
	buff_desc = "3 pheromone power"

/datum/xeno_mutation/pheromones/three
	name = "Pheromones III"
	desc = "Позволяет выделять сильные феромоны."
	cost = 15
	icon_state = "pheromones_three"
	tier = 3
	parent_name = "Pheromones II"
	child_name = null
	ability_type = /datum/action/ability/xeno_action/mutation/pheromones
	buff_desc = "4.5 pheromone power"

//
// Trail mutations
//

/datum/xeno_mutation/trail
	name = "Trail"
	desc = "Оставляет кислотный/липкий след с некоторым шансом."
	category = "Specialized"
	cost = 10
	icon_state = "trail"
	tier = 1
	parent_name = null
	child_name = null
	ability_type = /datum/action/ability/xeno_action/mutation/trail
	buff_desc = "50% acid trail chance"

GLOBAL_LIST_EMPTY(xeno_mutations)

/proc/initialize_xeno_mutations()
	if(length(GLOB.xeno_mutations))
		return

	for(var/mutation_type in subtypesof(/datum/xeno_mutation))
		var/datum/xeno_mutation/mutation = new mutation_type()
		// Only initialize mutations that have a proper name and cost (exclude abstract base classes)
		if(mutation.name && mutation.cost > 0)
			GLOB.xeno_mutations += mutation

/proc/get_xeno_mutation_by_name(mutation_name)
	initialize_xeno_mutations()
	for(var/datum/xeno_mutation/mutation in GLOB.xeno_mutations)
		if(mutation.name == mutation_name)
			return mutation
	return null

/// Get the cost of a mutation for a specific caste
/proc/get_mutation_cost_for_caste(datum/xeno_mutation/mutation, caste_type)
	if(!mutation)
		return 0

	var/base_cost = mutation.cost
	var/caste_name = lowertext(caste_type)

	// Check if there's a cost change for this caste
	if(caste_name in mutation.cost_change)
		return base_cost + mutation.cost_change[caste_name]

	return base_cost
