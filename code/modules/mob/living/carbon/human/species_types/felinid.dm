//Subtype of human
/datum/species/human/felinid
	name = "Felinid"
	id = "felinid"
	say_mod = "meows"
	limbs_id = "human"

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/felinid
	disliked_food = GROSS | RAW | CLOTH
	var/original_felinid = TRUE //set to false for felinids created by mass-purrbation
	payday_modifier = 0.75
	ass_image = 'icons/ass/asscat.png'
	family_heirlooms = list(/obj/item/toy/cattoy)

/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		return
	if(!isfelinid(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	return

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	return
