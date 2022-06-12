GLOBAL_LIST_INIT(recipe_components, build_recipe_component_list())
GLOBAL_LIST_INIT(recipes, build_recipe_list())

/proc/build_recipe_component_list()
	var/list/recipe_component_list = list()
	for(var/type in typesof(/datum/recipe_component))
		if(is_abstract(type))
			continue
		recipe_component_list[type] = new type()
	return recipe_component_list

/proc/build_recipe_list()
	var/list/recipe_list = list()
	for(var/type in typesof(/datum/recipe))
		if(is_abstract(type))
			continue
		recipe_list[type] = new type()
	return recipe_list
