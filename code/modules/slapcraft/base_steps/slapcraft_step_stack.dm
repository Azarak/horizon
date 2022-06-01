/// This step requires an amount of a stack items which will be split off and put into the assembly.
/datum/slapcraft_step/stack
	insert_item = TRUE
	uses_something = TRUE
	item_types = list(/obj/item/stack)
	/// Amount of the stack items to be put into the assembly.
	var/amount = 1

/datum/slapcraft_step/stack/can_perform(mob/living/user, obj/item/item)
	var/obj/item/stack/stack = item
	if(stack.amount < amount)
		return FALSE
	return TRUE

/datum/slapcraft_step/stack/move_item_to_assembly(mob/living/user, obj/item/item, obj/item/slapcraft_assembly/assembly)
	var/obj/item/stack/stack = item
	// Exactly how much we needed, just put the entirety in the assembly
	if(stack.amount == amount)
		stack.forceMove(assembly)
	else
		// We have more than we need, split the stacks off
		var/obj/item/stack/split_stack = stack.split_stack(null, amount)
		split_stack.forceMove(assembly)
