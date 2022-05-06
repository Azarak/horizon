/// Associative list of attribute types to singletons
GLOBAL_LIST_INIT(attributes, build_attribute_list())
/// Associative list of skill types to singletons
GLOBAL_LIST_INIT(skills, build_skill_list())

/proc/build_attribute_list()
	var/list/attribute_list = list()
	for(var/type in subtypesof(/datum/attribute))
		attribute_list[type] = new type()
	return attribute_list

/proc/build_skill_list()
	var/list/skill_list = list()
	for(var/type in subtypesof(/datum/skill))
		skill_list[type] = new type()
	return skill_list
