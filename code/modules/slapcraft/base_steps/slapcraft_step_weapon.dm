/// This steps can check sufficient weapon variables, such as sharpness or force
/datum/slapcraft_step/weapon
	insert_item = FALSE
	check_types = FALSE
	/// Required sharpness of the item for this step. (NONE, SHARP_EDGED, SHARP_POINTY)
	var/sharpness = NONE
	/// Required force of the item.
	var/force = 0

/datum/slapcraft_step/weapon/can_perform(mob/living/user, obj/item/item)
	if(sharpness != NONE && sharpness != item.sharpness)
		return FALSE
	if(item.force < force)
		return FALSE
	return TRUE
