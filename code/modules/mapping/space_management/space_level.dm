/datum/space_level
	var/name = "NAME MISSING"
	var/z_value = 1 //actual z placement
	/// Virtual levels contained in this z level
	var/list/virtual_levels = list()

/datum/space_level/New(new_z, new_name)
	z_value = new_z
	name = new_name
