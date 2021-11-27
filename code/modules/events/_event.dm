//this singleton datum is used by the events controller to dictate how it selects events
/datum/round_event_control
	var/name //The human-readable name of the event
	var/typepath //The typepath of the event datum /datum/round_event

	var/weight = 10 //The weight this event has in the random-selection process.
									//Higher weights are more likely to be picked.
									//10 is the default weight. 20 is twice more likely; 5 is half as likely as this default.
									//0 here does NOT disable the event, it just makes it extremely unlikely

	var/earliest_start = 20 MINUTES //The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins
	var/min_players = 0 //The minimum amount of alive, non-AFK human players on server required to start the event.

	var/occurrences = 0 //How many times this event has occured
	var/max_occurrences = 20 //The maximum number of times this event can occur (naturally), it can still be forced.
									//By setting this to 0 you can effectively disable an event.

	var/holidayID = "" //string which should be in the SSgamemodes.holidays list if you wish this event to be holiday-specific
									//anything with a (non-null) holidayID which does not match holiday, cannot run.
	var/wizardevent = FALSE
	var/alert_observers = TRUE //should we let the ghosts and admins know this event is firing
									//should be disabled on events that fire a lot
	/// To which event track does this event belong to
	var/track = EVENT_TRACK_MODERATE
	/// How much event points will this event spend. It's a multiplier to the track threshold and effectively affects how long until the next event of the same track type. Affected by random bell curve for variance.
	var/cost = 1
	/// Last calculated weight that the storyteller assigned this event
	var/calculated_weight = 10
	/// Tags of the event
	var/tags = list()
	/// Multiplier to the penalty applied to weight for re-occurance. The smaller the lesser the penalty
	var/reoccurence_penalty_multiplier = 1
	/// Whether this event uses a shared occurence type, sharing occurence counts with the ones that also do have this set. Important if you want different event types to share weight penalties for recurrence.
	var/shared_occurence_type
	/// List of the shared occurence types.
	var/static/list/shared_occurences = list()

/datum/round_event_control/New()
	if(config && !wizardevent) // Magic is unaffected by configs
		earliest_start = CEILING(earliest_start * CONFIG_GET(number/events_min_time_mul), 1)
		min_players = CEILING(min_players * CONFIG_GET(number/events_min_players_mul), 1)

/datum/round_event_control/Topic(href, href_list)
	. = ..()
	if(QDELETED(src))
		return
	switch(href_list["action"])
		if("force_next")
			message_admins("[key_name_admin(usr)] forced event [name] to be the next rolled event.")
			log_admin_private("[key_name(usr)] forced event[name] to be the next rolled event.")
			SSgamemode.forced_next_events[track] = src
		if("schedule")
			var/schedule_time = input(usr, "Schedule event [name] in time (in seconds):", "Schedule Event") as num|null
			if(isnull(schedule_time) || QDELETED(src))
				return
			var/start_time = schedule_time * 1 SECONDS
			SSgamemode.schedule_event(src, start_time, 0, TRUE)
			message_admins("[key_name_admin(usr)] scheduled event [name] to fire in [schedule_time] seconds.")
			log_admin_private("[key_name(usr)] scheduled event [name] to fire in [schedule_time] seconds.")
		if("fire")
			message_admins("[key_name_admin(usr)] has fired event [name].")
			log_admin_private("[key_name(usr)] has fired event [name].")
			SSgamemode.TriggerEvent(src)

/datum/round_event_control/wizard
	wizardevent = TRUE

///Adds an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/add_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]++
	occurrences++

///Subtracts an occurence. Has to use the setter to properly handle shared occurences
/datum/round_event_control/proc/subtract_occurence()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		shared_occurences[shared_occurence_type]--
	occurrences--

///Gets occurences. Has to use the getter to properly handle shared occurences
/datum/round_event_control/proc/get_occurences()
	if(shared_occurence_type)
		if(!shared_occurences[shared_occurence_type])
			shared_occurences[shared_occurence_type] = 0
		return shared_occurences[shared_occurence_type]
	return occurrences

// Checks if the event can be spawned. Used by event controller and "false alarm" event.
// Admin-created events override this.
/datum/round_event_control/proc/canSpawnEvent(popchecks = TRUE)
	var/players_amt = SSgamemode.active_players
	if(get_occurences() >= max_occurrences)
		return FALSE
	if(earliest_start >= world.time-SSticker.round_start_time)
		return FALSE
	if(wizardevent != SSgamemode.wizardmode)
		return FALSE
	if(popchecks)
		if(players_amt < min_players)
			return FALSE
	if(holidayID && (!SSgamemode.holidays || !SSgamemode.holidays[holidayID]))
		return FALSE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return FALSE
	if(ispath(typepath, /datum/round_event/ghost_role) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		return FALSE

	return TRUE

/datum/round_event_control/proc/preRunEvent()
	if(!ispath(typepath, /datum/round_event))
		return EVENT_CANT_RUN
	return EVENT_READY

/datum/round_event_control/proc/runEvent(random = FALSE)
	var/datum/round_event/E = new typepath()
	E.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	E.control = src
	SSblackbox.record_feedback("tally", "event_ran", 1, "[E]")
	add_occurence()

	message_admins("Event: [name] just triggered!")
	testing("[time2text(world.time, "hh:mm:ss")] [E.type]")
	if(random)
		log_game("Random Event triggering: [name] ([typepath])")
	if (alert_observers)
		deadchat_broadcast(" has just been[random ? " randomly" : ""] triggered!", "<b>[name]</b>", message_type=DEADCHAT_ANNOUNCEMENT) //STOP ASSUMING IT'S BADMINS!
	return E

//Special admins setup
/datum/round_event_control/proc/admin_setup()
	return

/datum/round_event //NOTE: Times are measured in master controller ticks!
	var/processing = TRUE
	var/datum/round_event_control/control

	var/startWhen = 0 //When in the lifetime to call start().
	var/announceWhen = 0 //When in the lifetime to call announce(). If you don't want it to announce use announceChance, below.
	var/announceChance = 100 // Probability of announcing, used in prob(), 0 to 100, default 100. Used in ion storms currently.
	var/endWhen = 0 //When in the lifetime the event should end.

	var/activeFor = 0 //How long the event has existed. You don't need to change this.
	var/current_players = 0 //Amount of of alive, non-AFK human players on server at the time of event start
	var/fakeable = TRUE //Can be faked by fake news event.

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
//EDIT: if there's anything you want to override within the new() call, it will not be overridden by the time this proc is called.
//It will only have been overridden by the time we get to announce() start() tick() or end() (anything but setup basically).
//This is really only for setting defaults which can be overridden later when New() finishes.
/datum/round_event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/round_event/proc/start()
	return

//Called after something followable has been spawned by an event
//Provides ghosts a follow link to an atom if possible
//Only called once.
/datum/round_event/proc/announce_to_ghosts(atom/atom_of_interest)
	if(control.alert_observers)
		if (atom_of_interest)
			notify_ghosts("[control.name] has an object of interest: [atom_of_interest]!", source=atom_of_interest, action=NOTIFY_ORBIT, header="Something's Interesting!")
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/round_event/proc/announce(fake)
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/round_event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/round_event/proc/end()
	return



//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/round_event/process()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!processing)
		return

	if(activeFor == startWhen)
		processing = FALSE
		start()
		processing = TRUE

	if(activeFor == announceWhen && prob(announceChance))
		processing = FALSE
		announce(FALSE)
		processing = TRUE

	if(startWhen < activeFor && activeFor < endWhen)
		processing = FALSE
		tick()
		processing = TRUE

	if(activeFor == endWhen)
		processing = FALSE
		end()
		processing = TRUE

	// Everything is done, let's clean up.
	if(activeFor >= endWhen && activeFor >= announceWhen && activeFor >= startWhen)
		processing = FALSE
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/round_event/proc/kill()
	SSgamemode.running -= src


//Sets up the event then adds the event to the the list of running events
/datum/round_event/New(my_processing = TRUE)
	setup()
	processing = my_processing
	SSgamemode.running += src
	return ..()
