/datum/map_config/tramstation
	map_name = "Tramstation"

	space_ruin_levels = 3

	minetype = "lavaland"

	job_changes = list("cook" = list("additional_cqc_areas" = list("/area/service/kitchen/diner")),
						"captain" = list("special_charter" = "asteroid"))

	station_maps = list(/datum/station_map/tramstation)

/datum/station_map/tramstation
	map_name = "Tramstation"
	map_path = "map_files/tramstation"
	map_file = "tramstation.dmm"
	traits = list(list("Up" = 1,
						"Baseturf" = "/turf/open/floor/plating/asteroid/airless"),
						list("Down" = -1,
						"Baseturf" = "/turf/open/openspace"))
	shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_tram",
		"emergency" = "emergency_tram")
