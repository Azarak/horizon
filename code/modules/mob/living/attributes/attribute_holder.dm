/// Holder datum for attributes, skill and modifiers for them. Those get attached to mob/living
/datum/attribute_holder
	/// Mob owner of this attribute holder.
	var/mob/living/owner
	/// Assoc list of attribute types to raw values
	var/list/attributes_raw = list()
	/// Assoc list of skill types to raw values
	var/list/skills_raw = list()
	/// Assoc list of attribute types to final values (with buffs)
	var/list/attributes_final = list()
	/// Assoc list of skill types to final values (with buffs)
	var/list/skills_final = list()
	/// Assoc list, from buff ID to instances of /datum/attribute_buff
	var/list/buffs = list()

/datum/attribute_holder/New(mob/living/attached_owner)
	owner = attached_owner

	// Build raw attributes
	for(var/attribute_type in GLOB.attributes)
		attributes_raw[attribute_type] = ATTRIBUTE_BASE

	// Build raw skills
	for(var/skill_type in GLOB.skills)
		skills_raw[skill_type] = SKILL_BASE

	update_attributes()

/// Updates final values of the attributes and skills.
/datum/attribute_holder/proc/update_attributes()
	attributes_final = attributes_raw.Copy()
	skills_final = skills_raw.Copy()

	// Handle buffs
	for(var/buff_id in buffs)
		var/datum/attribute_buff/buff = buffs[buff_id]
		if(buff.attributes)
			for(var/attribute in buff.attributes)
				attributes_final[attribute] += buff.attributes[attribute]
		if(buff.skills)
			for(var/skill in buff.skills)
				skills_final[skill] += buff.skills[skill]

	// Handle affinities
	for(var/skill_type in GLOB.skills)
		var/datum/skill/skill = GLOB.skills[skill_type]
		if(!skill.affinities)
			continue
		for(var/affinity_type in skill.affinities)
			var/attribute_value = attributes_final[affinity_type] - ATTRIBUTE_BASE
			var/affinity_modifier = skill.affinities[affinity_type]
			var/modifier_value = FLOOR(attribute_value * affinity_modifier, 1)
			skills_final[skill_type] += modifier_value

/// Instantiates a buff from a type and adds id to the holder.
/datum/attribute_holder/proc/add_buff(buff_id, buff_type)
	attach_buff(buff_id, new buff_type())

/// Adds an already instantiated buff to the holder. Useful if you need to customise a buff before adding it.
/datum/attribute_holder/proc/add_buff_instance(buff_id, datum/attribute_buff/buff_instance)
	attach_buff(buff_id, buff_instance)

/// Internal proc to actually add a buff
/datum/attribute_holder/proc/attach_buff(buff_id, datum/attribute_buff/buff_instance)
	buffs[buff_id] = buff_instance
	if(buff_instance.gain_message)
		if(buff_instance.positive)
			to_chat(owner, SPAN_NOTICE(buff_instance.gain_message))
		else
			to_chat(owner, SPAN_WARNING(buff_instance.gain_message))
	update_attributes()

/// Removes a buff of a given ID
/datum/attribute_holder/proc/remove_buff(buff_id)
	var/datum/attribute_buff/buff_instance = buffs[buff_id]
	if(buff_instance.lose_message)
		to_chat(owner, SPAN_NOTICE(buff_instance.lose_message))
	buffs -= buff_id
	update_attributes()

/// Whether the holder has a buff from a given ID
/datum/attribute_holder/proc/has_buff_from(buff_id)
	if(buffs[buff_id])
		return TRUE
	return FALSE

/// Returns a buff from a given ID, possibly useful to modify existing buffs, just remember to call update_attributes() afterwards.
/datum/attribute_holder/proc/get_buff_from(buff_id)
	return buffs[buff_id]

/// Add or subtract attributes to the holder from a list
/datum/attribute_holder/proc/add_attributes(list/attributes_to_add, subtract = FALSE)
	for(var/attribute in attributes_to_add)
		if(subtract)
			attributes_raw[attribute] -= attributes_to_add[attribute]
		else
			attributes_raw[attribute] += attributes_to_add[attribute]
	update_attributes()

/// Adds or subtract skills to the holder from a list
/datum/attribute_holder/proc/add_skills(list/skills_to_add, subtract = FALSE)
	for(var/skill in skills_to_add)
		if(subtract)
			skills_raw[skill] -= skills_to_add[skill]
		else
			skills_raw[skill] += skills_to_add[skill]
	update_attributes()

/// Adds values from an attribute sheet to this holder
/datum/attribute_holder/proc/add_attribute_sheet(sheet_type)
	var/datum/attribute_sheet/sheet = new sheet_type()
	if(sheet.attributes)
		add_attributes(sheet.attributes)
	if(sheet.skills)
		add_skills(sheet.skills)

/// Removes values from an attribute sheet from this holder
/datum/attribute_holder/proc/remove_attribute_sheet(sheet_type)
	var/datum/attribute_sheet/sheet = new sheet_type()
	if(sheet.attributes)
		add_attributes(sheet.attributes, subtract = TRUE)
	if(sheet.skills)
		add_skills(sheet.skills, subtract = TRUE)
