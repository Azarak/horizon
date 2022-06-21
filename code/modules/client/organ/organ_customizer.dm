/datum/organ_customizer
	abstract_type = /datum/organ_customizer
	/// User facing name of the organ customization.
	var/name = "Organ"
	/// List of all /datum/organ_choice's that this customizer can pick from.
	var/list/organ_choices
	/// The default choice from among `organ_choices`.
	var/default_choice
	/// Whether the user needs to have an entry for this customizer. (Otherwise the organ is optional)
	var/required = TRUE

/datum/organ_customizer/New()
	. = ..()
	if(!length(organ_choices))
		CRASH("Organ customizer [type] lacks organ choices")
	if(!default_choice)
		default_choice = organ_choices[1]

/datum/organ_customizer/proc/make_default_organ_entry(datum/preferences/prefs)
	var/datum/organ_choice/default_organ = ORGAN_CHOICE(default_choice)
	return default_organ.make_default_organ_entry(prefs, type)
