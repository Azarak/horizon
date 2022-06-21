/datum/organ_dna
	/// Type of the organ thats imprinted.
	var/organ_type
	/// Accessory type thats imprinted.
	var/accessory_type
	/// Accessory colors thats imprinted.
	var/accessory_colors

/// Creates an organ at location, imprints its information on it and returns it
/datum/organ_dna/proc/create_organ(atom/location)
	var/obj/item/organ/new_organ = new organ_type(location)
	imprint_organ(new_organ)
	return new_organ
	
/// Imprints information on the organ.
/datum/organ_dna/proc/imprint_organ(obj/item/organ/organ)
	if(accessory_type)
		organ.set_accessory_type(accessory_type, accessory_colors)
