/datum/slapcraft_recipe/test
	name = "Test"
	steps = list(
		/datum/slapcraft_step/one,
		/datum/slapcraft_step/two,
		/datum/slapcraft_step/three
		)
	result_type = /obj/item/screwdriver

/datum/slapcraft_step/one
	desc = "Acquire a %LINK%holy screwdriver%ENDLINK%."
	finished_desc = "A screwdriver has been added."
	todo_desc = "You could add a screwdriver..."
	finish_msg = "You add a screwdriver to the assembly."
	recipe_link = /datum/slapcraft_recipe/test
	item_types = list(/obj/item/screwdriver)

/datum/slapcraft_step/two
	finished_desc = "A screwdriver has been added."
	todo_desc = "You could add a screwdriver..."
	finish_msg = "You add a screwdriver to the assembly."
	item_types = list(/obj/item/screwdriver)

/datum/slapcraft_step/three
	finished_desc = "A screwdriver has been added."
	todo_desc = "You could add a screwdriver..."
	finish_msg = "You add a screwdriver to the assembly."
	item_types = list(/obj/item/screwdriver)

/datum/slapcraft_recipe/test/two
	name = "Test Two"
	result_type = /obj/item/wirecutters
