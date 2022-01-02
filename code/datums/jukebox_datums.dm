/// Track that is currently playing from some jukebox
/datum/jukebox_playing_track
	var/obj/machinery/jukebox/jukebox
	var/datum/jukebox_track/track
	var/channel
	var/end_when = 0

/datum/jukebox_playing_track/New(obj/machinery/jukebox/jukebox, datum/jukebox_track/track, channel)
	src.jukebox = jukebox
	src.track = track
	src.channel = channel
	end_when = world.time + track.song_length

	SSjukebox.playing_tracks += src
	add_to_controllers(SSjukebox.controller_list)

/datum/jukebox_playing_track/Destroy()
	jukebox.song_ended()
	SSjukebox.playing_tracks -= src
	SSjukebox.free_channel(channel)
	remove_from_controllers(SSjukebox.controller_list)
	return ..()

/datum/jukebox_playing_track/proc/add_to_controllers(var/list/controller_list)
	var/list/hearers = get_hearers_in_view(JUKEBOX_VIEW_RANGE, jukebox)
	for(var/datum/jukebox_controller/controller in controller_list)
		controller.add_played_track(src, hearers)

/datum/jukebox_playing_track/proc/remove_from_controllers(var/list/controller_list)
	for(var/datum/jukebox_controller/controller in controller_list)
		controller.remove_played_track(src)

/// Updates all controllers
/datum/jukebox_playing_track/proc/update_controllers(var/list/controller_list)
	var/list/hearers = get_hearers_in_view(JUKEBOX_VIEW_RANGE, jukebox)
	for(var/datum/jukebox_controller/controller in controller_list)
		controller.update_played_track(src, hearers)

/// Loaded tracks that jukeboxes can pick and play
/datum/jukebox_track
	var/song_name = "generic"
	var/song_path = null
	var/song_length = 0
	var/song_beat = 0
	var/song_volume = 100

/datum/jukebox_track/New(name, path, length, beat, volume)
	song_name = name
	song_path = path
	song_length = length
	song_beat = beat
	song_volume = volume

/// Jukebox subscription that gets attached to clients and manages the sounds that are being played to it.
/datum/jukebox_controller
	var/client/client
	/// Associative list pointing to a sound from a jukebox playing track
	var/list/track_to_sound = list()

/datum/jukebox_controller/New(client/my_client)
	client = my_client
	SSjukebox.add_controller(src)
	return ..()

/datum/jukebox_controller/Destroy()
	for(var/track in track_to_sound)
		remove_played_track(track)
	SSjukebox.remove_controller(src)
	return ..()

/datum/jukebox_controller/proc/update_sound_data(sound/sound_to_update, datum/jukebox_playing_track/played_track, list/jukebox_hearers)
	var/datum/jukebox_track/track_info = played_track.track
	var/obj/machinery/jukebox/jukebox = played_track.jukebox
	var/mob/client_mob = client.mob
	var/in_jukebox_viscinity = FALSE
	var/target_volume = track_info.song_volume

	var/turf/jukebox_turf = get_turf(jukebox)
	var/turf/mob_turf = get_turf(client_mob)

	if(!jukebox_turf || !mob_turf)
		sound_to_update.status |= SOUND_MUTE
		return
	if(jukebox_turf.virtual_z() != mob_turf.virtual_z())
		sound_to_update.status |= SOUND_MUTE
		return
	var/distance = get_dist(jukebox_turf, mob_turf)

	target_volume *= (jukebox.volume / 100)
	target_volume -= (max(distance - JUKEBOX_FALLOFF_DISTANCE, 0) ** (1 / JUKEBOX_FALLOFF_EXPONENT)) / ((max(JUKEBOX_MAX_RANGE, distance) - JUKEBOX_FALLOFF_DISTANCE) ** (1 / JUKEBOX_FALLOFF_EXPONENT)) * target_volume

	if(target_volume <= 0)
		sound_to_update.status |= SOUND_MUTE
		return
	else
		sound_to_update.status &= ~SOUND_MUTE
		sound_to_update.volume = target_volume

	/// At close range we dont set a position of the sound.
	if(distance <= JUKEBOX_NO_POSITIONAL_RANGE)
		sound_to_update.x = 0.01
		sound_to_update.z = 0.01 //Because 0 means no update. Lol
	else
		sound_to_update.x = jukebox_turf.x - mob_turf.x // Hearing from the right/left
		sound_to_update.z = jukebox_turf.y - mob_turf.y // Hearing from infront/behind

	if(!jukebox_hearers)
		jukebox_hearers = get_hearers_in_view(JUKEBOX_VIEW_RANGE, jukebox_turf)

	/// If we're close enough, check if we're jukebox view or the same area to not get echo.
	if(distance < JUKEBOX_ECHO_RANGE)
		if(get_area(client_mob) == get_area(jukebox))
			in_jukebox_viscinity = TRUE
		else if(client_mob in jukebox_hearers)
			in_jukebox_viscinity = TRUE

	/// Apply an echo if we're not in the jukebox viscinity
	if(in_jukebox_viscinity)
		sound_to_update.echo[1] = 0
		sound_to_update.echo[3] = -250
	else
		sound_to_update.echo[1] = -10000
		sound_to_update.echo[3] = 0

/datum/jukebox_controller/proc/add_played_track(datum/jukebox_playing_track/played_track, list/jukebox_hearers)
	///Create a sound for us from the track
	var/datum/jukebox_track/track_info = played_track.track
	var/sound/new_sound = new(track_info.song_path, repeat = FALSE, wait = 0, volume = 100, channel = played_track.channel)
	new_sound.falloff = JUKEBOX_MAX_RANGE
	new_sound.status |= SOUND_STREAM
	update_sound_data(new_sound, played_track, jukebox_hearers)
	SEND_SOUND(client, new_sound)
	new_sound.status |= SOUND_UPDATE
	track_to_sound[played_track] = new_sound

/datum/jukebox_controller/proc/remove_played_track(datum/jukebox_playing_track/played_track)
	client?.mob.stop_sound_channel(played_track.channel)
	track_to_sound -= played_track

/datum/jukebox_controller/proc/update_played_track(datum/jukebox_playing_track/played_track, list/jukebox_hearers)
	var/sound_to_update = track_to_sound[played_track]
	update_sound_data(sound_to_update, played_track, jukebox_hearers)
	SEND_SOUND(client, sound_to_update)
