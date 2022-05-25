
/mob/living/carbon/proc/get_pain_bar()
	var/pain_bar = 0
	for(var/obj/item/bodypart/part as anything in bodyparts)
		pain_bar += part.get_damage()
	// Toxins also count into pain, but they dont deal pain immediately when inflicted
	pain_bar += toxloss
	return pain_bar

/mob/living/carbon/adjustPainLoss(pain_amt)
	pain = clamp(pain + pain_amt, 0, PAIN_MAXIMUM)
	update_pain_states()

	// Handle pain groans //50 pain amount is 100% for a response, so around 25 damage in a hit
	if(next_pain_groan < world.time && pain_amt > PAIN_SCREAM_TRIGGER_THRESHOLD && pain >= PAIN_SCREAM_THRESHOLD && prob(pain_amt * PAIN_SCREAM_TRIGGER_MULTIPLIER))
		next_pain_groan = world.time + 4 SECONDS
		var/scream_chance = pain * 0.2
		if(prob(scream_chance))
			emote("scream")
		else
			emote("pain")

/mob/living/carbon/proc/handle_pain(delta_time)
	var/pain_bar = get_pain_bar()
	// If there is pain, pain bar and pain isn't equal to pain bar, we move the pain towards the pain bar
	if((pain || pain_bar) && pain != pain_bar)
		var/bar_difference = pain - pain_bar
		var/abs_difference = abs(bar_difference)
		var/recovery_amount = ((abs_difference * 0.01) + 0.5) * delta_time //1% + 0.5 of difference per second
		if(recovery_amount > abs_difference)
			recovery_amount = abs_difference
		if(bar_difference < 0)
			recovery_amount = -recovery_amount
		adjustPainLoss(-recovery_amount)
		return //adjusting pain updates pain states
	update_pain_states()

/mob/living/carbon/proc/get_pain_string()
	switch(pain)
		if(0 to 75)
			return SPAN_WARNING("You feel mild pain.")
		if(75 to 125)
			return SPAN_WARNING("You feel pain!")
		if(125 to 175)
			return SPAN_WARNING("You feel great pain!")
		if(175 to 225)
			return SPAN_BOLDWARNING("You feel terrible pain!")
		if(225 to PAIN_MAXIMUM)
			return SPAN_BOLDWARNING("You feel agonizing pain!")

/mob/living/carbon/proc/update_pain_states()
	// Handle pain messages
	if(pain > PAIN_MESSAGE_THRESHOLD && next_pain_message < world.time)
		next_pain_message = world.time + 20 SECONDS
		to_chat(src, get_pain_string())

	// Update pain slowdown
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
	else if(pain >= PAIN_SLOWDOWN_THRESHOLD)
		var/pain_slowdown = pain / PAIN_SLOWDOWN_DIVISOR
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, multiplicative_slowdown = pain_slowdown)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, multiplicative_slowdown = pain_slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)

	// Handle paincrit
	var/new_pain_crit_state = 0
	var/paincrit_persists = TRUE
	switch(pain)
		if(0 to 180)
			paincrit_persists = FALSE
			new_pain_crit_state = PAIN_CRIT_STATE_NONE
		if(180 to 200)
			new_pain_crit_state = PAIN_CRIT_STATE_CRAWLING
		if(200 to 230)
			new_pain_crit_state = PAIN_CRIT_STATE_INCAPACITATED
		if(230 to PAIN_MAXIMUM)
			new_pain_crit_state = PAIN_CRIT_STATE_UNCONSCIOUS


	if(pain_crit_state && !new_pain_crit_state && paincrit_persists)
		new_pain_crit_state = PAIN_CRIT_STATE_CRAWLING

	// If the state is new
	if(new_pain_crit_state != pain_crit_state)
		if(!pain_crit_state)
			to_chat(src, SPAN_BOLDWARNING("You succumb to pain..."))
		pain_crit_state = new_pain_crit_state
		switch(pain_crit_state)
			if(PAIN_CRIT_STATE_NONE)
				//Remove paincrit stuff
				REMOVE_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				REMOVE_TRAIT(src, TRAIT_FLOORED, PAIN)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
			if(PAIN_CRIT_STATE_CRAWLING)
				//Incapacitated, floored
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
			if(PAIN_CRIT_STATE_INCAPACITATED)
				//Incapacitated, floored, immobilized
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
			if(PAIN_CRIT_STATE_UNCONSCIOUS)
				// Unconscious + the rest
				ADD_TRAIT(src, TRAIT_INCAPACITATED, PAIN)
				ADD_TRAIT(src, TRAIT_FLOORED, PAIN)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, PAIN)
				AdjustUnconscious(10 SECONDS) // Entering this state makes you unconscious for 10 seconds

/mob/living/carbon/in_shock()
	return (health <= crit_threshold)

/mob/living/carbon/in_pain_crit()
	return (pain_crit_state > PAIN_CRIT_STATE_NONE)
