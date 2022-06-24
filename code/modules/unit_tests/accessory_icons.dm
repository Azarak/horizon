/// This unit test iterates over all sprite accessories and checks if they all have their icon states.
/datum/unit_test/accessory_icons/Run()
	for(var/accessory_type in GLOB.sprite_accessories)
		var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
		if(!accessory.icon_state)
			continue
		var/list/icon_states_available = icon_states(accessory.icon)
		var/list/states_to_check = accessory.unit_testing_possible_icon_states()
		for(var/state in states_to_check)
			if(!(state in icon_states_available))
				Fail("Accessory [accessory_type] has missing icon_state: [state]")
