/datum/organ_customizer/tail
	name = "Tail"
	abstract_type = /datum/organ_customizer/tail

/datum/organ_choice/tail
	name = "Tail"
	organ_type = /obj/item/organ/tail
	organ_slot = ORGAN_SLOT_TAIL
	abstract_type = /datum/organ_choice/tail

/datum/organ_customizer/tail/vulpkanin
	organ_choices = list(/datum/organ_choice/tail/vulpkanin)
	default_choice = /datum/organ_choice/tail/vulpkanin

/datum/organ_choice/tail/vulpkanin
	name = "Vulpkanin Tail"
	organ_type = /obj/item/organ/tail/vulpkanin
	sprite_accessories = list(/datum/sprite_accessory/tail/fox)
	default_accessory = /datum/sprite_accessory/tail/fox
