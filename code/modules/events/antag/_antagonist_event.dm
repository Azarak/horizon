/datum/round_event_control/antagonist
	reoccurence_penalty_multiplier = 0
	track = EVENT_TRACK_ROLESET
	/// Protected roles from the antag roll. People will not get those roles if a config is enabled
	var/list/protected_roles
	/// Restricted roles from the antag roll
	var/list/restricted_roles

/datum/round_event_control/antagonist/New()
	. = ..()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_roles |= protected_roles

/datum/round_event_control/antagonist/roundstart
	roundstart = TRUE
	can_run_post_roundstart = FALSE

/datum/round_event_control/antagonist/roundstart/solo
	typepath = /datum/round_event/antagonist/solo //Dont change this
	/// How many baseline antags do we spawn
	var/base_antags = 1
	/// How many maximum antags can we spawn
	var/maximum_antags = 3
	/// For this many players we'll add 1 up to the maximum antag amount
	var/denominator = 20
	/// The antag flag to be used
	var/antag_flag
	/// The antag datum to be applied
	var/antag_datum

/datum/round_event_control/antagonist/roundstart/solo/canSpawnEvent(popchecks = TRUE)
	. = ..()
	if(!.)
		return
	var/antag_amt = get_antag_amount()
	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, ready_newplayers = TRUE)
	if(candidates.len < antag_amt)
		return FALSE

/datum/round_event_control/antagonist/roundstart/solo/proc/get_antag_amount()
	var/people = SSgamemode.get_correct_popcount()
	var/amount = base_antags + FLOOR(people / denominator, 1)
	return min(amount, maximum_antags)

/datum/round_event/antagonist
	fakeable = FALSE

/datum/round_event/antagonist/solo
	// ALL of those variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/antag_datum
	/// The antag count passed from control
	var/antag_count
	/// The restricted roles (jobs) passed from control
	var/list/restricted_roles
	/// The minds we've setup in setup() and need to finalize in start()
	var/list/setup_minds = list()

/datum/round_event/antagonist/solo/setup()
	var/datum/round_event_control/antagonist/roundstart/solo/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles

	var/list/candidates = SSgamemode.get_candidates(antag_flag, antag_flag, ready_newplayers = TRUE)
	for(var/i in 1 to antag_count)
		var/mob/candidate = pick_n_take(candidates)
		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles

/datum/round_event/antagonist/solo/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		antag_mind.add_antag_datum(antag_datum)

/datum/round_event_control/antagonist/roundstart/solo/traitor
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	protected_roles = list("Prisoner","Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI", "Cyborg")
