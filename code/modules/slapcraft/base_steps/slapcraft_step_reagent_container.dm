/// This step requires to input a reagent container, possibly with some reagent inside, or with some volume specifications.
/datum/slapcraft_step/reagent_container
	insert_item = TRUE
	uses_something = TRUE
	item_types = list(/obj/item/reagent_containers)
	/// Type of the reagent needed.
	var/reagent_type
	/// Volume of the reagent needed.
	var/reagent_volume
	/// The amount of container volume we require if any.
	var/container_volume
	/// Amount of free volume we require if any.
	var/free_volume
	/// Whether we need an open container to do this.
	var/needs_open_container = TRUE

/datum/slapcraft_step/reagent_container/can_perform(mob/living/user, obj/item/item)
	var/obj/item/reagent_containers/container = item
	if(needs_open_container && !container.is_open_container())
		return FALSE
	if(!isnull(reagent_type) && !container.reagents.has_reagent(reagent_type, reagent_volume))
		return FALSE
	if(!isnull(container_volume) && container.reagents.maximum_volume < container_volume)
		return FALSE
	if(!isnull(free_volume) && (container.reagents.maximum_volume - container.reagents.total_volume) < free_volume)
		return FALSE
	return TRUE
