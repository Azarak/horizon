/datum/ambient_sound
	/// ID of the ambient sound.
	var/id
	/// Paths to the sounds to be picked from.
	var/list/sounds
	/// Volume of the ambient sound to be played.
	var/volume = 30
	/// Maximum range an ambient sound may play from.
	var/range = 5
	/// How many ambience emitters can be playing this at once.
	var/maximum_emitters = 1
	/// How often does the sound play. In seconds.
	var/frequency_time = 5 SECONDS //1 to 10 seconds loops are ideal for the system
	/// Whether we let byond change the pitch of the played sounds
	var/vary = FALSE
	/// If defined, cooldown between different emitters for emitting this sound
	var/cooldown_between_emitters
	/// If defined, it'll be a chance to play the sound, to add variance and scarcity to more one-off and random ambiences
	var/emission_chance
	/// Whether the ambient sound tries to behave like a loop. Area based ambient emitters can have their frequency multiplied if FALSE.
	var/loop_like = TRUE

/datum/ambient_sound/lava
	id = AMBIENT_SOUND_LAVA
	volume = 40
	sounds = list(
		'sound/ambience/emitters/lava/lava1.ogg',
		'sound/ambience/emitters/lava/lava2.ogg',
		'sound/ambience/emitters/lava/lava3.ogg',
		'sound/ambience/emitters/lava/lava4.ogg',
		'sound/ambience/emitters/lava/lava5.ogg'
		)
	frequency_time = 6 SECONDS

/datum/ambient_sound/water
	id = AMBIENT_SOUND_WATER
	sounds = list('sound/ambience/emitters/water/water1.ogg')
	frequency_time = 6 SECONDS
