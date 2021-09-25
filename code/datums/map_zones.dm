/datum/map_zone
	var/name = "Map Zone"
	var/list/traits
	var/datum/overmap_object/related_overmap_object
	var/is_overmap_controllable = FALSE
	var/parallax_direction_override
	///Extensions for z levels as overmap objects
	var/list/all_extensions = list()
	/// Weather controller for this level
	var/datum/weather_controller/weather_controller
	/// Linked day and night controller, expect this to apply to all related_levels
	var/datum/day_night_controller/day_night_controller
	/// An override of rock colors on this level
	var/rock_color = COLOR_ASTEROID_ROCK
	/// An override of plant colors on this level
	var/plant_color = COLOR_DARK_MODERATE_LIME_GREEN
	/// An override of grass colors on this level
	var/grass_color = COLOR_DARK_MODERATE_LIME_GREEN
	/// An override of water colors on this level
	var/water_color = COLOR_WHITE
	/// List of all sub map zones this map zone contains
	var/list/sub_map_zones = list()

/datum/map_zone/New(passed_name, datum/overmap_object/passed_ov_obj)
	name = passed_name
	related_overmap_object = passed_ov_obj
	SSmapping.map_zones += src
	. = ..()

///If something requires a level to have a weather controller, use this
/datum/map_zone/proc/AssertWeatherController()
	if(!weather_controller)
		new /datum/weather_controller(list(src))

/datum/map_zone/proc/get_client_mobs()
	return get_alive_client_mobs() + get_dead_client_mobs()

/datum/map_zone/proc/get_alive_client_mobs()
	. = list()
	for(var/datum/sub_map_zone/subzone as anything in sub_map_zones)
		. += subzone.get_alive_client_mobs()

/datum/map_zone/proc/get_dead_client_mobs()
	. = list()
	for(var/datum/sub_map_zone/subzone as anything in sub_map_zones)
		. += subzone.get_dead_client_mobs()

/datum/map_zone/proc/is_in_bounds(atom/Atom)
	for(var/datum/sub_map_zone/subzone as anything in sub_map_zones)
		if(subzone.is_in_bounds(Atom))
			return TRUE
	return FALSE

/datum/map_zone/proc/add_sub_zone(datum/sub_map_zone/addsub)
	sub_map_zones += addsub
	addsub.parent_map_zone = src

/datum/sub_map_zone
	var/name = "Sub Map Zone"
	var/datum/map_zone/parent_map_zone
	/// Z level which contains this sub map zone
	var/datum/space_level/parent_level
	/// The low X boundary of the sub-zone
	var/low_x
	/// The low Y boundary of the sub-zone
	var/low_y
	/// The high X boundary of the sub-zone
	var/high_x
	/// The high Y boundary of the sub-zone
	var/high_y
	/// Distance in the X axis of the sub-zone
	var/x_distance
	/// Distance in the Y axis of the sub-zone
	var/y_distance
	/// Z value of the sub map zone, for easy access
	var/z_value
	/// Sub map zone that is above this one (multi-z)
	var/datum/sub_map_zone/up_linkage
	/// Sub map zone that is below this one (multi-z)
	var/datum/sub_map_zone/down_linkage
	/// Neighboring sub map zones, associative by direction
	var/list/neigbours = list()
	/// Traits of this sub map zone
	var/list/traits = list()
	var/linkage = SELFLOOPING

	/// Content variables:
	/// A list of all ore nodes on this level
	var/list/ore_nodes = list()

/datum/sub_map_zone/New(passed_name, list/passed_traits, datum/map_zone/passed_map, lx, ly, hx, hy, passed_z)
	name = passed_name
	traits = passed_traits.Copy()
	passed_map.add_sub_zone(src)
	reserve(lx, ly, hx, hy, passed_z)
	return ..()

/datum/sub_map_zone/proc/get_trait(trait)
	return traits[trait]

/datum/sub_map_zone/proc/reserve(x1, y1, x2, y2, passed_z)
	low_x = x1
	low_y = y1
	high_x = x2
	high_y = y2
	z_value = passed_z
	parent_level = SSmapping.z_list[z_value]
	parent_level.sub_map_zones += src
	x_distance = high_x - low_x
	y_distance = high_y - low_y

/datum/sub_map_zone/proc/is_in_bounds(atom/Atom)
	if(Atom.x >= low_x && Atom.x <= high_x && Atom.y >= low_y && Atom.y <= high_y && Atom.z == z_value)
		return TRUE
	return FALSE

/datum/sub_map_zone/proc/get_block()
	return block(locate(low_x,low_y,z_value), locate(high_x,high_y,z_value))

/datum/sub_map_zone/proc/get_center()
	return locate(round((low_x + high_x) / 2), round((low_y + high_y) / 2), z_value)

/datum/sub_map_zone/proc/get_random_position()
	return locate(rand(low_x, high_x), rand(low_y, high_y), z_value)

/datum/sub_map_zone/proc/get_below_turf(turf/Turf)
	if(!down_linkage)
		return
	var/abs_x = Turf.x - low_x
	var/abs_y = Turf.y - low_y
	return locate(down_linkage.low_x + abs_x, down_linkage.low_y + abs_y, down_linkage.z_value)

/datum/sub_map_zone/proc/get_above_turf(turf/Turf)
	if(!up_linkage)
		return
	var/abs_x = Turf.x - low_x
	var/abs_y = Turf.y - low_y
	return locate(up_linkage.low_x + abs_x, up_linkage.low_y + abs_y, up_linkage.z_value)

/datum/sub_map_zone/proc/get_client_mobs()
	return get_alive_client_mobs() + get_dead_client_mobs()

/datum/sub_map_zone/proc/get_alive_client_mobs()
	. = list()
	for(var/mob/Mob as anything in SSmobs.clients_by_zlevel[z_value])
		if(is_in_bounds(Mob))
			. += Mob

/datum/sub_map_zone/proc/get_dead_client_mobs()
	. = list()
	for(var/mob/Mob as anything in SSmobs.dead_players_by_zlevel[z_value])
		if(is_in_bounds(Mob))
			. += Mob

/// Gets the sub zone that contains the passed atom
/datum/controller/subsystem/mapping/proc/get_sub_zone(atom/Atom)
	var/datum/space_level/level = z_list[Atom.z]
	var/datum/sub_map_zone/sub_map
	for(var/datum/sub_map_zone/iterated_zone as anything in level.sub_map_zones)
		if(iterated_zone.is_in_bounds(Atom))
			sub_map = iterated_zone
			break
	return sub_map

/// A helper pretty much
/datum/controller/subsystem/mapping/proc/get_map_zone(atom/Atom)
	var/datum/sub_map_zone/sub_map = get_sub_zone(Atom)
	if(sub_map)
		return sub_map.parent_map_zone
