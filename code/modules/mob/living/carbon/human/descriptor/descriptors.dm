/// Descriptor for a human's age.
/datum/descriptor/age

/datum/descriptor/age/can_describe(mob/living/carbon/human/examined)
	if ((examined.wear_mask && (examined.wear_mask.flags_inv & HIDEFACE)) || (examined.head && (examined.head.flags_inv & HIDEFACE)))
		return FALSE
	return TRUE

/datum/descriptor/age/description_value(mob/living/carbon/human/examined)
	switch(examined.age)
		if(0 to 20)
			return 1
		if(21 to 24)
			return 2
		if(25 to 28)
			return 3
		if(29 to 35)
			return 4
		if(36 to 45)
			return 5
		if(46 to 55)
			return 6
		if(56 to 70)
			return 7
		if(71 to INFINITY)
			return 8

/datum/descriptor/age/describe(mob/living/carbon/human/examined, description_value)
	var/age_text
	switch(description_value)
		if(1)
			age_text = "a young adult."
		if(2)
			age_text = "of adult age."
		if(3)
			age_text = "a mature adult."
		if(4 to 5)
			age_text = "middle-aged."
		if(6)
			age_text = "rather old."
		if(7)
			age_text = "very old."
		if(8)
			age_text = "withering away."
	return SPAN_SMALLNOTICE("[examined.p_they(TRUE)] appear[examined.p_s()] to be [age_text]")

/datum/descriptor/age/compare(mob/living/carbon/human/comparator, mob/living/carbon/human/examined, description_difference)
	var/compare_text
	switch(description_difference)
		if(-INFINITY to -3)
			compare_text = "much older than you."
		if(-2)
			compare_text = "older than you."
		if(-1)
			compare_text = "slightly older than you."
		if(0)
			compare_text = "about the same age as you."
		if(1)
			compare_text = "slightly younger than you."
		if(2)
			compare_text = "younger than you."
		if(3 to INFINITY)
			compare_text = "much younger than you."
	return SPAN_SMALLNOTICE("[examined.p_they(TRUE)] appear[examined.p_s()] to be [compare_text]")
