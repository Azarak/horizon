/// The subsystem used to play ambience to users every now and then, makes them real excited.
SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_AMBIENCE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1 SECONDS
	/// List of all ambience controllers
	var/list/ambience_controller_list = list()

/datum/controller/subsystem/ambience/fire(resumed)
	for(var/datum/ambience_controller/ambi_control as anything in ambience_controller_list)
		ambi_control.process()
		if(MC_TICK_CHECK)
			return
