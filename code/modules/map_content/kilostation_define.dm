/datum/map_config/kilostation
	map_name = "Kilo Station"

	space_ruin_levels = 3

	minetype = "lavaland"

	allow_custom_shuttles = TRUE

	job_changes = list("cook" = list("additional_cqc_areas" = list("/area/service/bar/atrium")),
						"captain" = list("special_charter" = "asteroid"))

	station_maps = list(/datum/station_map/kilostation)

/datum/station_map/kilostation
	map_name = "Kilo Station"
	map_path = "map_files/KiloStation"
	map_file = "KiloStation.dmm"
	traits = null
	shuttles = list(
		"cargo" = "cargo_kilo",
		"ferry" = "ferry_kilo",
		"whiteship" = "whiteship_kilo",
		"emergency" = "emergency_kilo")
