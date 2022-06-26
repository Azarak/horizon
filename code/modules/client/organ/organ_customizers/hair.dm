/datum/organ_customizer/hair
	abstract_type = /datum/organ_customizer/hair

/datum/organ_choice/hair
	abstract_type = /datum/organ_choice/hair
	organ_entry_type = /datum/organ_entry/hair
	organ_dna_type = /datum/organ_dna/hair
	allows_accessory_color_customization = FALSE //Customized through hair color
	var/allows_natural_gradient = TRUE
	var/allows_dye_gradient = TRUE

/datum/organ_choice/hair/customize_organ(obj/item/organ/organ, datum/organ_entry/entry)
	..()
	var/obj/item/organ/hair/hair_organ = organ
	var/datum/organ_entry/hair/hair_entry = entry
	if(allows_dye_gradient)
		hair_organ.hair_dye_gradient = hair_entry.dye_gradient
		hair_organ.hair_dye_color = hair_entry.dye_color

/datum/organ_choice/hair/imprint_organ_dna(datum/organ_dna/organ_dna, datum/organ_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/hair/hair_dna = organ_dna
	var/datum/organ_entry/hair/hair_entry = entry
	hair_dna.hair_color = hair_entry.hair_color
	if(allows_natural_gradient)
		hair_dna.natural_gradient  = hair_entry.natural_gradient
		hair_dna.natural_color = hair_entry.natural_color

/datum/organ_choice/hair/validate_entry(datum/preferences/prefs, datum/organ_entry/entry)
	..()
	var/datum/organ_entry/hair/hair_entry = entry
	hair_entry.hair_color = sanitize_hexcolor(hair_entry.hair_color, 6, TRUE, initial(hair_entry.hair_color))
	hair_entry.natural_color = sanitize_hexcolor(hair_entry.natural_color, 6, TRUE, initial(hair_entry.natural_color))
	hair_entry.dye_color = sanitize_hexcolor(hair_entry.dye_color, 6, TRUE, initial(hair_entry.dye_color))

/datum/organ_choice/hair/generate_pref_choices(list/dat, datum/preferences/prefs, datum/organ_entry/entry, customizer_type)
	..()
	var/datum/organ_entry/hair/hair_entry = entry
	dat += "<br>Hair Color: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=hair_color''><span class='color_holder_box' style='background-color:[hair_entry.hair_color]'></span></a>"
	if(allows_natural_gradient)
		var/datum/hair_gradient/gradient = HAIR_GRADIENT(hair_entry.natural_gradient)
		dat += "<br>Natural Gradient: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=natural_gradient'>[gradient.name]</a>"
		if(hair_entry.natural_gradient != /datum/hair_gradient/none)
			dat += "<br>Natural Color: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=natural_gradient_color''><span class='color_holder_box' style='background-color:[hair_entry.natural_color]'></span></a>"
	if(allows_dye_gradient)
		var/datum/hair_gradient/gradient = HAIR_GRADIENT(hair_entry.dye_gradient)
		dat += "<br>Dye Gradient: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=dye_gradient'>[gradient.name]</a>"
		if(hair_entry.dye_gradient != /datum/hair_gradient/none)
			dat += "<br>Dye Color: <a href='?_src_=prefs;task=change_organ;customizer=[customizer_type];organ=dye_gradient_color''><span class='color_holder_box' style='background-color:[hair_entry.dye_color]'></span></a>"

/datum/organ_choice/hair/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/organ_entry/entry, customizer_type)
	..()
	var/datum/organ_entry/hair/hair_entry = entry
	switch(href_list["organ"])
		if("hair_color")
			var/new_color = input(user, "Choose your hair color:", "Character Preference", hair_entry.hair_color) as color|null
			if(!new_color)
				return
			hair_entry.hair_color = sanitize_hexcolor(new_color, 6, TRUE)
		if("natural_gradient")
			if(!allows_natural_gradient)
				return
			var/list/choice_list = hair_gradient_name_to_type_list()
			var/chosen_input = input(user, "Choose your natural gradient:", "Character Preference")  as null|anything in choice_list
			if(!chosen_input)
				return
			hair_entry.natural_gradient = choice_list[chosen_input]
		if("natural_gradient_color")
			if(!allows_natural_gradient)
				return
			var/new_color = input(user, "Choose your natural gradient color:", "Character Preference", hair_entry.natural_color) as color|null
			if(!new_color)
				return
			hair_entry.natural_color = sanitize_hexcolor(new_color, 6, TRUE)
		if("dye_gradient")
			if(!allows_dye_gradient)
				return
			var/list/choice_list = hair_gradient_name_to_type_list()
			var/chosen_input = input(user, "Choose your dye gradient:", "Character Preference")  as null|anything in choice_list
			if(!chosen_input)
				return
			hair_entry.dye_gradient = choice_list[chosen_input]
		if("dye_gradient_color")
			if(!allows_dye_gradient)
				return
			var/new_color = input(user, "Choose your dye gradient color:", "Character Preference", hair_entry.dye_color) as color|null
			if(!new_color)
				return
			hair_entry.dye_color = sanitize_hexcolor(new_color, 6, TRUE)

/datum/organ_entry/hair
	var/hair_color = "#FFFFFF"
	var/natural_gradient = /datum/hair_gradient/none
	var/natural_color = "#FFFFFF"
	var/dye_gradient = /datum/hair_gradient/none
	var/dye_color = "#FFFFFF"

/datum/organ_customizer/hair/head
	abstract_type = /datum/organ_customizer/hair/head
	name = "Hair"

/datum/organ_choice/hair/head
	abstract_type = /datum/organ_choice/hair/head
	name = "Hair"
	organ_type = /obj/item/organ/hair/head
	organ_slot = ORGAN_SLOT_HAIR

/datum/organ_customizer/hair/facial
	abstract_type = /datum/organ_customizer/hair/facial
	name = "Facial Hair"

/datum/organ_choice/hair/facial
	abstract_type = /datum/organ_choice/hair/facial
	name = "Facial Hair"
	organ_type = /obj/item/organ/hair/facial
	organ_slot = ORGAN_SLOT_FACIAL_HAIR

/datum/organ_customizer/hair/head/humanoid
	organ_choices = list(/datum/organ_choice/hair/head/humanoid)

/datum/organ_choice/hair/head/humanoid

/datum/organ_customizer/hair/facial/humanoid
	organ_choices = list(/datum/organ_choice/hair/facial/humanoid)

/datum/organ_choice/hair/facial/humanoid
