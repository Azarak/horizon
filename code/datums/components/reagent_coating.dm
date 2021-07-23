#define REAGENT_COATING_VOLUME 30

/datum/component/reagent_coating
	///The reagents datum that holds the reagents for this coating
	var/datum/reagents/reagents
	var/color
	var/chat_color
	var/static/list/item_splatter_appearances = list()
	var/obj/item/item
	///Add flags that are inherited from some property from obj/item? Whether it's able to be polished to be cleaned (helmets, hardsuits), or other properties
	var/suffix

/datum/component/reagent_coating/Initialize(suffix = "default")
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.suffix = suffix
	item = parent
	reagents = new(REAGENT_COATING_VOLUME, NO_REACT)
	reagents.my_atom = parent
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/AppendOverlay)
	RegisterSignal(parent, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/GetExamineName)
	RegisterSignal(parent, COMSIG_ITEM_UPDATE_WORN_OVERLAYS, .proc/AppendWornOverlay)
	RegisterSignal(parent, COMSIG_ITEM_STAIN_REAGENTS, .proc/StainReagents)
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/CleanAct)

/datum/component/reagent_coating/Destroy()
	UnregisterSignal(parent, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ITEM_STAIN_REAGENTS, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_GET_EXAMINE_NAME, COMSIG_ITEM_UPDATE_WORN_OVERLAYS))
	item = null
	QDEL_NULL(reagents)
	return ..()

/datum/component/reagent_coating/proc/CleanAct(datum/source, clean_types)
	SIGNAL_HANDLER
	var/weak_clean = (clean_types & CLEAN_TYPE_WEAK) ? TRUE : FALSE
	var/total_volume_cache = reagents.total_volume
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		if(!(clean_types & reagent.clean_type))
			continue
		var/removed_volume = weak_clean ? ((reagent.volume / total_volume_cache * WEAK_CLEAN_PERCENT_AMOUNT) * reagent.volume + WEAK_CLEAN_BASE_AMOUNT) : reagent.volume
		reagents.remove_reagent(reagent.type, removed_volume)
	if(reagents.total_volume > 0)
		item.update_appearance()
		item.update_slot_icon()
		return
	//All cleaned! delete self
	var/obj/item/item_cache = item //item will be null after qdel(src)
	QDEL_NULL(reagents)
	qdel(src)
	item_cache.update_appearance()
	item_cache.update_slot_icon()

/datum/component/reagent_coating/proc/StainReagents(datum/source, datum/reagents/stained)
	SIGNAL_HANDLER
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space < MINIMUM_REAGENT_COAT_VOLUME)
		reagents.remove_all(MINIMUM_REAGENT_COAT_VOLUME)
	stained.trans_to(reagents, MINIMUM_REAGENT_COAT_VOLUME)
	color = mix_color_from_reagents(reagents.reagent_list)
	var/sanitized_color = copytext(color, 1, 8) //Removes alpha
	var/temp_hsv = RGBtoHSV(sanitized_color)
	var/list/read_hsv = ReadHSV(temp_hsv)
	if(read_hsv[3] < REAGENT_COATING_CHAT_TEXT_LUMINOSITY)
		read_hsv[3] = REAGENT_COATING_CHAT_TEXT_LUMINOSITY
		chat_color = HSVtoRGB(hsv(read_hsv[1], read_hsv[2], read_hsv[3]))
	else
		chat_color = sanitized_color
	item.update_appearance()
	item.update_slot_icon()
	return

/datum/component/reagent_coating/proc/GetExamineName(datum/source, mob/user, list/override)
	SIGNAL_HANDLER
	override[EXAMINE_POSITION_ARTICLE] = item.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " <font color = [chat_color]>stained</font> "
	return COMPONENT_EXNAME_CHANGED

/datum/component/reagent_coating/proc/AppendOverlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	var/icon = item.icon
	var/icon_state = item.icon_state
	var/index = "[REF(icon)]-[icon_state]"
	var/mutable_appearance/pic = item_splatter_appearances[index]
	if(!pic)
		var/icon/splatter_icon = icon(icon, icon_state, , 1)
		splatter_icon.Blend("#FFF", ICON_ADD) //fills the icon_state with white (except where it's transparent)
		splatter_icon.Blend(icon('icons/effects/reagent_coating.dmi', "item_stain"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		pic = mutable_appearance(splatter_icon, icon_state)
		item_splatter_appearances[index] = pic
	//Needs to make a new appearance otherwise it will be managed improperly
	var/mutable_appearance/new_overlay = mutable_appearance(pic.icon, pic.icon_state)
	new_overlay.color = color
	new_overlay.appearance_flags = RESET_COLOR
	overlays += new_overlay

/datum/component/reagent_coating/proc/AppendWornOverlay(datum/source, list/overlays, isinhands, mutant_variant, bodytype, worn_slot)
	SIGNAL_HANDLER
	if(isinhands)
		return
	var/slot_affix
	switch(worn_slot)
		if(ITEM_SLOT_OCLOTHING)
			slot_affix = "suit"
		if(ITEM_SLOT_ICLOTHING)
			slot_affix = "uniform"
		if(ITEM_SLOT_GLOVES)
			slot_affix = "gloves"
		if(ITEM_SLOT_EYES)
			slot_affix = "eyes"
		if(ITEM_SLOT_MASK)
			slot_affix = "mask"
		if(ITEM_SLOT_HEAD)
			slot_affix = "head"
		if(ITEM_SLOT_NECK)
			slot_affix = "neck"
		if(ITEM_SLOT_FEET)
			if(mutant_variant == STYLE_DIGITIGRADE)
				slot_affix = "feet_digi"
			else
				slot_affix = "feet"
	if(!slot_affix)
		return

	var/mutable_appearance/muta = mutable_appearance('icons/effects/reagent_coating.dmi', "[slot_affix]_[suffix]")
	muta.color = color
	muta.appearance_flags = RESET_COLOR
	var/wide_icon = FALSE
	if(isclothing(item))
		var/obj/item/clothing/clothing = item
		if(clothing.clothing_flags & LARGE_WORN_ICON)
			wide_icon = TRUE
	if(mutant_variant & STYLE_TAUR_ALL || wide_icon)
		muta.pixel_x = 16
	overlays += muta

///Abstract parent type for coating components that care about being equipped on a carbon
/datum/component/reagent_coating/equip
	var/mob/living/carbon/wearer
	var/equipped_slot
	var/next_eye_splash = 0

/datum/component/reagent_coating/equip/Initialize(suffix = "default")
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/OnEquip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/OnDrop)
	//Because checking of item slots is so terrible, just hardcode cases you're expecting
	if(iscarbon(item.loc))
		var/mob/living/carbon/carbon_owner = item.loc
		if(carbon_owner.shoes == item)
			DoEquip(carbon_owner, ITEM_SLOT_FEET)
		if(carbon_owner.head == item)
			DoEquip(carbon_owner, ITEM_SLOT_HEAD)
		if(carbon_owner.glasses == item)
			DoEquip(carbon_owner, ITEM_SLOT_EYES)

/datum/component/reagent_coating/equip/proc/DoEquip(mob/equipper, slot)
	wearer = equipper
	equipped_slot = slot
	OnRegister()

/datum/component/reagent_coating/equip/proc/OnEquip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!(item.slot_flags & slot))
		return
	if(!iscarbon(equipper))
		return
	DoEquip(equipper, slot)

/datum/component/reagent_coating/equip/proc/OnDrop(datum/source, mob/dropper)
	SIGNAL_HANDLER
	if(!wearer)
		return
	OnUnregister()
	wearer = null
	equipped_slot = null

/datum/component/reagent_coating/equip/Destroy()
	if(wearer)
		OnUnregister()
		wearer = null
		equipped_slot = null
	return ..()

/datum/component/reagent_coating/equip/proc/OnRegister()
	return

/datum/component/reagent_coating/equip/proc/OnUnregister()
	return

///Feet cover subtype, will make footsteps of the reagents color if the coating is fresh enough
/datum/component/reagent_coating/equip/feetcover

/datum/component/reagent_coating/equip/feetcover/OnRegister()
	return

/datum/component/reagent_coating/equip/feetcover/OnUnregister()
	return

///Eye cover subtype, adds a screen overlay to anyone who's wearing those
/datum/component/reagent_coating/equip/eyecover

/datum/component/reagent_coating/equip/eyecover/OnRegister()
	if(color)
		var/atom/movable/mask = wearer.overlay_fullscreen("reagent_eyecover_[color]", /atom/movable/screen/fullscreen/stained)
		mask.color = color

/datum/component/reagent_coating/equip/eyecover/OnUnregister()
	if(color)
		wearer.clear_fullscreen("reagent_eyecover_[color]")

/datum/component/reagent_coating/equip/eyecover/StainReagents(datum/source, datum/reagents/stained)
	SIGNAL_HANDLER
	if(wearer && color)
		wearer.clear_fullscreen("reagent_eyecover_[color]")
	var/splash_color = mix_color_from_reagents(stained.reagent_list)
	. = ..()
	if(wearer && color)
		if(world.time >= next_eye_splash)
			next_eye_splash = world.time + 30 SECONDS
			var/atom/movable/flashmask = wearer.overlay_fullscreen("reagent_eyecover_flash_[splash_color]", /atom/movable/screen/fullscreen/stained_flash)
			flashmask.color = splash_color
			wearer.clear_fullscreen("reagent_eyecover_flash_[splash_color]", 16)

		var/atom/movable/mask = wearer.overlay_fullscreen("reagent_eyecover_[color]", /atom/movable/screen/fullscreen/stained)
		mask.color = color

#undef REAGENT_COATING_VOLUME
