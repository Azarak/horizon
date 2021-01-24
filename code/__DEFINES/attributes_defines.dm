//Defines relating to prefs
#define ATTRIBUTES_FREE_POINTS 0
#define ATTRIBUTES_PREF_MINIMUM -3
#define ATTRIBUTES_PREF_MAXIMUM 6

#define ATTRIBUTE_EQUILIBRIUM 10
#define BASE_ATTRIBUTE_AMOUNT 10

#define SKILL_EQUILIBRIUM 5
#define BASE_SKILL_AMOUNT 5

#define ADD_ATTRIBUTES(target, source, attributes) \
	target.attributes.attribute_buffs[source] = attributes; \
	target.attributes.update_attributes(); \

#define REMOVE_ATTRIBUTES(target, source) \
	target.attributes.attribute_buffs -= source; \
	target.attributes.update_attributes(); \

#define HAS_ATTRIBUTES_FROM(target, source) target.attributes.attribute_buffs[source]

#define ADD_SKILLS(target, source, skills) \
	target.attributes.skill_buffs[source] = skills; \
	target.attributes.update_skills(); \

#define REMOVE_SKILLS(target, source) \
	target.attributes.skill_buffs -= source; \
	target.attributes.update_skills(); \

#define HAS_SKILLS_FROM(target, source) target.attributes.skill_buffs[source]

///CHECKS, ROLLS AND SUCH
//Lots of sad duplicate code, but it's not that big of a deal, it's just cause you treat those 2 for checks similarly
/******************ATTRIBUTE RELATED STUFF*************/
#define GET_ATTRIBUTE(target, attribute) target.attributes.total_attributes[attribute]
#define GET_ATTRIBUTE_DELTA(target, attribute) (GET_ATTRIBUTE(target, attribute) - ATTRIBUTE_EQUILIBRIUM)

#define ATTRIBUTE_CHECK(target, attribute, check) GET_ATTRIBUTE(target, attribute) >= check

#define ATTRIBUTE_CHECK_FAIL(target, attribute, check) GET_ATTRIBUTE(target, attribute) < check

#define ATTRIBUTE_CHECK_FAIL_AND_ROLL(target, attribute, check, roll) (ATTRIBUTE_CHECK_FAIL(target, attribute, check)) && prob(roll)

#define ATTRIBUTE_VALUE(target, attribute, base, increment) base + GET_ATTRIBUTE_DELTA(target, attribute) * increment
#define ATTRIBUTE_VALUE_POSITIVE(target, attribute, base, increment) base + max(0,GET_ATTRIBUTE_DELTA(target, attribute)) * increment
#define ATTRIBUTE_VALUE_NEGATIVE(target, attribute, base, increment) base + min(0,GET_ATTRIBUTE_DELTA(target, attribute)) * increment

#define ATTRIBUTE_PERCENTAGE(target, attribute, base, increment) ATTRIBUTE_VALUE/100
#define ATTRIBUTE_PERCENTAGE_POSITIVE(target, attribute, base, increment) ATTRIBUTE_VALUE_POSITIVE/100
#define ATTRIBUTE_PERCENTAGE_NEGATIVE(target, attribute, base, increment) ATTRIBUTE_VALUE_NEGATIVE/100

#define ATTRIBUTE_ROLL(target, attribute, base, increment) prob(ATTRIBUTE_VALUE)
#define ATTRIBUTE_ROLL_POSITIVE(target, attribute, base, increment) prob(ATTRIBUTE_VALUE_POSITIVE)
#define ATTRIBUTE_ROLL_NEGATIVE(target, attribute, base, increment) prob(ATTRIBUTE_VALUE_NEGATIVE)

//It rolls a prob on a skill delta, that is equal to 'base' + the skill delta multiplied by the increment
//For example: Someone has a skill of 7 in medicine and we roll this
//SKILL_ROLL(target, /datum/nice_skill/medicine, 10, 20)
//The delta is 2, so we get 10% base chance and then 40% extra (20 * 2 from delta), resulting in a prob(50)
#define SKILL_ROLL(target, skill, base, increment) prob(SKILL_VALUE)

//Same as above, but only positive deltas matter
#define SKILL_ROLL_POSITIVE(target, skill, base, increment) prob(SKILL_VALUE_POSITIVE)
//Same, but negative deltas
#define SKILL_ROLL_NEGATIVE(target, skill, base, increment) prob(SKILL_VALUE_NEGATIVE)

/******************SKILL RELATED STUFF*************/
#define GET_SKILL(target, skill) target.attributes.total_skills[skill]
#define GET_SKILL_DELTA(target, skill) (GET_SKILL(target, skill) - SKILL_EQUILIBRIUM)

//Binary TRUE/FALSE check on a threshold. If a target has matching value as the check, it'll be TRUE
#define SKILL_CHECK(target, skill, check) GET_SKILL(target, skill) >= check

#define SKILL_CHECK_FAIL(target, skill, check) GET_SKILL(target, skill) < check

#define SKILL_CHECK_FAIL_AND_ROLL(target, skill, check, roll) (SKILL_CHECK_FAIL(target, skill, check)) && prob(roll)

#define SKILL_VALUE(target, skill, base, increment) base + GET_SKILL_DELTA(target, skill) * increment
#define SKILL_VALUE_POSITIVE(target, skill, base, increment) base + max(0,GET_SKILL_DELTA(target, skill)) * increment
#define SKILL_VALUE_NEGATIVE(target, skill, base, increment) base + min(0,GET_SKILL_DELTA(target, skill)) * increment

#define SKILL_PERCENTAGE(target, skill, base, increment) SKILL_VALUE/100
#define SKILL_PERCENTAGE_POSITIVE(target, skill, base, increment) SKILL_VALUE_POSITIVE/100
#define SKILL_PERCENTAGE_NEGATIVE(target, skill, base, increment) SKILL_VALUE_NEGATIVE/100

//It rolls a prob on a skill delta, that is equal to 'base' + the skill delta multiplied by the increment
//For example: Someone has a skill of 7 in medicine and we roll this
//SKILL_ROLL(target, /datum/nice_skill/medicine, 10, 20)
//The delta is 2, so we get 10% base chance and then 40% extra (20 * 2 from delta), resulting in a prob(50)
#define SKILL_ROLL(target, skill, base, increment) prob(SKILL_VALUE)

//Same as above, but only positive deltas matter
#define SKILL_ROLL_POSITIVE(target, skill, base, increment) prob(SKILL_VALUE_POSITIVE)
//Same, but negative deltas
#define SKILL_ROLL_NEGATIVE(target, skill, base, increment) prob(SKILL_VALUE_NEGATIVE)

#define SURGERY_SKILL_BASE 30
#define SURGERY_SKILL_INCREMENT 20
