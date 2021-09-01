/datum/map_config/multizdebug
	map_name = "MultiZ Debug"

	station_maps = list(/datum/station_map/multizdebug)

/datum/station_map/multizdebug
	map_name = "MultiZ Debug"
	map_path = "map_files/debug"
	map_file = "multiz.dmm"
	traits = list(list("Up" = 1),
				list("Up" = 1,
					"Down" = -1,
					"Baseturf" = "/turf/open/openspace"),
				list("Down" = -1,
					"Baseturf" = "/turf/open/openspace")
		)
