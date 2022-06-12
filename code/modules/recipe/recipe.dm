/// A recipe which implements a way to create something from components, be it effects or items
/datum/recipe
	abstract_type = /datum/recipe
	// Required appliance to perform this recipe.
	var/appliance
	// Priority in which this recipe should be checked for. Broader recipes should have lower priorities, while more specific ones higher.
	var/priority = RECIPE_PRIORITY_NORMAL
	// List of recipe_component's, all of them need to pass for the recipe to be completed.
	var/list/components

// What should be the arguments that pass into recipe checking?
// This needs to be broad as the system is supposed to cover a large and abstract functionality
// - List of items that are being mixed
// - Location at which its being performed
// - Reagents.. do we want to read reagents from passed item containers or something else?
//		- Perhaps we want to be able to read reagents from items and reagents from some other abstract way?
// - Abstract list of conditionals (such as oven temperature etc.)
// - Nearby related turf locations?
//		- So a recipe condition can check if there's something nearby,
			//but perhaps all we need is location, and we can get turf location from the location, 
			// yeah that's better
/datum/recipe/proc/check_recipe()
	return FALSE
