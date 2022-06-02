/datum/slapcraft_recipe/flamethrower
	name = "flamethrower"
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/flamethrower_welder,
		/datum/slapcraft_step/flamethrower_igniter,
		/datum/slapcraft_step/tool/screwdriver/flamethrower,
		/datum/slapcraft_step/stack/flamethrower_rod
		)
	result_type = /obj/item/flamethrower

/datum/slapcraft_step/flamethrower_welder
	desc = "Start with normal sized welding tool."
	finished_desc = "A welding tool has been added."
	item_types = list(/obj/item/weldingtool)
	blacklist_item_types = list(/obj/item/weldingtool/mini, /obj/item/weldingtool/largetank)
	insert_item_into_result = TRUE

/datum/slapcraft_step/flamethrower_igniter
	desc = "Attach an igniter to the welder."
	finished_desc = "An igniter has been added to welder."
	todo_desc = "You could add an igniter to the welder..."
	finish_msg = "You attach the igniter to the welder."
	item_types = list(/obj/item/assembly/igniter)
	insert_item_into_result = TRUE

/datum/slapcraft_step/tool/screwdriver/flamethrower
	desc = "Secure the igniter and the welding tool with a screwdriver."
	finished_desc = "The igniter and the welding tool were secured."
	todo_desc = "You could secure this with a screwdriver..."
	finish_msg = "You secure the components with a screwdriver."

/datum/slapcraft_step/stack/flamethrower_rod
	desc = "Finish the flamethrower by inserting a rod."
	todo_desc = "You could finish it by inserting a rod..."
	finish_msg = "You insert a rod to the assembly."
	item_types = list(/obj/item/stack/rods)
	amount = 1
