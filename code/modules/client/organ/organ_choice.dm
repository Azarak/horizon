/datum/organ_choice
	abstract_type = /datum/organ_choice
	/// User facing name of the organ choice.
	var/name = "Organ"
	/// Type of the entry datum which is used for save/load of information.
	var/organ_entry_type = /datum/organ_entry
	/// Typepath of the organ this choice yields.
	var/organ_type
	/// Slot of the organ.
	var/organ_slot
	/// Typepath of the organ DNA.
	var/organ_dna_type = /datum/organ_dna
	/// List of sprite accessories this choice allows. Can be null
	var/list/sprite_accessories
	/// The default sprite accessory from `sprite_accessories`.
	var/default_accessory
	/// Whether this organ choice allows to customize colors of sprite accessories.
	var/allows_accessory_color_customization = TRUE
	/// Whether this choice allows the user to choose to be missing an organ.
	var/allows_missing_organ = FALSE

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
	imprint_organ_dna(organ_dna, entry)
	return organ_dna

/datum/organ_choice/proc/imprint_organ_dna(datum/organ_dna/organ_dna, datum/organ_entry/entry)
	organ_dna.organ_type = organ_type
	if(allows_missing_organ && entry.missing_organ)
		organ_dna.missing_organ = TRUE
	if(entry.accessory_type)
		organ_dna.accessory_type = entry.accessory_type
		if(allows_accessory_color_customization)
			organ_dna.accessory_colors = entry.accessory_colors

/// When you want to customize an organ but not through DNA (hair dye for example)
/datum/organ_choice/proc/customize_organ(obj/item/organ/organ, datum/organ_entry/entry)
	return

/datum/organ_choice/proc/show_pref_choices(datum/preferences/prefs, datum/organ_entry/entry, customizer_type)
	var/list/dat = list()
	generate_pref_choices(dat, prefs, entry, customizer_type)
	return dat

/datum/organ_choice/proc/generate_pref_choices(list/dat, datum/preferences/prefs, datum/organ_entry/entry, customizer_type)
	var/datum/sprite_accessory/accessory
	if(sprite_accessories && entry.accessory_type)
		accessory = SPRITE_ACCESSORY(entry.accessory_type)

	if(accessory)
		var/accessory_link
		var/arrows_string
		if(length(sprite_accessories) > 1)
			accessory_link = "href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=choose_acc'"
			arrows_string = "<a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=next_acc''><</a><a href='?_src_=prefs]task=change_organ;customizer=[customizer_type];organ=prev_acc''>></a>"
		else
			accessory_link = "class='linkOff'"
			arrows_string = "<a class='linkOff'><</a><a class='linkOff'>></a>"
		dat += "<br>[arrows_string]<a [accessory_link]>[accessory.name]</a>"

		if(allows_accessory_color_customization)
			var/list/color_list = color_string_to_list(entry.accessory_colors)
			for(var/index in 1 to accessory.color_keys)
				var/named_index = (accessory.color_keys == 1) ? accessory.color_key_name : accessory.color_key_names[index]
				dat += "<br>[named_index]: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=acc_color;color_index=[index]''><span class='color_holder_box' style='background-color:[color_list[index]]'></span></a>"

/datum/organ_choice/proc/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/organ_entry/entry, customizer_type)
	switch(href_list["organ"])
		if("choose_acc")
			return
		if("next_acc")
			return
		if("prev_acc")
			return
		if("acc_color")
			var/index = text2num(href_list["color_index"])
			return



