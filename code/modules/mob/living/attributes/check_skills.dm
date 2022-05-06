/// Verb that shows a html panel with information about your attributes, skills and buffs affecting them
/mob/living/verb/check_skills()
	set category = "IC"
	set name = "Check Skills"
	set desc = "Check your skills and attributes."

	var/list/dat = list()
	var/even = FALSE
	var/background_cl

	// Display temporary buffs at the very top, but only if there's atleast 1
	if(length(attributes.buffs))
		dat += "<table width='100%'>"
		dat += "<center><h2>Buffs:</h2></center>"
		dat += "<tr>"
		dat += "<td width='25%'></td>" //Name
		dat += "<td width='30%'></td>" //Effects
		dat += "<td width='45%'></td>" //Description
		dat += "</tr>"

		for(var/buff_id in attributes.buffs)
			var/datum/attribute_buff/buff = attributes.buffs[buff_id]
			even = !even
			background_cl = even ? "#17191C" : "#23273C"

			dat += "<tr style='background-color: [background_cl]'>"
			dat += "<td>[buff.name]</td>" //Name

			//Effects:
			var/effect_string = ""
			var/first_effect = TRUE
			if(buff.attributes)
				for(var/attribute_type in buff.attributes)
					if(!first_effect)
						effect_string += "\n"
					var/datum/attribute/attribute = GLOB.attributes[attribute_type]
					var/attribute_value = buff.attributes[attribute_type]
					effect_string += "[attribute.name]: [attribute_value]"
					first_effect = FALSE
			if(buff.skills)
				for(var/skill_type in buff.skills)
					if(!first_effect)
						effect_string += "\n"
					var/datum/skill/skill = GLOB.skills[skill_type]
					var/skill_value = buff.skills[skill_type]
					effect_string += "[skill.name]: [skill_value]"
					first_effect = FALSE

			dat += "<td>[effect_string]</td>" //Description
			dat += "<td>[buff.desc]</td>" //Description
			dat += "</tr>"

		dat += "</table>"

	// Display attributes
	even = FALSE
	dat += "<table width='100%'>"
	dat += "<center><h2>Attributes:</h2></center>"
	dat += "<tr>"
	dat += "<td width='20%'></td>" //Name
	dat += "<td width='10%'></td>" //Value
	dat += "<td width='10%'></td>" //Common Modifier
	dat += "<td width='60%'></td>" //Description
	dat += "</tr>"

	for(var/attribute_type in GLOB.attributes)
		even = !even
		background_cl = even ? "#17191C" : "#23273C"
		var/datum/attribute/attribute = GLOB.attributes[attribute_type]
		var/amount = attributes.attributes_final[attribute_type]
		var/raw = attributes.attributes_raw[attribute_type]
		var/stat_color = "#FFFFFF"
		if(amount < raw)
			stat_color = "#FF0000"
		else if(amount > raw)
			stat_color = "#00FF00"
		dat += "<tr style='background-color: [background_cl]'>"
		dat += "<td>[attribute.name]</td>" //Name
		dat += "<td><b><center><font color='[stat_color]'>[amount]</font></center></b></td>" //Value
		dat += "<td><b><center><font color='[stat_color]'>[attribute.get_common_modifier_string(amount)]</font></center></b></td>" //Common Modifier
		dat += "<td>[attribute.desc]</td>" //Description
		dat += "</tr>"

	dat += "</table>"

	// Display skills
	even = FALSE
	dat += "<table width='100%'>"
	dat += "<center><h2>Skills:</h2></center>"
	dat += "<tr>"
	dat += "<td width='20%'></td>" //Name
	dat += "<td width='10%'></td>" //Value
	dat += "<td width='10%'></td>" //Capability description
	dat += "<td width='60%'></td>" //Description
	dat += "</tr>"
	for(var/skill_type in GLOB.skills)
		even = !even
		background_cl = even ? "#17191C" : "#23273C"
		var/datum/skill/skill = GLOB.skills[skill_type]
		var/value = attributes.skills_final[skill_type]
		dat += "<tr style='background-color: [background_cl]'>"
		dat += "<td>[skill.name]</td>" //Name
		dat += "<td><center>[value]</center></td>" //Value
		dat += "<td>[skill.get_capability_description(value)]</td>" //Capability description
		dat += "<td>[skill.desc]</td>" //Name
		dat += "</tr>"

	dat += "</table>"
	var/datum/browser/popup = new(usr, "attributes and skills", "Attributes & Skills", 550, 700)
	popup.set_content(dat.Join())
	popup.open()
