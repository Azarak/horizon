/datum/ambience_controller
	/// Client we play things to and respects prefs of
	var/client/client
	/// Next time we shall play area ambience at
	var/next_area_ambience = 0
	/// Whether we wzhzhzhzhhzhzh
	var/playing_ship_ambience = FALSE
	/// Whether we are playing area ambience
	var/playing_area_ambience = FALSE

	/// Preference variables
	var/pref_ship_ambience = TRUE
	var/pref_area_ambience = TRUE
	var/pref_object_ambience = TRUE

	/// Time until the next object sweep for scheduling played object ambience
	var/next_object_sweep = 0
	/// Fast ref to the list with ambient datums
	var/static/list/ambient_sounds
	/// A list of lists of cooldowns per emitters to our ambient sounds
	var/list/ambience_cooldowns[TOTAL_AMBIENT_SOUNDS]
	/// Queued object ambiences that we process
	var/list/queued_object_ambience = list()

/datum/ambience_controller/New(client/applied_client)
	. = ..()
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
	if(next_object_sweep < world.time)
		handle_object_sweep(client_mob)
	handle_area_ambience(client_mob)
	handle_ship_ambience(client_mob)
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
	if(ambience_cooldowns.len)
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
		/// If it has an emission chance, roll it
		if(sound_datum.emission_chance && !prob(sound_datum.emission_chance))
			continue
		/// Consider if it's out of the range.
		if(get_dist(ambience_turf, mob_turf) > sound_datum.range)
			continue
		var/list/cooldown_list = ambience_cooldowns[ambience]
		var/cooldown_list_index = 1
		var/cooldown_time_to_set = world_time + sound_datum.frequency_time
		/// Check the cooldown in the cooldown lists
		var/wait_time = world_time
		if(cooldown_list)
			// We have a free spot in the emitter list, add a new entry
			if(cooldown_list.len < sound_datum.maximum_emitters)
				cooldown_list += 0
				cooldown_list_index = cooldown_list.len
			// If we don't, we try and queue
			else
				cooldown_list_index = 0
				var/found_any = FALSE
				/// Iterate over all cooldowns and see if we can play a sound in the next 5s (AMBIENCE_SWEEP_TIME)
				for(var/current_cooldown in cooldown_list)
					cooldown_list_index++
					if(current_cooldown < world_time + AMBIENCE_SWEEP_TIME)
						found_any = TRUE
						wait_time = current_cooldown
						cooldown_time_to_set = current_cooldown + sound_datum.frequency_time
						break
				if(!found_any)
					// We cant find any ambience that can be played within 5s, skip and bar this ambience id from trying
					LAZYINITLIST(barred_ambience)
					barred_ambience += ambience
					continue
		/// If there isn't a cooldown list, free to assume we can create one and add a cd.
		else
			ambience_cooldowns[ambience] = cooldown_list = list()
			cooldown_list += 0

		/// While the next played ambience would have to happen before the next sweep, add another queued sound and increment cooldown approprietly
		while(cooldown_time_to_set < world_time + AMBIENCE_SWEEP_TIME)
			queued_object_ambience += new /datum/ambience_queued(ambience, ambience_turf, cooldown_time_to_set)
			cooldown_time_to_set = cooldown_time_to_set + sound_datum.frequency_time
		/// Set the cooldown and add a queued sound.
		cooldown_list[cooldown_list_index] = cooldown_time_to_set
		queued_object_ambience += new /datum/ambience_queued(ambience, ambience_turf, wait_time)
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

#define AMBIENCE_RANGE_LEISURE 1

/datum/ambience_controller/proc/handle_object_ambience(mob/client_mob)
	for(var/datum/ambience_queued/qued_ambience as anything in queued_object_ambience)
		if(qued_ambience.play_when >= world.time)
			continue
		queued_object_ambience -= qued_ambience
		var/turf/mob_turf = get_turf(client_mob)
		var/datum/ambient_sound/sound_datum = ambient_sounds[qued_ambience.ambience_id]
		/// Once again, checking the distance, but adding 1 for extra leisure to not cancel too many queued ambiences
		if(get_dist(qued_ambience.play_turf, mob_turf) > sound_datum.range + AMBIENCE_RANGE_LEISURE)
			continue
		var/sound_to_use = pick(sound_datum.sounds)
		client_mob.playsound_local(qued_ambience.play_turf, sound_to_use, sound_datum.volume, sound_datum.vary, falloff_exponent = AMBIENCE_FALLOFF_EXPONENT, falloff_distance = AMBIENCE_FALLOFF_DISTANCE)

#undef AMBIENCE_RANGE_LEISURE

/// Struct-like datum that holds information about the queued ambience sound
/datum/ambience_queued
	/// What kind of ambience sound we shall play?
	var/ambience_id
	/// Which turf we will play the sound on?
	var/turf/play_turf
	/// When do we play the sound?
	var/play_when

/datum/ambience_queued/New(passed_id, passed_turf, passed_when)
	ambience_id = passed_id
	play_turf = passed_turf
	play_when = passed_when
