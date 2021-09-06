/datum/job_listing
	var/name
	var/desc
	var/datum/job/overflow_role_job
	var/overflow_role
	/// List of all departments with joinable jobs.
	var/list/datum/job_department/joinable_departments = list()
	/// List of all joinable departments indexed by their typepath, sorted by their own display order.
	var/list/datum/job_department/joinable_departments_by_type = list()
	/// List of jobs that can be joined through the starting menu.
	var/list/datum/job/joinable_occupations = list()
	/// List of jobs that can be joined through the starting menu, associative by type.
	var/list/datum/job/joinable_occupations_by_type = list()
	/// List of all the job types that should be initialzied for this listing
	var/list/jobs = list()
	/// If this is defined, instead it'll pool all jobs that are of that faction, and ignore the `jobs` definiton.
	var/faction
	/// Landmarks for latejoining
	var/list/latejoin_trackers = list()
	/// Landmarks for starting points
	var/list/start_landmarks_list = list()
	/// Landmarks for starting points
	var/list/jobspawn_overrides = list()
	/// Unique ID of the job listing, doesn't actually have to be unique as the system will handle duplicates fine, but if you want consistent job prefs savefiles, make those unique
	var/unique_id = "blank"

/datum/job_listing/New(passed_name, passed_desc)
	. = ..()
	name = passed_name
	desc = passed_desc
	SetupOccupations()
	SetOverflowRole(overflow_role)
	SSjob.job_listings += src
	if(!SSjob.main_jobs)
		SSjob.main_jobs = src
	SSjob.last_job_listing = src
	if(!SSjob.job_listings_ids[unique_id])
		SSjob.job_listings_ids[unique_id] = src
	else //There is already a listing loaded like us, fallback to appending our id
		var/append_num = 1
		while(TRUE)
			append_num++
			var/target_id = "[unique_id][append_num]"
			if(!SSjob.job_listings_ids[target_id])
				unique_id = target_id
				SSjob.job_listings_ids[unique_id] = src
				break

/datum/job_listing/proc/GetJobType(passed_type)
	return joinable_occupations_by_type[passed_type]

/datum/job_listing/proc/SetupOccupations()
	if(faction)
		jobs = list()
		for(var/job_type in subtypesof(/datum/job))
			var/datum/job/job = SSjob.GetJobType(job_type)
			if(job.job_flags & JOB_NEW_PLAYER_JOINABLE && job.faction == faction)
				jobs += job_type
	var/list/new_joinable_occupations = list()
	var/list/new_joinable_departments = list()
	var/list/new_joinable_departments_by_type = list()
	for(var/iterated_type in jobs)
		var/datum/job/job = new iterated_type(src)
		new_joinable_occupations += job
		joinable_occupations_by_type[iterated_type] = job
		if(!LAZYLEN(job.departments_list))
			var/datum/job_department/department = new_joinable_departments_by_type[/datum/job_department/undefined]
			if(!department)
				department = new /datum/job_department/undefined()
				new_joinable_departments_by_type[/datum/job_department/undefined] = department
			department.add_job(job)
			continue
		for(var/department_type in job.departments_list)
			var/datum/job_department/department = new_joinable_departments_by_type[department_type]
			if(!department)
				department = new department_type()
				new_joinable_departments_by_type[department_type] = department
			department.add_job(job)
	sortTim(new_joinable_departments_by_type, /proc/cmp_department_display_asc, associative = TRUE)
	for(var/department_type in new_joinable_departments_by_type)
		var/datum/job_department/department = new_joinable_departments_by_type[department_type]
		sortTim(department.department_jobs, /proc/cmp_job_display_asc)
		new_joinable_departments += department
	joinable_occupations = sortTim(new_joinable_occupations, /proc/cmp_job_display_asc)
	joinable_departments = new_joinable_departments
	joinable_departments_by_type = new_joinable_departments_by_type

/datum/job_listing/proc/SetOverflowRole(new_overflow_role_type)
	var/datum/job/new_overflow_role = GetJobType(new_overflow_role_type)
	if(!new_overflow_role)
		CRASH("SetOverflowRole failed | SetOverflowRole: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow_role.allow_bureaucratic_error = FALSE
	new_overflow_role.spawn_positions = cap
	new_overflow_role.total_positions = cap

	if(new_overflow_role == overflow_role_job)
		return
	var/datum/job/old_overflow = GetJobType(overflow_role)
	old_overflow.allow_bureaucratic_error = initial(old_overflow.allow_bureaucratic_error)
	old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
	old_overflow.total_positions = initial(old_overflow.total_positions)
	overflow_role_job = new_overflow_role
	overflow_role = new_overflow_role_type

/datum/job_listing/proc/get_department_type(department_type)
	return joinable_departments_by_type[department_type]

/datum/job_listing/station
	overflow_role = /datum/job/assistant
	faction = FACTION_STATION
	unique_id = "station"

/datum/job_listing/tradership
	overflow_role = /datum/job/tradership_deckhand
	faction = FACTION_TRADERSHIP
	unique_id = "tradership"
