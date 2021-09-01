/datum/map_config/tradership
	map_name = "FTV Bearcat"
	space_ruin_levels = 3

	minetype = "none"

	global_trading_hub_type = /datum/trade_hub/worldwide/bearcat

	allow_custom_shuttles = TRUE

	amount_of_planets_spawned = 2
	station_maps = list(/datum/station_map/tradership)

/datum/map_config/tradership/get_map_info()
	return "You're aboard the <b>[map_name],</b> a survey and mercantile vessel affiliated with the Free Trade Union. \
	No meaningful authorities can claim the planets and resources in this uncharted sector, so their exploitation is entirely up to you - mine, poach and deforest all you want."

/datum/station_map/tradership
	map_name = "FTV Bearcat"
	map_path = "map_files/tradership"
	map_file = list("tradership1.dmm",
					"tradership2.dmm",
					"tradership3.dmm",
					"tradership4.dmm")

	traits = list(list("Up" = 1),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace"),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace"),
					list("Down" = -1,
						"Baseturf" = "/turf/open/openspace"))
	shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")

	overmap_object_type = /datum/overmap_object/shuttle/ship/bearcat
	job_listing = /datum/job_listing/tradership
