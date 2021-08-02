/datum/component/stain_stepper
	/// The parent item but casted into atom type for easier use.
	var/obj/item/clothing/parent_clothing
	/// The ITEM_SLOT_* slot the item is equipped on, if it is.
	var/equipped_slot
	/// Wearer
	var/mob/living/carbon/wearer

/datum/component/stain_stepper/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	parent_clothing = parent
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/OnEquip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/OnDrop)

/datum/component/stain_stepper/proc/OnEquip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!(parent_clothing.slot_flags & slot))
		return
	if(!iscarbon(equipper))
		return
	wearer = equipper
	equipped_slot = slot
	RegisterSignal(wearer, COMSIG_STEP_ON_BLOOD, .proc/OnStepBlood)

/datum/component/stain_stepper/proc/OnDrop(datum/source, mob/dropper)
	SIGNAL_HANDLER
	if(!wearer)
		return
	UnregisterSignal(wearer, COMSIG_STEP_ON_BLOOD)
	wearer = null
	equipped_slot = null

/datum/component/stain_stepper/proc/OnStepBlood(datum/source, obj/effect/decal/cleanable/pool)
	SIGNAL_HANDLER
	if(wearer.check_obscured_slots(TRUE) & equipped_slot)
		return
	if(HAS_TRAIT(wearer, TRAIT_LIGHT_STEP)) //the character is agile enough to don't mess their clothing and hands just from one blood splatter at floor
		return

	parent_clothing.add_blood_DNA(pool.return_blood_DNA())

/datum/component/stain_stepper_mob
	///Parent casted into carbon
	var/mob/living/carbon/carbon_parent

/datum/component/stain_stepper_mob/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	carbon_parent = parent
	RegisterSignal(carbon_parent, COMSIG_STEP_ON_BLOOD, .proc/OnStepBlood)

/datum/component/stain_stepper_mob/Destroy()
	UnregisterSignal(carbon_parent, COMSIG_STEP_ON_BLOOD)
	return ..()

/datum/component/stain_stepper_mob/proc/OnStepBlood(datum/source, obj/effect/decal/cleanable/pool)
	SIGNAL_HANDLER
	if(carbon_parent.shoes?.body_parts_covered & FEET)
		return
	if(carbon_parent.check_obscured_slots(TRUE) & ITEM_SLOT_FEET)
		return
	if(HAS_TRAIT(carbon_parent, TRAIT_LIGHT_STEP)) //the character is agile enough to don't mess their clothing and hands just from one blood splatter at floor
		return TRUE
	message_admins("implement feet bodypart stain here")
