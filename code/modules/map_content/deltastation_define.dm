/datum/map_config/deltastation
	map_name = "Delta Station"

	space_ruin_levels = 3

	minetype = "lavaland"

	allow_custom_shuttles = TRUE

	job_changes = list("cook" = list("additional_cqc_areas" = list("/area/service/bar/atrium")))

	station_maps = list(/datum/station_map/deltastation)

/datum/station_map/deltastation
	map_name = "Delta Station"
	map_path = "map_files/Deltastation"
	map_file = "DeltaStation2.dmm"
	traits = null
	shuttles = list(
		"cargo" = "cargo_delta",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_delta",
		"emergency" = "emergency_delta")
