/datum/organ_choice
	abstract_type = /datum/organ_choice
	/// User facing name of the organ choice.
	var/name = "Organ"
	/// Type of the entry datum which is used for save/load of information.
	var/organ_entry_type = /datum/organ_entry
	/// Typepath of the organ this choice yields.
	var/organ_type
	/// Typepath of the organ DNA.
	var/organ_dna_type = /datum/organ_dna
	/// List of sprite accessories this choice allows. Can be null
	var/list/sprite_accessories
	/// The default sprite accessory from `sprite_accessories`.
	var/default_accessory
	/// Whether this organ choice allows to customize colors of sprite accessories.
	var/allows_accessory_color_customization = TRUE

/datum/organ_choice/New()
	. = ..()
	if(length(sprite_accessories))
		if(!default_accessory)
			default_accessory = sprite_accessories[1]
		if(!(default_accessory in sprite_accessories))
			CRASH("Organ choice [type] has a default accessory which is unavailable in its accessory list.")

/datum/organ_choice/proc/make_default_organ_entry(datum/preferences/prefs, customizer_type)
	var/datum/organ_entry/entry = new organ_entry_type()
	entry.organ_customizer_type = customizer_type
	entry.organ_choice_type = type
	if(sprite_accessories)
		entry.set_accessory_type(prefs, default_accessory)
	return entry

/datum/organ_choice/proc/create_organ_dna(datum/organ_entry/entry)
	var/datum/organ_dna/organ_dna = new organ_dna_type()
	imprint_organ_dna(organ_dna)
	return organ_dna

/datum/organ_choice/proc/imprint_organ_dna(datum/organ_dna/organ_dna, datum/organ_entry/entry)
	organ_dna.organ_type = organ_type
	if(entry.accessory_type)
		organ_dna.accessory_type = entry.accessory_type
		if(allows_accessory_color_customization)
			organ_dna.accessory_colors = entry.accessory_colors
