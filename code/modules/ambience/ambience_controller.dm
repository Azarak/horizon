/datum/ambience_controller
	/// Client we play things to and respects prefs of
	var/client/client
	/// Next time we shall play area ambience at
	var/next_area_ambience = 0
	/// When do we call the updates for area and ship ambience handling
	var/next_area_handling = 0
	/// Whether we wzhzhzhzhhzhzh
	var/playing_ship_ambience = FALSE
	/// Whether we are playing area ambience
	var/playing_area_ambience = FALSE

	/// Preference variables
	var/pref_ship_ambience = TRUE
	var/pref_area_ambience = TRUE
	var/pref_object_ambience = TRUE

	var/mob_x
	var/mob_y
	var/mob_z

	/// Time until the next object sweep for scheduling played object ambience
	var/next_object_sweep = 0
	/// Fast ref to the list with ambient datums
	var/static/list/ambient_sounds
	/// A list of lists of cooldowns per emitters to our ambient sounds
	var/list/ambience_cooldowns[TOTAL_AMBIENT_SOUNDS]
	/// Queued object ambiences that we process
	var/list/queued_object_ambience = list()
	/// List of free channels for playing ambient sounds
	var/list/free_channels = list()
	/// List of sounds we're currently managing. They will take up channels and free them when they end
	var/list/managed_sounds = list()

/datum/ambience_controller/New(client/applied_client)
	. = ..()
	for(var/i in CHANNEL_AMBIENT_SOUNDS_START to CHANNEL_AMBIENT_SOUNDS_END)
		free_channels+= i
	if(!ambient_sounds)
		ambient_sounds = SSambience.ambient_sounds
	client = applied_client
	SSambience.ambience_controller_list += src
	client_pref_update()

/datum/ambience_controller/Destroy()
	client = null
	SSambience.ambience_controller_list -= src
	return ..()

/datum/ambience_controller/process()
	var/mob/client_mob = client.mob
	// Dont try and play ambience for new players
	if(isnewplayer(client_mob))
		return
	if(next_object_sweep <= world.time)
		handle_object_sweep(client_mob)
	if(next_area_handling <= world.time)
		next_area_handling = world.time + 2 SECONDS
		handle_area_ambience(client_mob)
		handle_ship_ambience(client_mob)
	handle_managed_ambience(client_mob)
	handle_object_ambience(client_mob)

/datum/ambience_controller/proc/handle_area_ambience(mob/client_mob)
	if(!pref_area_ambience)
		if(playing_area_ambience)
			client_mob.stop_sound_channel(CHANNEL_AMBIENCE)
			playing_area_ambience = FALSE
		return
	if(world.time < next_area_ambience)
		return
	playing_area_ambience = TRUE
	var/area/current_area = get_area(client_mob)
	var/sound = pick(current_area.ambientsounds)

	SEND_SOUND(client, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))

	next_area_ambience = world.time + rand(current_area.min_ambience_cooldown, current_area.max_ambience_cooldown)

/datum/ambience_controller/proc/handle_ship_ambience(mob/client_mob)
	var/area/current_area = get_area(client_mob)
	var/should_play_ship_ambience = (pref_ship_ambience && !current_area.outdoors)
	if(playing_ship_ambience == should_play_ship_ambience)
		return
	playing_ship_ambience = should_play_ship_ambience
	if(playing_ship_ambience)
		SEND_SOUND(client, sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = 0, volume = 15, channel = CHANNEL_BUZZ))
	else
		client_mob.stop_sound_channel(CHANNEL_BUZZ)

/// When our client pref gets updated.
/datum/ambience_controller/proc/client_pref_update()
	var/datum/preferences/prefs = client.prefs
	var/mob/client_mob = client.mob

	pref_ship_ambience = (prefs.toggles & SOUND_SHIP_AMBIENCE)
	pref_area_ambience = (prefs.toggles & SOUND_AMBIENCE)
	pref_object_ambience = TRUE

	if(isnewplayer(client_mob))
		return

	handle_area_ambience(client_mob)
	handle_ship_ambience(client_mob)

// This proc goes hard feel free to copy
// This proc is very complex and does 3 important tasks:
// 1. Goes over the cooldown list for ambience emitters and clears any ones that have passed, unsetting empty lists too
// 2. Sweeps a range of nearby turfs to get new ambiences
// 3. Iterates over all new ambiences and checks if it can be played, setting the appropriate cooldowns (The cooldown setting is rather complex)
/datum/ambience_controller/proc/handle_object_sweep(mob/client_mob)
	var/world_time = world.time //faster access I think????
	next_object_sweep = world_time + AMBIENCE_SWEEP_TIME
	if(!pref_object_ambience)
		return

	///Clear existing cooldowns
	var/i = 0
	for(var/list/cooldown_list as anything in ambience_cooldowns)
		i++
		if(!cooldown_list)
			continue
		for(var/cooldown in cooldown_list)
			if(cooldown <= world_time)
				cooldown_list -= cooldown
		if(!cooldown_list.len)
			ambience_cooldowns[i] = null

	///Do a sweep
	var/turf/mob_turf = get_turf(client_mob)
	if(!mob_turf)
		return
	var/list/found_ambience = list()
	var/list/found_turfs = list()
	for(var/turf/nearby_turf as anything in RANGE_TURFS(MAX_AMBIENCE_RANGE, mob_turf))
		if(nearby_turf.ambience)
			found_ambience += nearby_turf.ambience
			found_turfs += nearby_turf
		if(nearby_turf.ambience_list)
			for(var/ambience in nearby_turf.ambience_list)
				found_ambience += ambience
				found_turfs += nearby_turf
	if(!found_ambience)
		return
	/// Sort by distance here???

	/// Try and queue the ambiences we have found
	i = 0
	var/list/cached_ambience_sounds = ambient_sounds
	var/list/barred_ambience
	for(var/ambience in found_ambience)
		i++
		if(barred_ambience && (ambience in barred_ambience))
			continue
		var/turf/ambience_turf = found_turfs[i]
		var/datum/ambient_sound/sound_datum = cached_ambience_sounds[ambience]
		/// Consider if it's out of the range.
		if(get_dist(ambience_turf, mob_turf) > sound_datum.range)
			continue
		var/list/cooldown_list = ambience_cooldowns[ambience]
		var/cooldown_list_index = 1
		var/cooldown_time_to_set = world_time + sound_datum.frequency_time
		/// Check the cooldown in the cooldown lists
		var/wait_time = world_time
		if(cooldown_list)
			// We have a free spot in the emitter list, add a new cooldown.
			if(cooldown_list.len < sound_datum.maximum_emitters)
				cooldown_list += 0
				cooldown_list_index = cooldown_list.len
			// If we don't, we try and queue
			else
				cooldown_list_index = 0
				var/found_any = FALSE
				/// Iterate over all cooldowns and see if we can play a sound in the next 5s (AMBIENCE_QUEUE_TIME)
				for(var/current_cooldown in cooldown_list)
					cooldown_list_index++
					if(current_cooldown < world_time + AMBIENCE_QUEUE_TIME)
						found_any = TRUE
						wait_time = current_cooldown
						cooldown_time_to_set = current_cooldown + sound_datum.frequency_time
						break
				if(!found_any)
					// We cant find any ambience that can be played within 5s, skip and bar this ambience id from trying
					LAZYINITLIST(barred_ambience)
					barred_ambience += ambience
					continue
		/// If there isn't a cooldown list, free to assume we can create a new cooldown.
		else
			ambience_cooldowns[ambience] = cooldown_list = list()
			cooldown_list += 0

		/// While the next played ambience would have to happen before the next queue, add another queued sound and increment cooldown approprietly
		while(cooldown_time_to_set < world_time + AMBIENCE_QUEUE_TIME)
			invoke_ambient_sound(ambience, ambience_turf, cooldown_time_to_set, cooldown_list_index, sound_datum)
			cooldown_time_to_set = cooldown_time_to_set + sound_datum.frequency_time
		/// Set the cooldown and add a queued sound.
		cooldown_list[cooldown_list_index] = cooldown_time_to_set
		invoke_ambient_sound(ambience, ambience_turf, wait_time, cooldown_list_index, sound_datum)
		/// If there is a cooldown between emitters, populate the cooldown list and fill them all with the cooldown
		if(sound_datum.cooldown_between_emitters)
			var/beetween_cooldown = world_time + sound_datum.cooldown_between_emitters
			cooldown_list_index = 0
			for(var/cooldown in cooldown_list)
				cooldown_list_index++
				if(cooldown < beetween_cooldown)
					cooldown_list[cooldown_list_index] = beetween_cooldown
			while(cooldown_list.len < sound_datum.maximum_emitters)
				cooldown_list += beetween_cooldown

/datum/ambience_controller/proc/invoke_ambient_sound(ambience_id, ambience_turf, wait_time, emitter_index, datum/ambient_sound/sound_datum)
	//If it loops, try and find existing playing managed sound and up its duration instead
	if(sound_datum.loops)
		for(var/datum/managed_ambience/managed as anything in managed_sounds)
			if(managed.ambience_id == ambience_id && managed.emitter_index == emitter_index)
				managed.play_until = wait_time + sound_datum.sound_length
				managed.source_turf = ambience_turf
				return
	queued_object_ambience += new /datum/ambience_queued(ambience_id, ambience_turf, wait_time, emitter_index)

#define AMBIENCE_RANGE_LEISURE 1

/datum/ambience_controller/proc/handle_object_ambience(mob/client_mob)
	for(var/datum/ambience_queued/qued_ambience as anything in queued_object_ambience)
		if(qued_ambience.play_when > world.time)
			continue
		queued_object_ambience -= qued_ambience
		var/turf/mob_turf = get_turf(client_mob)
		var/datum/ambient_sound/sound_datum = ambient_sounds[qued_ambience.ambience_id]
		/// Once again, checking the distance, but adding 1 for extra leisure to not cancel too many queued ambiences
		if(get_dist(qued_ambience.play_turf, mob_turf) > sound_datum.range + AMBIENCE_RANGE_LEISURE)
			continue
		var/sound_to_use = pick(sound_datum.sounds)
		var/channel = get_free_channel()
		var/sound/played_sound = play_ambience_sound(client_mob, qued_ambience.play_turf, sound_to_use, sound_datum.volume, sound_datum.vary, sound_datum.falloff_exponent, sound_datum.falloff_distance, channel, sound_datum.loops)
		played_sound.status = SOUND_UPDATE
		managed_sounds += new /datum/managed_ambience(qued_ambience.emitter_index, qued_ambience.ambience_id, played_sound, channel, qued_ambience.play_turf, sound_datum.sound_length)

#undef AMBIENCE_RANGE_LEISURE

/datum/ambience_controller/proc/play_ambience_sound(mob/client_mob, turf/play_turf, sound_to_use, volume, vary, falloff_exponent, falloff_distance, channel, loops)
	var/sound/sound = sound(sound_to_use)
	sound.wait = FALSE
	sound.channel = channel
	sound.volume = volume
	sound.repeat = loops

	if(vary)
		sound.frequency = get_rand_frequency()

	var/max_distance = 6

	if(play_turf && mob_z)
		var/distance = TWO_POINT_DISTANCE(play_turf.x,play_turf.y,mob_x,mob_y)
		sound.volume -= (max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * volume
		sound.x = play_turf.x - mob_x // Hearing from the right/left
		sound.z = play_turf.y - mob_y // Hearing from infront/behind

	sound.falloff = max_distance
	SEND_SOUND(client_mob, sound)
	return sound

/datum/ambience_controller/proc/handle_managed_ambience(mob/client_mob)
	var/update_sound_positions = update_mob_positions(client_mob) ? TRUE : FALSE

	for(var/datum/managed_ambience/managed as anything in managed_sounds)
		/// If a sound is expired, free it's channel and remove it.
		if(managed.play_until <= world.time)
			if(managed.loops)
				client_mob.stop_sound_channel(managed.channel)
			free_channel(managed.channel)
			managed_sounds -= managed
			continue
		var/turf/play_turf = managed.source_turf
		/// Sound doesn't have a turf it's coming from, we cant update it's xyz and volume
		if(!update_sound_positions || !play_turf)
			continue
		/// Sound is not expired and has a turf. Update it's xyz position and volume
		var/sound/sound = managed.sound
		var/datum/ambient_sound/sound_datum = ambient_sounds[managed.ambience_id]

		var/volume = sound_datum.volume
		var/falloff_exponent = sound_datum.falloff_exponent
		var/falloff_distance = sound_datum.falloff_distance

		var/distance = TWO_POINT_DISTANCE(play_turf.x,play_turf.y,mob_x,mob_y)
		/// if the emitter has gotten too far us, free it.
		//if(distance > 6) ///Check looping here too? Why free non-looping emitters?


		var/max_distance = 6
		sound.volume = volume - ((max(distance - falloff_distance, 0) ** (1 / sound_datum.falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * volume)
		sound.x = play_turf.x - mob_x // Hearing from the right/left
		sound.z = play_turf.y - mob_y // Hearing from infront/behind

		SEND_SOUND(client_mob, sound)

/// Returns TRUE if updated anything, FALSE if not
/datum/ambience_controller/proc/update_mob_positions(mob/client_mob)
	var/turf/mob_turf = get_turf(client_mob)
	if(!mob_turf)
		return FALSE
	if(mob_turf.x == mob_x && mob_turf.y == mob_y && mob_turf.z == mob_z)
		return FALSE
	mob_x = mob_turf.x
	mob_y = mob_turf.y
	mob_z = mob_turf.z
	return TRUE

/// Takes a free channel from the pool of remaining channels. Null if none left
/datum/ambience_controller/proc/get_free_channel()
	if(!free_channels.len)
		return
	var/channel = free_channels[free_channels.len]
	free_channels.len--
	return channel

/// Frees a once taken channel
/datum/ambience_controller/proc/free_channel(channel_to_free)
	free_channels += channel_to_free

/// Struct-like datum that holds information about the queued ambience sound
/datum/ambience_queued
	/// What kind of ambience sound we shall play?
	var/ambience_id
	/// Which turf we will play the sound on?
	var/turf/play_turf
	/// When do we play the sound?
	var/play_when

	var/emitter_index

/datum/ambience_queued/New(passed_id, passed_turf, passed_when, passed_emitter)
	ambience_id = passed_id
	play_turf = passed_turf
	play_when = passed_when
	emitter_index = passed_emitter

/// Struct-like datum that holds information about the currently played sound
/datum/managed_ambience
	/// Index of our emitter
	var/emitter_index
	/// What kind of ambience sound we shall play?
	var/ambience_id
	/// Our sound datum
	var/sound/sound
	/// Channel we are playing on
	var/channel
	/// Which turf we will play the sound on?
	var/turf/source_turf
	/// When do we stop playing the sound
	var/play_until
	/// Whether the managed sound loops
	var/loops = FALSE

/datum/managed_ambience/New(emitter_index, ambience_id, sound/sound, channel, source_turf, sound_length)
	src.emitter_index = emitter_index
	src.ambience_id = ambience_id
	src.sound = sound
	src.loops = sound.repeat
	src.channel = channel
	src.source_turf = source_turf
	src.play_until = world.time + sound_length
