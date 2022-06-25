/datum/organ_customizer/snout
	abstract_type = /datum/organ_customizer/snout
	name = "Snout"

/datum/organ_choice/snout
	abstract_type = /datum/organ_choice/snout
	name = "Snout"
	organ_type = /obj/item/organ/snout
	organ_slot = ORGAN_SLOT_SNOUT

/datum/organ_customizer/snout/vulpkanin
	organ_choices = list(/datum/organ_choice/snout/vulpkanin)
	default_choice = /datum/organ_choice/snout/vulpkanin

/datum/organ_choice/snout/vulpkanin
	name = "Vulpkanin Snout"
	sprite_accessories = list(
		/datum/sprite_accessory/snout/lcanid,
		/datum/sprite_accessory/snout/lcanidalt,
		/datum/sprite_accessory/snout/lcanidstriped,
		/datum/sprite_accessory/snout/lcanidstripedalt,
		)
	default_accessory = /datum/sprite_accessory/snout/lcanid
