/proc/random_unique_vox_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(vox_name())

		if(!findname(.))
			break

/proc/assemble_body_markings_from_set(datum/body_marking_set/BMS, list/features, datum/species/pref_species)
	var/list/body_markings = list()
	for(var/set_name in BMS.body_marking_list)
		var/datum/body_marking/BM = GLOB.body_markings[set_name]
		for(var/zone in GLOB.body_markings_per_limb)
			var/list/marking_list = GLOB.body_markings_per_limb[zone]
			if(set_name in marking_list)
				if(!body_markings[zone])
					body_markings[zone] = list()
				body_markings[zone][set_name] = BM.get_default_color(features, pref_species)
	return body_markings

/proc/marking_list_of_zone_for_species(zone, datum/species/species, mismatched = FALSE)
	if(mismatched)
		return GLOB.body_markings_per_limb[zone].Copy()
	var/list/compiled_list = list()
	var/list/global_list_cache = GLOB.body_markings_per_limb[zone]
	var/list/global_lookup_cache = GLOB.body_markings
	for(var/name in global_list_cache)
		var/datum/body_marking/body_marking = global_lookup_cache[name]
		if(!(body_marking.bodytypes & species.bodytype) || (body_marking.recommended_species && !(species.id in body_marking.recommended_species)))
			continue
		compiled_list[name] = body_marking
	return compiled_list

/proc/marking_sets_for_species(datum/species/species, mismatched = FALSE)
	if(mismatched)
		return GLOB.body_marking_sets.Copy()
	var/list/compiled_list = list()
	var/list/global_list_cache = GLOB.body_marking_sets
	for(var/name in global_list_cache)
		var/datum/body_marking_set/marking_set = global_list_cache[name]
		if(!(marking_set.bodytypes & species.bodytype) || (marking_set.recommended_species && !(species.id in marking_set.recommended_species)))
			continue
		compiled_list[name] = marking_set
	return compiled_list
