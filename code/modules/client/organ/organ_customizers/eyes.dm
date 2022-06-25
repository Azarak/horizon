/datum/organ_customizer/eyes
	abstract_type = /datum/organ_customizer/eyes
	name = "Eyes"

/datum/organ_choice/eyes
	abstract_type = /datum/organ_choice/eyes
	name = "Eyes"
	organ_type = /obj/item/organ/eyes
	organ_slot = ORGAN_SLOT_EYES
	organ_entry_type = /datum/organ_entry/eyes
	allows_accessory_color_customization = FALSE //Customized through eye color

/datum/organ_entry/eyes
	var/eye_color
	var/heterochromia = FALSE
	var/second_color

/datum/organ_customizer/eyes/humanoid
	organ_choices = list(/datum/organ_choice/eyes/humanoid)
	default_choice = /datum/organ_choice/eyes/humanoid

/datum/organ_choice/eyes/humanoid
