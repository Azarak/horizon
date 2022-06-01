/datum/slapcraft_recipe
	/// Name of the recipe. Will use the resulting atom's name if not specified
	var/name
	/// List of all steps to finish this recipe
	var/list/steps
	/// Type of the item that will be yielded as the result.
	var/result_type
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
	if(!name && result_type)
		var/atom/movable/result_cast = result_type
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
	if(result_type)
		var/atom/movable/result_cast = result_type
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
	var/atom/movable/result_item = create_item(assembly)
	after_create_item(result_item, assembly)
	dispose_assembly(assembly)

/// The proc that creates the resulted item and passes it as a return.
/datum/slapcraft_recipe/proc/create_item(obj/item/slapcraft_assembly/assembly)
	return new result_type(assembly.loc)

/// Behaviour after the item is created, and before the slapcrafting assembly is disposed.
/// Here you can move the components into the item if you wish, or do other stuff with them.
/datum/slapcraft_recipe/proc/after_create_item(atom/movable/result_item, obj/item/slapcraft_assembly/assembly)
	return

/// Here is the proc to get rid of the assembly, should one want to override it to handle that differently.
/datum/slapcraft_recipe/proc/dispose_assembly(obj/item/slapcraft_assembly/assembly)
	qdel(assembly)
