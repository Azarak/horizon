/datum/trader_bounty
	var/bounty_name = "Epic Items"
	var/name

	var/amount = 1
	var/check_type = TRUE
	var/path
	var/list/possible_paths

	var/reward_cash = 1000

	var/reward_item_name
	var/reward_item_path
	var/list/possible_reward_item_paths

	var/bounty_text = "I'm looking to acquire a couple of this exotic item."
	var/bounty_complete_text = "Thank you very much for getting me those."

/datum/trader_bounty/New()
	. = ..()
	if(possible_paths)
		path = pick(possible_paths)
		possible_paths = null
	if(!name)
		var/atom/movable/cast = path
		name = initial(cast.name)
	if(possible_reward_item_paths)
		reward_item_path = pick(possible_reward_item_paths)
		possible_reward_item_paths = null
	if(reward_item_path && !reward_item_name)
		var/atom/movable/cast = reward_item_path
		reward_item_name = initial(cast.name)

/datum/trader_bounty/proc/Validate(atom/movable/movable_to_valid)
	if((!check_type || movable_to_valid.type == path) && IsValid(movable_to_valid))
		return GetAmount(movable_to_valid)

/datum/trader_bounty/proc/IsValid(atom/movable/movable_to_valid)
	return TRUE

/datum/trader_bounty/proc/GetAmount(atom/movable/movable_to_valid)
	return 1

/datum/trader_bounty/stack

/datum/trader_bounty/stack/GetAmount(atom/movable/movable_to_valid)
	var/obj/item/stack/our_stack = movable_to_valid
	return our_stack.amount

/datum/trader_bounty/reagent
	check_type = FALSE
	var/reagent_type
	var/list/possible_reagent_types

/datum/trader_bounty/reagent/New()
	. = ..()
	if(possible_reagent_types)
		reagent_type = pick(possible_reagent_types)
		possible_reagent_types = null
	if(!name)
		var/datum/reagent/reagent_cast = reagent_type
		name = "[initial(reagent_cast.name)]"

/datum/trader_bounty/reagent/IsValid(atom/movable/movable_to_valid)
	if(!istype(movable_to_valid, /obj/item/reagent_containers))
		return FALSE
	var/datum/reagents/holder = movable_to_valid.reagents
	if(!holder)
		return FALSE
	if(!holder.has_reagent(reagent_type))
		return FALSE
	return TRUE

/datum/trader_bounty/reagent/GetAmount(atom/movable/movable_to_valid)
	var/datum/reagents/holder = movable_to_valid.reagents
	var/datum/reagent/reagent = holder.get_reagent(reagent_type)
	return reagent.volume
