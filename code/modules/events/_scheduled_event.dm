///Scheduled event datum for SSgamemode to put events into.
/datum/scheduled_event
	/// What event are scheduling.
	var/datum/round_event_control/event
	/// When do we start our event
	var/start_time = 0
	/// If we were created by a storyteller, here's a cost to refund in case.
	var/cost
	/// Whether we alerted admins about this schedule when it's close to being invoked.
	var/alerted_admins = FALSE
	/// Whether we are faking an occurence or not
	var/fakes_occurence = TRUE
	/// Whether this ignores event can run checks. If bussed by an admin, you want to ignore checks
	var/ignores_checks

/datum/scheduled_event/New(datum/round_event_control/passed_event, passed_time, passed_cost, passed_ignore)
	. = ..()
	event = passed_event
	start_time = passed_time
	cost = passed_cost
	ignores_checks = passed_ignore
	/// Add a fake occurence to make the weightings/checks properly respect the scheduled event.
	event.add_occurence()
	fakes_occurence = TRUE

/datum/scheduled_event/proc/remove_occurence()
	if(fakes_occurence)
		/// Remove the fake occurence if we still have it
		event.subtract_occurence()
		fakes_occurence = FALSE

/// For admins who want to reschedule the event.
/datum/scheduled_event/proc/reschedule(new_time)
	start_time = new_time
	alerted_admins = FALSE

/datum/scheduled_event/Destroy()
	remove_occurence()
	event = null
	return ..()

/datum/scheduled_event/Topic(href, href_list)
	. = ..()
	if(QDELETED(src))
		return
	switch(href_list["action"])
		if("cancel")
			message_admins("[key_name_admin(usr)] cancelled scheduled event [event.name].")
			log_admin_private("[key_name(usr)] cancelled scheduled event [event.name].")
			SSgamemode.remove_scheduled_event(src)
		if("refund")
			message_admins("[key_name_admin(usr)] refunded scheduled event [event.name].")
			log_admin_private("[key_name(usr)] refunded scheduled event [event.name].")
			SSgamemode.refund_scheduled_event(src)
