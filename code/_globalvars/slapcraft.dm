GLOBAL_LIST_EMPTY(slapcraft_categorized_recipes)
GLOBAL_LIST_INIT(slapcraft_recipes, build_slapcraft_recipes())
GLOBAL_LIST_INIT(slapcraft_steps, build_slapcraft_steps())


/proc/build_slapcraft_recipes()
	var/list/recipe_list = list()
	for(var/type in subtypesof(/datum/slapcraft_recipe))
		var/datum/slapcraft_recipe/recipe = new type()
		recipe_list[type] = recipe

		// Add the recipe to the categorized global list, which is used for the handbook UI
		if(!GLOB.slapcraft_categorized_recipes[recipe.category])
			GLOB.slapcraft_categorized_recipes[recipe.category] = list()
		if(!GLOB.slapcraft_categorized_recipes[recipe.category][recipe.subcategory])
			GLOB.slapcraft_categorized_recipes[recipe.category][recipe.subcategory] = list()
		GLOB.slapcraft_categorized_recipes[recipe.category][recipe.subcategory] += recipe

	return recipe_list

/proc/build_slapcraft_steps()
	var/list/step_list = list()
	for(var/type in subtypesof(/datum/slapcraft_step))
		step_list[type] = new type()
	return step_list
