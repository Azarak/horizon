/datum/map_config/metastation
	map_name = "Meta Station"

	space_ruin_levels = 3

	minetype = "lavaland"

	allow_custom_shuttles = TRUE

	job_changes = list()
	station_maps = list(/datum/station_map/meta)

/datum/station_map/meta
	map_name = "Meta Station"
	map_path = "map_files/MetaStation"
	map_file = "MetaStation.dmm"
	traits = null
	shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")
