/// Randomized Chemical Reactions
/// Uses randomized recipes for a consistent output.
/// Creates a recipe the first time a reaction occurs.
/// Codebase by Kirie

/datum/chemical_reaction/randomized/abno_chem
	randomize_req_temperature = FALSE

	randomize_inputs = TRUE
	min_input_reagent_amount = 1
	max_input_reagent_amount = 1
	min_input_reagents = 2
	max_input_reagents = 2
	possible_reagents = list(
		/datum/reagent/abnormality/nutrition,
		/datum/reagent/abnormality/cleanliness,
		/datum/reagent/abnormality/consensus,
		/datum/reagent/abnormality/amusement,
		/datum/reagent/abnormality/violence,
		/datum/reagent/abnormality/abno_flesh
	)

	max_catalysts = 0

	results = list(/datum/reagent/toxin = 2)

	var/datum/ac_recipe/reagent/linked_recipe
	var/random_threat_level = FALSE

/datum/chemical_reaction/randomized/abno_chem/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem)
		return FALSE
	if(random_threat_level)
		possible_reagents = list(/datum/reagent/abnormality/abno_flesh)
		for(var/type_path in subtypesof(/mob/living/simple_animal/hostile/abnormality))
			var/mob/living/simple_animal/hostile/abnormality/abno = type_path
			if(initial(abno.threat_level) != random_threat_level || !initial(abno.chem_type))
				continue
			possible_reagents += initial(abno.chem_type)
	. = ..()
	return

/datum/chemical_reaction/randomized/abno_chem/on_reaction(datum/reagents/holder, created_volume)
	if(!linked_recipe)
		linked_recipe = new
		linked_recipe.chem_req = required_reagents
		linked_recipe.chem_result = results
		if(results.len > 1)
			linked_recipe.name = "Mixed Reagent Recipe"
		else
			for(var/R in results)
				var/datum/reagent/rea = R
				linked_recipe.name = "[initial(rea.name)] Recipe"
		linked_recipe.desc = "Makes"
		for(var/R in results)
			var/datum/reagent/rea = R
			linked_recipe.desc = linked_recipe.desc + " [initial(rea.name)] ([results[R]]u)"
		SEND_GLOBAL_SIGNAL("!new_reaction", linked_recipe)
	return ..()

// Utilizes Zayin chemicals
/datum/chemical_reaction/randomized/abno_chem/zayin
	random_threat_level = ZAYIN_LEVEL

/datum/chemical_reaction/randomized/abno_chem/zayin/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem/zayin)
		return FALSE
	return ..()

// Utilizes TETH chemicals
/datum/chemical_reaction/randomized/abno_chem/teth
	random_threat_level = TETH_LEVEL

/datum/chemical_reaction/randomized/abno_chem/teth/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem/teth)
		return FALSE
	return ..()

// Utilizes HE chemicals
/datum/chemical_reaction/randomized/abno_chem/he
	random_threat_level = HE_LEVEL

/datum/chemical_reaction/randomized/abno_chem/he/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem/he)
		return FALSE
	return ..()

// Utilizes WAW chemicals
/datum/chemical_reaction/randomized/abno_chem/waw
	random_threat_level = WAW_LEVEL

/datum/chemical_reaction/randomized/abno_chem/waw/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem/waw)
		return FALSE
	return ..()

// Utilizes ALEPH chemicals
/datum/chemical_reaction/randomized/abno_chem/aleph
	random_threat_level = ALEPH_LEVEL

/datum/chemical_reaction/randomized/abno_chem/aleph/GenerateRecipe()
	if(src.type == /datum/chemical_reaction/randomized/abno_chem/aleph)
		return FALSE
	return ..()


/// Non-Randomized Chemical Reactions
/// Uses consistent recipes for a consistent output.
/// Creates a recipe the first time a reaction occurs.
/datum/chemical_reaction/abno_chem
	var/datum/ac_recipe/reagent/linked_recipe

/datum/chemical_reaction/abno_chem/on_reaction(datum/reagents/holder, created_volume)
	if(!linked_recipe)
		linked_recipe = new
		linked_recipe.chem_req = required_reagents
		linked_recipe.chem_result = results
		if(results.len > 1)
			linked_recipe.name = "Mixed Reagent Recipe"
		else
			for(var/R in results)
				var/datum/reagent/rea = R
				linked_recipe.name = "[initial(rea.name)] Recipe"
		linked_recipe.desc = "Makes"
		for(var/R in results)
			var/datum/reagent/rea = R
			linked_recipe.desc = linked_recipe.desc + " [initial(rea.name)] ([results[R]]u)"
		SEND_GLOBAL_SIGNAL("!new_reaction", linked_recipe)
	return ..()
