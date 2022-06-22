/datum/organ_customizer
	abstract_type = /datum/organ_customizer
	/// User facing name of the organ customization.
	var/name = "Organ"
	/// List of all /datum/organ_choice's that this customizer can pick from.
	var/list/organ_choices
	/// The default choice from among `organ_choices`.
	var/default_choice

/datum/organ_customizer/New()
	. = ..()
	if(!length(organ_choices))
		CRASH("Organ customizer [type] lacks organ choices")
	if(!default_choice)
		default_choice = organ_choices[1]

/datum/organ_customizer/proc/make_default_organ_entry(datum/preferences/prefs)
	return get_organ_entry(prefs, default_choice)

/datum/organ_customizer/proc/create_organ_entry(datum/preferences/prefs, organ_choice_type)
	return get_organ_entry(prefs, organ_choice_type)

/datum/organ_customizer/proc/get_organ_entry(datum/preferences/prefs, organ_choice_type)
	var/datum/organ_choice/chosen_organ = ORGAN_CHOICE(organ_choice_type)
	return chosen_organ.make_default_organ_entry(prefs, type)
