//Could be bitflags, but that would require a good amount of translations, which eh, either way works for me
#define TAG_COMBAT "combat"
#define TAG_SPOOKY "spooky"
#define TAG_DESTRUCTIVE "destructive"
#define TAG_COMMUNAL "communal"
#define TAG_TARGETED "targeted"
#define TAG_POSITIVE "positive"
#define TAG_OVERMAP "overmap"
#define TAG_SPACE "space"
#define TAG_PLANETARY "planetary"

#define EVENT_TRACK_MUNDANE "track_mundane"
#define EVENT_TRACK_MODERATE "track_moderate"
#define EVENT_TRACK_MAJOR "track_major"
#define EVENT_TRACK_ROLESET "track_roleset"
#define EVENT_TRACK_OBJECTIVES "track_objectives"

#define STORYTELLER_WAIT_TIME 20 SECONDS

#define EVENT_POINT_GAINED_PER_SECOND 0.05

#define EVENT_TRACKS list(EVENT_TRACK_MUNDANE, EVENT_TRACK_MODERATE, EVENT_TRACK_MAJOR, EVENT_TRACK_ROLESET, EVENT_TRACK_OBJECTIVES)
