/datum/station_map
	var/map_name = "Station"
	var/map_desc = "A station."
	var/map_path
	var/map_file
	var/job_listing = /datum/job_listing/station
	var/traits = null
	var/list/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")
	/// The type of the overmap object the station will act as on the overmap
	var/overmap_object_type = /datum/overmap_object/shuttle/station
	/// The weather controller the station levels will have
	var/weather_controller_type = /datum/weather_controller
	/// Type of our day and night controller, can be left blank for none
	var/day_night_controller_type
	/// Type of the atmosphere that will be loaded on station
	var/atmosphere_type
	/// Possible rock colors of the loaded map
	var/list/rock_color
	/// Possible plant colors of the loaded map
	var/list/plant_color
	/// Possible grass colors of the loaded map
	var/list/grass_color
	/// Possible water colors of the loaded map
	var/list/water_color
	var/ore_node_seeder_type

/datum/station_map/New()
	//Make sure that all levels in station have the default station traits, unless they're overriden
	if(islist(traits))
		for(var/level in traits)
			var/list/level_traits = level
			var/base_traits_station = ZTRAITS_STATION
			for(var/trait_to_validate in base_traits_station)
				if(!level_traits[trait_to_validate])
					level_traits[trait_to_validate] = base_traits_station[trait_to_validate]
	return ..()

/datum/station_map/proc/LoadStationMap()
	//Create station jobs
	if(job_listing)
		new job_listing(map_name, map_desc)

	var/loaded_overmap_object = new overmap_object_type(SSovermap.main_system, rand(3,10), rand(3,10))
	if(!SSmapping.station_overmap_object)
		SSmapping.station_overmap_object = loaded_overmap_object
	if(!SSmapping.shuttles_to_load)
		SSmapping.shuttles_to_load = shuttles.Copy()
	var/picked_rock_color = CHECK_AND_PICK_OR_NULL(rock_color)
	var/picked_plant_color = CHECK_AND_PICK_OR_NULL(plant_color)
	var/picked_grass_color = CHECK_AND_PICK_OR_NULL(grass_color)
	var/picked_water_color = CHECK_AND_PICK_OR_NULL(water_color)
	SSmapping.LoadGroup(null,
			map_name,
			map_path,
			map_file,
			traits,
			ZTRAITS_STATION,
			ov_obj = loaded_overmap_object,
			weather_controller_type = weather_controller_type,
			atmosphere_type = atmosphere_type,
			day_night_controller_type = day_night_controller_type,
			rock_color = picked_rock_color,
			plant_color = picked_plant_color,
			grass_color = picked_grass_color,
			water_color = picked_water_color,
			ore_node_seeder_type = ore_node_seeder_type)
