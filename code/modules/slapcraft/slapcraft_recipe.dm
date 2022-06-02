/datum/slapcraft_recipe
	/// Name of the recipe. Will use the resulting atom's name if not specified
	var/name
	/// Description of the recipe. May be displayed as additional info in the handbook.
	var/desc
	/// List of all steps to finish this recipe
	var/list/steps
	/// Type of the item that will be yielded as the result.
	var/result_type
	/// Amount of how many resulting types will be crafted.
	var/result_amount = 1
	/// Instead of result type you can use this as associative list of types to amounts for a more varied output
	var/list/result_list
	/// Weight class of the assemblies for this recipe.
	var/assembly_weight_class = WEIGHT_CLASS_NORMAL
	/// Suffix for the assembly name.
	var/assembly_name_suffix = "assembly"
	/// Category this recipe is in the handbook.
	var/category = SLAP_CAT_MISC
	/// Subcategory this recipe is in the handbook.
	var/subcategory = SLAP_SUBCAT_MISC
	/// Appearance in the radial menu for the user to choose from if there are recipe collisions.
	var/image/radial_appearance

/datum/slapcraft_recipe/New()
	. = ..()
	// Check if the recipe has atleast 2 steps.
	if(length(steps) < 2)
		CRASH("Slapcrafting recipe of type [type] has less than 2 steps. This is wrong.")
	// Set the name from the resulting atom if the name is missing and resulting type is present.
	if(!name)
		var/atom/movable/result_cast
		if(result_list)
			for(var/path in result_list)
				// First association it can get, then break.
				result_cast = path
				break
		else if(result_type)
			result_cast = result_type
		if(result_cast)
			name = initial(result_cast.name)
	// Check if the first step is type checked, this is currently required because an optimization cache lookup works based off this.
	var/datum/slapcraft_step/step_one = SLAPCRAFT_STEP(steps[1])
	if(!step_one.check_types)
		CRASH("Slapcrafting recipe of type [type] has first step [step_one.type] which doesn't type check. This is incompatible with an optimization cache.")

/datum/slapcraft_recipe/proc/get_radial_image()
	if(!radial_appearance)
		radial_appearance = make_radial_image()
	return radial_appearance

/datum/slapcraft_recipe/proc/make_radial_image()
	// If we make an explicit result type, use its icon and icon state in the radial menu to display it.
	var/atom/movable/result_cast = result_type
	if(result_list)
		for(var/path in result_list)
			// First association it can get, then break.
			result_cast = path
			break
	else if(result_type)
		result_cast = result_type
	if(result_cast)
		return image(icon = initial(result_cast.icon), icon_state = initial(result_cast.icon_state))
	//Fallback image idk what to put here.
	return image(icon = 'icons/hud/radial.dmi', icon_state = "radial_rotate")

/// Gets a reference to the recipe step.
/datum/slapcraft_recipe/proc/get_recipe_step(step_to_get)
	if(step_to_get > steps.len)
		CRASH("Tried to get a slapcraft recipe step out of index.")
	return SLAPCRAFT_STEP(steps[step_to_get])

/// User has finished the recipe in an assembly.
/datum/slapcraft_recipe/proc/finish_recipe(mob/living/user, obj/item/slapcraft_assembly/assembly)
	to_chat(user, SPAN_NOTICE("You finish \the [name]."))
	assembly.being_finished = TRUE
	var/list/items_list  = create_items(assembly)
	// Move items which wanted to go to the resulted item into it. Only supports for the first created item.
	var/atom/movable/first_item = items_list[1]
	for(var/obj/item/item as anything in assembly.items_to_place_in_result)
		item.forceMove(first_item)

	after_create_items(items_list, assembly)
	dispose_assembly(assembly)

	//Finally, CheckParts on the resulting items.
	for(var/atom/movable/result_item as anything in items_list)
		result_item.CheckParts()

/// Runs when the last step tries to be performed and cancels the step if it returns FALSE. Could be used to validate location in structure construction via slap crafting.
/datum/slapcraft_recipe/proc/can_finish(mob/living/user, obj/item/slapcraft_assembly/assembly)
	return TRUE

/// The proc that creates the resulted item and passes it as a return.
/datum/slapcraft_recipe/proc/create_items(obj/item/slapcraft_assembly/assembly)
	/// Check if we want to craft multiple items, if yes then populate the list passed by the argument with them.
	var/list/contents_list = list()
	var/list/multi_to_craft
	if(result_list)
		multi_to_craft = result_list
	else if (result_amount)
		multi_to_craft = list()
		multi_to_craft[result_type] = result_amount
	if(multi_to_craft.len)
		for(var/path in multi_to_craft)
			var/amount = multi_to_craft[path]
			var/shift_pixels = amount > 1 ? TRUE : FALSE
			for(var/i in 1 to amount)
				var/atom/movable/new_thing = new path(assembly.loc)
				if(shift_pixels)
					new_thing.pixel_x += rand(-3,3)
					new_thing.pixel_y += rand(-3,3)
				contents_list += new_thing
	return contents_list

/// Behaviour after the item is created, and before the slapcrafting assembly is disposed.
/// Here you can move the components into the item if you wish, or do other stuff with them.
/datum/slapcraft_recipe/proc/after_create_items(list/items_list, obj/item/slapcraft_assembly/assembly)
	return

/// Here is the proc to get rid of the assembly, should one want to override it to handle that differently.
/datum/slapcraft_recipe/proc/dispose_assembly(obj/item/slapcraft_assembly/assembly)
	qdel(assembly)
