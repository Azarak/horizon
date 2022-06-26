/obj/item/organ/hair
	abstract_type = /obj/item/organ/hair
	desc = "A severed patch of skin with hair."
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_HEAD
	var/hair_color = "#FFFFFF"
	var/natural_gradient = /datum/hair_gradient/none
	var/natural_color = "#FFFFFF"
	var/hair_dye_gradient = /datum/hair_gradient/none
	var/hair_dye_color = "#FFFFFF"

/obj/item/organ/hair/head
	name = "hair"
	slot = ORGAN_SLOT_HAIR

/obj/item/organ/hair/facial
	name = "facial hair"
	slot = ORGAN_SLOT_FACIAL_HAIR
