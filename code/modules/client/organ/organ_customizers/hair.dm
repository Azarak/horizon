/datum/organ_customizer/hair
	abstract_type = /datum/organ_customizer/hair

/datum/organ_choice/hair
	abstract_type = /datum/organ_choice/hair
	allows_accessory_color_customization = FALSE //Customized through hair color

/datum/organ_entry/hair
	var/hair_color
	var/natural_gradient = FALSE
	var/natural_color
	var/dye_gradient = FALSE
	var/dye_color

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
