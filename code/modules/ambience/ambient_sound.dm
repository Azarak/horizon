/datum/ambient_sound
	/// ID of the ambient sound.
	var/id
	/// Paths to the sounds to be picked from.
	var/list/sounds
	/// Volume of the ambient sound to be played.
	var/volume = 20
	/// Maximum range an ambient sound may play from.
	var/range = 5
	/// How many ambience emitters can be playing this at once.
	var/maximum_emitters = 1
	/// How often does the sound play. In seconds.
	var/frequency_time = 5 SECONDS
	/// Whether we let byond change the pitch of the played sounds
	var/vary = FALSE

/datum/ambient_sound/lava
	id = AMBIENT_SOUND_LAVA
	sounds = list(
		'sound/ambience/emitters/lava/lava1.ogg',
		'sound/ambience/emitters/lava/lava2.ogg',
		'sound/ambience/emitters/lava/lava3.ogg',
		'sound/ambience/emitters/lava/lava4.ogg',
		'sound/ambience/emitters/lava/lava5.ogg'
		)
	frequency_time = 7 SECONDS

/datum/ambient_sound/water
	id = AMBIENT_SOUND_WATER
	sounds = list('sound/ambience/emitters/water/water1.ogg')
	frequency_time = 7 SECONDS
