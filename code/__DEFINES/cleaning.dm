
// Cleaning flags

// Different kinds of things that can be cleaned.
// Use these when overriding the wash proc or registering for the clean signals to check if your thing should be cleaned
/// Cleans blood decals off of the cleanable atom. For bloodstains and blood DNA you need CLEAN_TYPE_CHEMICAL_WASH
#define CLEAN_TYPE_BLOOD (1 << 0)
/// Cleans runes off of the cleanable atom.
#define CLEAN_TYPE_RUNES (1 << 1)
/// Cleans fingerprints off of the cleanable atom.
#define CLEAN_TYPE_FINGERPRINTS (1 << 2)
/// Cleans fibres off of the cleanable atom.
#define CLEAN_TYPE_FIBERS (1 << 3)
/// Cleans radiation off of the cleanable atom.
#define CLEAN_TYPE_RADIATION (1 << 4)
/// Cleans diseases off of the cleanable atom.
#define CLEAN_TYPE_DISEASE (1 << 5)
/// Special type, add this flag to make some cleaning processes non-instant. Currently only used for showers when removing radiation.
#define CLEAN_TYPE_WEAK (1 << 6)
/// Cleans paint off of the cleanable atom.
#define CLEAN_TYPE_PAINT (1 << 7)
/// Cleans acid off of the cleanable atom.
#define CLEAN_TYPE_ACID (1 << 8)
/// Cleans decals such as dirt and oil off the floor
#define CLEAN_TYPE_LIGHT_DECAL (1 << 9)
/// Cleans decals such as cobwebs off the floor
#define CLEAN_TYPE_HARD_DECAL (1 << 10)
/// Defines for cleaning reagent coatings
/// Cleaned with warmth, dried basically
#define CLEAN_TYPE_DRY_WASH (1 << 11)
/// Cleaned with water and some pressure
#define CLEAN_TYPE_WET_WASH (1 << 12)
/// Cleaned with chemical agents
#define CLEAN_TYPE_CHEMICAL_WASH (1 << 13)

// Different cleaning methods.
// Use these when calling the wash proc for your cleaning apparatus
#define CLEAN_WASH (CLEAN_TYPE_BLOOD | CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID | CLEAN_TYPE_LIGHT_DECAL)
#define CLEAN_SCRUB (CLEAN_WASH | CLEAN_TYPE_FINGERPRINTS | CLEAN_TYPE_FIBERS | CLEAN_TYPE_PAINT | CLEAN_TYPE_HARD_DECAL)
#define CLEAN_RAD CLEAN_TYPE_RADIATION
#define CLEAN_SHOWER (CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID | CLEAN_TYPE_LIGHT_DECAL | CLEAN_TYPE_WET_WASH | CLEAN_TYPE_WEAK | CLEAN_TYPE_RADIATION)
#define CLEAN_WASHING_MACHINE (CLEAN_TYPE_DRY_WASH | CLEAN_TYPE_PAINT | CLEAN_TYPE_BLOOD | CLEAN_TYPE_RUNES | CLEAN_TYPE_DISEASE | CLEAN_TYPE_ACID | CLEAN_TYPE_LIGHT_DECAL | CLEAN_TYPE_WET_WASH | CLEAN_TYPE_CHEMICAL_WASH | CLEAN_TYPE_RADIATION)
#define CLEAN_SOAP (CLEAN_WASHING_MACHINE)
#define CLEAN_ALL (ALL & ~CLEAN_TYPE_WEAK)
