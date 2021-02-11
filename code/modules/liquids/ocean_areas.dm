/area/ocean
	name = "Ocean"
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA | NO_ALERTS
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/ocean/generated
	map_generator = /datum/map_generator/ocean_generator

/area/ruin/ocean
	has_gravity = TRUE
	area_flags = UNIQUE_AREA

/area/ruin/ocean/listening_outpost

/area/ruin/ocean/bunker
