#define RECIPE_COMPONENT(type) GLOB.recipe_components[type]
#define RECIPE(type) GLOB.recipes[type]

// Appliance types
// Special type which allows the recipe to be performed anywhere.
#define RECIPE_APPLIANCE_ANY "Any"

// Recipe priorities
#define RECIPE_PRIORITY_VERY_HIGH 4000
#define RECIPE_PRIORITY_HIGH 3000
#define RECIPE_PRIORITY_NORMAL 2000
#define RECIPE_PRIORITY_LOW 1000
#define RECIPE_PRIORITY_VERY_LOW 500

// Generic recipe conditionals
#define RECIPE_CONDITION_TEMPERATURE "temp"
