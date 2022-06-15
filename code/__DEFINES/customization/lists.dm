GLOBAL_LIST_INIT(sprite_accessories, build_sprite_accessory_list())
GLOBAL_LIST_EMPTY(generic_accessories)

GLOBAL_LIST_EMPTY(body_markings)
GLOBAL_LIST_EMPTY_TYPED(body_markings_per_limb, /list)
GLOBAL_LIST_EMPTY(body_marking_sets)

GLOBAL_LIST_EMPTY(loadout_items)
GLOBAL_LIST_EMPTY(loadout_category_to_subcategory_to_items)

GLOBAL_LIST_EMPTY(augment_items)
GLOBAL_LIST_EMPTY(augment_categories_to_slots)
GLOBAL_LIST_EMPTY(augment_slot_to_items)

GLOBAL_LIST_EMPTY(culture_cultures)
GLOBAL_LIST_EMPTY(culture_factions)
GLOBAL_LIST_EMPTY(culture_locations)

/proc/build_sprite_accessory_list()
	// Here we build the global list for all accessories
    var/list/accessory_list = list()
    for(var/path in typesof(/datum/sprite_accessory))
        if(is_abstract(path))
            continue
        accessory_list[path] = new path()
    return accessory_list
