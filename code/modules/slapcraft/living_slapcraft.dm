/// Have a living mob attempt to do a slapcraft. The mob is using the second item on the first item.
/mob/living/proc/try_slapcraft(obj/item/first_item, obj/item/second_item)
	// We need to find a recipe where the first item corresponds to the first step 
	// ..and the second item corresponds to the second step
	var/datum/slapcraft_recipe/target_recipe
	for(var/recipe_type in GLOB.slapcraft_recipes)
		var/datum/slapcraft_recipe/recipe = SLAPCRAFT_RECIPE(recipe_type)
		var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(recipe.steps[1])
		var/datum/slapcraft_step/step_two = SLAPCRAFT_STEP(recipe.steps[2])
		if(!step_one.perform_check(src, first_item, null) || !step_two.perform_check(src, second_item, null))
			continue
		// TODO: There could be a couple recipes matching those two first steps, most notably cooking recipes.
		// Make sure there is a way to choose which recipe you want to perform.
		target_recipe = recipe
		break
	if(!target_recipe)
		return FALSE
	// We have found the recipe we want to do, make an assembly item where the first item used to be.
	var/obj/item/slapcraft_assembly/assembly = new(get_turf(first_item))
	assembly.set_recipe(target_recipe)

	var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(target_recipe.steps[1])
	var/datum/slapcraft_step/step_two = SLAPCRAFT_STEP(target_recipe.steps[2])

	// Instantly and silently perform the first step on the assembly, disassemble it if something went wrong
	if(!step_one.perform(src, first_item, assembly, instant = TRUE, silent = TRUE))
		assembly.disassemble()
		return TRUE
	// Perform the second step.
	// Alternatively, pass the attack chain onto the assembly to progress the crafting instead of calling it directly from the step.
	step_two.perform(src, second_item, assembly)
	return TRUE
