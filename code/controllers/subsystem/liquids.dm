SUBSYSTEM_DEF(liquids)
	name = "Liquid Turfs"
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/active_turfs = list()


/datum/controller/subsystem/liquids/stat_entry(msg)
	msg += "AT:[active_turfs.len]"
	return ..()


/datum/controller/subsystem/liquids/fire(resumed = FALSE)
	for(var/tur in active_turfs)
		var/turf/T = tur
		T.process_liquid_cell()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/liquids/proc/add_active_turf(turf/T)
	active_turfs[T] = TRUE

/datum/controller/subsystem/liquids/proc/remove_active_turf(turf/T)
	active_turfs -= T

/*
/turf/air_update_turf(update = FALSE, remove = FALSE)
	..()
	for(var/thing in GetAtmosAdjacentTurfs())
		var/turf/NT = thing
		if(NT.liquids)
			SSliquids.add_active_turf(NT)
*/

/turf
	var/datum/liquid_mixture/liquids
	var/obj/effect/liquid_effect/liquid_effect

/turf/proc/set_reagent_color_for_liquid()
	liquid_effect.color = mix_color_from_reagents(liquids.reagents.reagent_list)

/turf/proc/process_liquid_cell()
	if(!liquids || liquids.height <= 1)
		SSliquids.remove_active_turf(src)
		return
	//Try sharing the liquids
	for(var/thing in GetAtmosAdjacentTurfs())
		var/turf/NT = thing
		var/target_height = NT.liquids ? NT.liquids.height : 0
		var/difference = abs(target_height - liquids.height)
		if(difference > 1) //SHOULD BE 1?		
			spread_liquid_to_cell(NT)
			return

	SSliquids.remove_active_turf(src)

/turf/proc/spread_liquid_to_cell(turf/T)
	if(!T.liquids)
		T.liquids = new()
		T.liquid_effect = new(T)
	//SHARE BOTH HERE
	var/datum/reagents/tempr = new(10000)
	liquids.reagents.trans_to(tempr, liquids.reagents.total_volume)
	T.liquids.reagents.trans_to(tempr, T.liquids.reagents.total_volume)
	tempr.trans_to(liquids.reagents, multiplier = 0.5, no_react = TRUE)
	tempr.trans_to(T.liquids.reagents, multiplier = 0.5, no_react = TRUE)
	qdel(tempr)
	liquids.calculate_height()
	set_reagent_color_for_liquid()
	T.liquids.calculate_height()
	T.set_reagent_color_for_liquid()
	SSliquids.add_active_turf(T)

/turf/proc/add_liquid(reagent, amount)
	if(!liquids)
		liquids = new()
		liquid_effect = new(src)
	liquids.reagents.add_reagent(reagent, amount)
	liquids.calculate_height()
	set_reagent_color_for_liquid()
	SSliquids.add_active_turf(src)

/datum/liquid_mixture
	var/height = 0
	var/datum/reagents/reagents

/datum/liquid_mixture/New()
	reagents = new(1000)

/datum/liquid_mixture/proc/calculate_height()
	height = CEILING(reagents.total_volume/10, 1)

/obj/effect/liquid_effect
	name = "liquid"
	icon = 'icons/horizon/obj/effects/liquid.dmi'
	icon_state = "liquid"
	anchored = TRUE
	plane = FLOOR_PLANE
	color = "#DDF"
	//layer = MID_LANDMARK_LAYER
	//invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/liquid_effect/singularity_act()
	return

/obj/effect/liquid_effect/singularity_pull()
	return

/obj/effect/liquid_effect/Destroy(force)
	if(force)
		return ..()
	else
		return QDEL_HINT_LETMELIVE
