/datum/slapcraft_step
	/// The description of the step, it shows in the slapcraft handbook
	var/desc = "THIS IS HOW YOU DO THIS STEP"
	var/finished_desc = "SLAPCRAFT STEP FINISHED"
	var/todo_desc = "HOW TO DO NEXT STEP"
	var/finish_msg = "YOU FINISH THIS STEP"
	/// Whether we insert the valid item in the assembly.
	var/insert_item = TRUE
	/// How long does it take to perform the step.
	var/perform_time = 2 SECONDS
	/// Whether we should check the types of the item, if FALSE then make sure `can_perform()` checks conditions.
	var/check_types = TRUE
	/// List of types of items that can be used. Only relevant if `check_types` is TRUE
	var/list/item_types
	/// The typecache of types of the items.
	var/list/typecache

/datum/slapcraft_step/New()
	. = ..()
	if(check_types)
		if(!item_types || !length(item_types))
			CRASH("Slapcraft step of type [type] wants to check types but is missing `item_types`")
		typecache = typecacheof(item_types)

/// Checks whether a type is in the typecache of the step.
/datum/slapcraft_step/proc/check_type(checked_type)
	if(!typecache)
		CRASH("Slapcraft step [type] tried to check a type without a typecache!")
	if(typecache[checked_type])
		return TRUE
	return FALSE

/// Checks if the passed item is a proper type to perform this step, and whether it passes the `can_perform()` check. 
/datum/slapcraft_step/proc/perform_check(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	if(check_types && !check_type(item.type))
		return FALSE
	if(!can_perform(user, item, assembly))
		return FALSE
	return TRUE

/// Checks whether this step is the correct one to perform to progress an assembly.
/datum/slapcraft_step/proc/step_type_check(obj/item/slapcraft_assembly/assembly)
	var/target_step = assembly.recipe_step + 1
	var/datum/slapcraft_recipe/recipe = assembly.recipe
	if(length(recipe.steps) < target_step)
		CRASH("Tried to perform a slapcraft step on an assembly whose recipe doesn't have the next step and yet still exists.")
	var/target_step_type = recipe.steps[target_step]
	if(target_step_type != type)
		return FALSE
	return TRUE

/// Make a user perform this step, by using an item on the assembly, trying to progress the assembly.
/datum/slapcraft_step/proc/perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly, instant = FALSE, silent = FALSE)
	if(!perform_check(user, item, assembly) || !step_type_check(assembly))
		return FALSE
	if(perform_time && !instant)
		if(!do_after(user, perform_time * get_speed_multiplier(user, item, assembly), target = assembly))
			return FALSE
		// Do checks again because we spent time in a do_after(), this time also check deletions.
		if(QDELETED(assembly) || QDELETED(item) || !perform_check(user, item, assembly) || !step_type_check(assembly))
			return FALSE
	if(!silent && finish_msg)
		to_chat(user, SPAN_NOTICE(finish_msg))
	on_perform(user, item, assembly)
	if(insert_item)
		move_item_to_assembly(user, item, assembly)
	if(progress_crafting(user, item, assembly))
		assembly.progress(user)
	return TRUE

/// Below are virtual procs I encourage steps to override for their specific behaviours.

/// Checks whether a user can perform this step with an item. Exists so steps can override this proc for their own behavioural checks.
/// `assembly` can be null here, when the recipe finding checks are trying to figure out what recipe we can make.
/datum/slapcraft_step/proc/can_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	return TRUE

/// Behaviour to happen on performing this step. Perhaps removing a portion of reagents to create an IED or something.
/datum/slapcraft_step/proc/on_perform(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	return

/// Behaviour to move the item into the assembly. Stackable items may want to change how they do this.
/datum/slapcraft_step/proc/move_item_to_assembly(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	item.forceMove(assembly)

/// Whether the step progresses towards the next step when successfully performed. 
/// This can be used to allow "freeform" crafting to put more things into an assembly than required, possibly utilizing it for things like custom burgers
/datum/slapcraft_step/proc/progress_crafting(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	return TRUE

/// Returns a speed multiplier to the time it takes for the step to complete. Useful for tool-related steps
/datum/slapcraft_step/proc/get_speed_multiplier(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	return 1
