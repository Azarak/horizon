/// Organ entry representing a saved/loaded information about a /datum/organ_choice and its related information.
/datum/organ_entry
	/// Used for identification.
	var/organ_customizer_type
	var/organ_choice_type
	var/accessory_type
	var/accessory_colors
	var/missing_organ = FALSE

/datum/organ_entry/proc/validate(datum/preferences/prefs)
	var/datum/organ_choice/organ_choice = ORGAN_CHOICE(organ_choice_type)
	if(missing_organ && !organ_choice.allows_missing_organ)
		missing_organ = FALSE
	/// Validate chosen accessory
	if(accessory_type && !organ_choice.sprite_accessories)
		accessory_type = null
		accessory_colors = null
	else if (organ_choice.sprite_accessories && !(accessory_type in organ_choice.sprite_accessories))
		set_accessory_type(prefs, organ_choice.default_accessory)
	/// Validate colors
	if(accessory_type)
		var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
		if(accessory.color_keys != 0)
			var/reset_colors = FALSE
			if(!accessory_colors)
				reset_colors = TRUE
			else
				var/list/color_list = color_string_to_list(accessory_colors)
				if(color_list.len != accessory.color_keys)
					reset_colors = TRUE
			if(reset_colors)
				accessory_colors = accessory.get_default_colors(color_key_source_list_from_prefs(prefs))

/datum/organ_entry/proc/set_accessory_type(datum/preferences/prefs, new_accessory_type)
	if(accessory_type == new_accessory_type)
		return
	if(!organ_choice_type)
		CRASH("Tried to set an organ entry accessory without an organ choice.")
	var/datum/organ_choice/organ_choice = ORGAN_CHOICE(organ_choice_type)
	if(!(new_accessory_type in organ_choice.sprite_accessories))
		CRASH("Tried to set an organ entry accessory that isn't allowed for the organ choice.")

	accessory_type = new_accessory_type
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	accessory_colors = accessory.get_default_colors(color_key_source_list_from_prefs(prefs))

/datum/organ_entry/proc/reset_accessory_colors(datum/preferences/prefs)
	if(!accessory_type)
		return
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	accessory_colors = accessory.get_default_colors(color_key_source_list_from_prefs(prefs))

