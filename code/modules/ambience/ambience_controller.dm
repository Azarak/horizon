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

/datum/ambience_controller/New(client/applied_client)
	. = ..()
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
	handle_area_ambience(client_mob)
	handle_ship_ambience(client_mob)

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
	if(playing_ship_ambience == pref_ship_ambience)
		return
	playing_ship_ambience = pref_ship_ambience
	if(playing_ship_ambience)
		SEND_SOUND(client, sound('sound/ambience/shipambience.ogg', repeat = TRUE, wait = 0, volume = 18, channel = CHANNEL_BUZZ))
	else
		client_mob.stop_sound_channel(CHANNEL_BUZZ)

/// When our client pref gets updated.
/datum/ambience_controller/proc/client_pref_update()
	var/datum/preferences/prefs = client.prefs
	var/mob/client_mob = client.mob

	pref_ship_ambience = (prefs.toggles & SOUND_SHIP_AMBIENCE)
	pref_area_ambience = (prefs.toggles & SOUND_AMBIENCE)
	pref_object_ambience = TRUE

	handle_area_ambience(client_mob)
	handle_ship_ambience(client_mob)
