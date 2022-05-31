GLOBAL_LIST_INIT(slapcraft_recipes, build_slapcraft_recipes())
GLOBAL_LIST_INIT(slapcraft_steps, build_slapcraft_steps())

/proc/build_slapcraft_recipes()
	var/list/recipe_list = list()
	for(var/type in subtypesof(/datum/slapcraft_recipe))
		recipe_list[type] = new type()
	return recipe_list

/proc/build_slapcraft_steps()
	var/list/step_list = list()
	for(var/type in subtypesof(/datum/slapcraft_step))
		step_list[type] = new type()
	return step_list
