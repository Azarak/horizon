/datum/preferences/proc/validate_organ_entries()
	organ_entries = SANITIZE_LIST(organ_entries)
	var/datum/species/species = pref_species
	var/list/customizers = species.organ_customizers
	/// Check if we have any organ entries that don't match.
	for(var/datum/organ_entry/entry as anything in organ_entries)
		var/validated = FALSE
		for(var/customizer_type as anything in customizers)
			if(customizer_type != entry.organ_customizer_type)
				continue
			var/datum/organ_customizer/customizer = ORGAN_CUSTOMIZER(customizer_type)
			if(!(entry.organ_choice_type in customizer.organ_choices))
				continue
			var/datum/organ_choice/organ_choice = ORGAN_CHOICE(entry.organ_choice_type)
			if(entry.type != organ_choice.organ_entry_type)
				continue
			validated = TRUE
			break

		if(!validated)
			organ_entries -= entry

	/// Check if we have any missing organ entries
	for(var/customizer_type as anything in customizers)
		var/found = FALSE
		for(var/datum/organ_entry/entry as anything in organ_entries)
			if(entry.organ_customizer_type != customizer_type)
				continue
			found = TRUE
			break
		var/datum/organ_customizer/customizer = ORGAN_CUSTOMIZER(customizer_type)
		if(!found)
			organ_entries += customizer.make_default_organ_entry(src)

	/// Validate the variables within organ entries
	for(var/datum/organ_entry/entry as anything in organ_entries)
		entry.validate(src)

/// Gets an associative list of organ slots to organ dna created from organ customization
/datum/preferences/proc/get_organ_dna_list()
	var/list/organ_list = list()
	for(var/datum/organ_entry/entry as anything in organ_entries)
		var/datum/organ_choice/organ_choice = ORGAN_CHOICE(entry.organ_choice_type)
		organ_list[organ_choice.organ_slot] = organ_choice.create_organ_dna(entry)

	return organ_list
