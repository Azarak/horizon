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
	var/frequency_time = 5 SECONDS
	/// How long does the sound play for. MAKE SURE THIS MATCHES FREQUENCY IF LOOPING, if not, make sure it's not bigger than frequency
	var/sound_length = 5 SECONDS
	/// Whether we let byond change the pitch of the played sounds
	var/vary = FALSE
	/// If defined, cooldown between playing a sound between ALL emitters. Dont set this higher than `frequency_time`
	var/cooldown_between_emitters
	/// Whether the ambient sound tries to behave like a loop. Area based ambient emitters can have their frequency multiplied if FALSE.
	var/loops = TRUE
	/// Falloff distance to pass to the played sound
	var/falloff_distance = AMBIENCE_FALLOFF_DISTANCE
	/// Falloff exponent to pass to the played sound
	var/falloff_exponent = AMBIENCE_FALLOFF_EXPONENT
	/// Whether to play the sound from a random position around the user if an area invokes it
	var/random_position_if_area = FALSE

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
	sound_length = 6 SECONDS

/datum/ambient_sound/water
	id = AMBIENT_SOUND_WATER
	sounds = list('sound/ambience/emitters/water/water1.ogg')
	frequency_time = 6 SECONDS
	sound_length = 6 SECONDS

/datum/ambient_sound/heartbeat
	id = AMBIENT_SOUND_HEARTBEAT
	sounds = list('sound/effects/singlebeat.ogg')
	frequency_time = 1 SECONDS
	sound_length = 1 SECONDS
	loops = FALSE //Great looping sound, but can happen at any frequency just fine.

/datum/ambient_sound/sparks //Resembling of an inducer charging
	id = AMBIENT_SOUND_SPARKS
	sounds = list(
		'sound/effects/sparks1.ogg',
		'sound/effects/sparks2.ogg',
		'sound/effects/sparks3.ogg',
		'sound/effects/sparks4.ogg'
		)
	frequency_time = 1 SECONDS
	sound_length = 1 SECONDS

/datum/ambient_sound/thunder
	id = AMBIENT_SOUND_THUNDER
	sounds = list(
		'sound/effects/thunder/thunder1.ogg',
		'sound/effects/thunder/thunder2.ogg',
		'sound/effects/thunder/thunder3.ogg',
		'sound/effects/thunder/thunder4.ogg',
		'sound/effects/thunder/thunder5.ogg',
		'sound/effects/thunder/thunder6.ogg',
		'sound/effects/thunder/thunder7.ogg',
		'sound/effects/thunder/thunder8.ogg',
		'sound/effects/thunder/thunder9.ogg',
		'sound/effects/thunder/thunder10.ogg'
		)
	frequency_time = 40 SECONDS
	sound_length = 7 SECONDS
	loops = FALSE

/datum/ambient_sound/station_creak
	id = AMBIENT_SOUND_STATION_CREAK
	sounds = list(
		'sound/effects/creak1.ogg',
		'sound/effects/creak2.ogg',
		'sound/effects/creak3.ogg'
		)
	frequency_time = 30 SECONDS
	sound_length = 10 SECONDS
	loops = FALSE

/datum/ambient_sound/fire
	id = AMBIENT_SOUND_FIRE
	sounds = list('sound/effects/comfyfire.ogg') //Truly the fiercest fire sound
	frequency_time = 4 SECONDS
	maximum_emitters = 2
	cooldown_between_emitters = 2 SECONDS

/// Obnoxious tcomms ambience, but slightly more bearable now
/datum/ambient_sound/crunchy_server
	id = AMBIENT_SOUND_CRUNCHY_SERVER
	sounds = list(
		'sound/machines/tcomms/tcomms_mid1.ogg',
		'sound/machines/tcomms/tcomms_mid2.ogg',
		'sound/machines/tcomms/tcomms_mid3.ogg',
		'sound/machines/tcomms/tcomms_mid4.ogg',
		'sound/machines/tcomms/tcomms_mid5.ogg',
		'sound/machines/tcomms/tcomms_mid6.ogg',
		'sound/machines/tcomms/tcomms_mid7.ogg'
		)
	frequency_time = 2 SECONDS
	sound_length = 2 SECONDS
	volume = 2
	range = 3

/datum/ambient_sound/server //Nice, subtle hdd crunching
	id = AMBIENT_SOUND_SERVER
	sounds = list(
		'sound/ambience/emitters/server/server1.ogg',
		'sound/ambience/emitters/server/server2.ogg',
		'sound/ambience/emitters/server/server3.ogg'
		)
	frequency_time = 2.8 SECONDS
	sound_length = 2.8 SECONDS
	range = 3
	volume = 15

/datum/ambient_sound/vending
	id = AMBIENT_SOUND_VENDING
	sounds = list(
		'sound/ambience/emitters/vending/vending1.ogg',
		'sound/ambience/emitters/vending/vending2.ogg',
		'sound/ambience/emitters/vending/vending3.ogg',
		'sound/ambience/emitters/vending/vending4.ogg',
		'sound/ambience/emitters/vending/vending5.ogg'
		)
	frequency_time = 2.8 SECONDS
	sound_length = 2.8 SECONDS
	range = 3
	volume = 10
