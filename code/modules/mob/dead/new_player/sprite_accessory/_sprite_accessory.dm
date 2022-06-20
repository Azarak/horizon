/datum/sprite_accessory
	abstract_type = /datum/sprite_accessory
	/// Name of the sprite accessories, which may be presented to pick from in the preferences menu
	var/name
	/// Icon file of the accessory
	var/icon
	/// Icon state of the accessory
	var/icon_state
	/// Whether the states for this accessory have an extra state that will get overlayed ontop of the resulting state. Per layer, suffix "_extra"
	var/extra_state = FALSE
	/// Pixel x offset
	var/pixel_x = 0
	/// Pixel y offset
	var/pixel_y = 0
	/// Layer of the accessory
	var/layer = BODY_LAYER
	/// Relevant layers. If this is defined, instead of a single image the code will generate an image for each defined layer, with a suffix for the layer.
	var/list/relevant_layers
	/// Amount of color keys this accessory uses.
	var/color_keys = 1
	/// Color key name to describe a single customizable color key.
	var/color_key_name = "Accessory"
	/// List of names for color keys, required if you use more than 1. This is to present the user with how every color will affect the accessory.
	var/list/color_key_names
	/// Whether this accessory has gendered variants. This will add either a "m_" or "f_" prefix if TRUE, depending on gender. No prefix if FALSE
	var/gendered_variants = FALSE
	/// List of generated overlays based on the [type x icon_state x colors] combination.
	var/static/list/accessory_overlay_cache = list()

/datum/sprite_accessory/New()
	if(color_keys > 1)
		if(!color_key_names)
			stack_trace("Sprite accessory of [type] has more than 1 color key but doesn't have a color key name list")
		else if (color_key_names.len < color_keys)
			stack_trace("Sprite accessory of [type] has missing color key names")
	return ..()

/datum/sprite_accessory/proc/validate_organ_color_keys(obj/item/organ/organ)
	if(!color_keys)
		return
	var/list/color_list = color_string_to_list(organ.accessory_colors)
	if(color_list && color_list.len == color_keys)
		return

	var/list/new_color_list = list()
	for(var/i in 1 to color_keys)
		new_color_list += get_color_for_color_key(color_keys, organ.owner)
	organ.accessory_colors = color_list_to_string(new_color_list)

/datum/sprite_accessory/proc/get_color_for_color_key(color_key, mob/living/carbon/owner)
	return "#FFFFFF"

/// Gets the appearance of the sprite accessory as a mutable appearance for an organ on a bodypart.
/datum/sprite_accessory/proc/get_appearance(obj/item/organ/organ, obj/item/bodypart/bodypart)
	var/mob/living/carbon/owner = organ.owner
	var/icon_state_to_use = get_icon_state(organ, bodypart, owner)
	if(!icon_state_to_use)
		return null
	var/color_string = organ.accessory_colors
	return get_overlay(icon_state_to_use, color_string)

/datum/sprite_accessory/proc/get_overlay(overlay_icon_state, color_string)
	color_string = sanitize_color_string(color_string)
	var/key = "[type]-[overlay_icon_state]-[color_string]"
	if(!accessory_overlay_cache[key])
		accessory_overlay_cache[key] = generate_overlay(overlay_icon_state, color_string)
	return accessory_overlay_cache[key]

/datum/sprite_accessory/proc/sanitize_color_string(color_string)
	var/list/color_list = color_string_to_list(color_string)
	if(!color_list)
		color_list = list()
	if(color_list.len < color_keys)
		//stack_trace("Sprite accessory [type] was passed an insufficient amount of colors.")
		while(color_list.len < color_keys)
			color_list += "#FFFFFF"
	else if(color_list.len > color_keys)
		//stack_trace("Sprite accessory [type] was passed too much of colors.")
		while(color_list.len > color_keys)
			color_list -= color_list[color_list.len]
	return color_list_to_string(color_list)

/datum/sprite_accessory/proc/generate_overlay(overlay_icon_state, color_string)
	var/mutable_appearance/appearance
	var/list/color_list = color_string_to_list(color_string)
	if(relevant_layers)
		for(var/iterated_layer in relevant_layers)
			var/mutable_appearance/layer_appearance = generate_overlay_layer(overlay_icon_state, color_list, iterated_layer, get_layer_suffix(iterated_layer))
			if(appearance == null)
				appearance = layer_appearance
			else
				appearance.overlays += layer_appearance
	else
		appearance = generate_overlay_layer(overlay_icon_state, color_list, layer)
	return appearance

/datum/sprite_accessory/proc/generate_overlay_layer(overlay_icon_state, color_list, passed_layer, suffix)
	var/one_color = (color_keys == 1)
	if(suffix)
		overlay_icon_state += "_[suffix]"
	var/icon/result_icon
	var/result_state
	for(var/color_index in 1 to color_keys)
		var/color_to_use = color_list[color_index]
		var/lookup_state = one_color ? overlay_icon_state  : "[overlay_icon_state]_[color_index]"
		var/icon/color_key_icon = icon(icon, lookup_state)
		color_key_icon.Blend(color_to_use, ICON_MULTIPLY)
		if(!result_icon)
			result_icon = icon(color_key_icon)
			result_state = lookup_state
		else
			result_icon.Blend(color_key_icon, ICON_OVERLAY)
	
	// Blend the extra state on top if we want that.
	if(extra_state)
		var/icon/extra_icon = icon(icon, "[overlay_icon_state]_extra")
		result_icon.Blend(extra_icon, ICON_OVERLAY)

	// Apparently new icons can do weird stuff unless you try and "read" something from it like this before using it.
	result_icon.GetPixel(1, 1)
	var/mutable_appearance/layer_appearance = mutable_appearance(result_icon, result_state, layer = -passed_layer)
	layer_appearance.overlays += emissive_blocker(result_icon, result_state)

	// TODO: add emissive overlays here.

	layer_appearance.pixel_x = pixel_x
	layer_appearance.pixel_y = pixel_y

	return layer_appearance

/datum/sprite_accessory/proc/get_layer_suffix(passed_layer)
	switch(passed_layer)
		if(BODY_FRONT_LAYER)
			return "FRONT"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		else
			CRASH("Tried to get an unimplemented layer suffix for sprite accessory of type [type]")

/datum/sprite_accessory/proc/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	return icon_state

#ifdef UNIT_TESTS

/datum/sprite_accessory/proc/unit_testing_possible_icon_states()
	var/list/icon_states = list()
	var/list/final_states = list()
	var/list/layer_suffixes = list()
	unit_testing_icon_states(icon_states)

	if(relevant_layers)
		for(var/layer in relevant_layers)
			layer_suffixes = get_layer_suffix(layer)

	for(var/state in icon_states)
		for(var/color_index in 1 to color_keys)
			var/color_suffix = ""
			if(color_keys !=)
				color_suffix = "_[i]"
			if(length(layer_suffixes))
				for(var/layer_suffix in layer_suffixes)
					var/final_state = "[state]_[layer_suffix][color_suffix]"
					final_states += final_state
					if(extra_state)
						final_states += "[final_state]_extra"
			else
				final_state = "[state]_[color_suffix]"
				final_states += final_state
				if(extra_state)
					final_states += "[final_state]_extra"

	return final_states

/datum/sprite_accessory/proc/unit_testing_icon_states(list/states)
	states += icon_state

#endif

/// None state which just means no appearance. Exists for easier manipulation so we dont have to write cases for customizng into a null type.
/datum/sprite_accessory/none
	name = "None"
	color_keys = 0
	icon = null
	icon_state = null
