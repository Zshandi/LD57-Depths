extends Node

const PITCH_VOL_NONE := NAN

@export
var default_volume_db:float = 0.0
@export
var default_min_pitch:float = 0.8
@export
var default_max_pitch:float = 1.2

## Plays a stream such that it will persist across scenes.
##
## Generates an [AudioStreamPlayer] based on the [param stream].
## This player is then added as a child of the singleton so that
## it is guaranteed to be persistent. The player is freed after it
## finished playing audio.
##
## [param stream] can be one of:
##  - [String] which is the name of an [AudioStreamPlayer] added as a child
##    of `RegisteredSounds` in the `SoundPlayer` singleton.
##  - [String] which is the path to a sound resource (such as a WAV file)
##  - [AudioStreamPlayer] to be duplicated and played.
func play_stream_persistent(stream:Variant) -> AudioStreamPlayer:
	return _play_stream_internal(stream, true)

## Plays a stream such that it will not persist across scenes.
##
## Generates an [AudioStreamPlayer] based on the [param stream].
## This player is then added as a child of the current scene so that
## it will be removed if the scene is changed. The player is freed after it
## finished playing audio.
##
## [param stream] can be one of:
##  - [String] which is the name of an [AudioStreamPlayer] added as a child
##    of `RegisteredSounds` in the `SoundPlayer` singleton.
##  - [String] which is the path to a sound resource (such as a WAV file)
##  - [AudioStreamPlayer] to be duplicated and played.
func play_stream(stream:Variant) -> AudioStreamPlayer:
	return _play_stream_internal(stream, false)

func _play_stream_internal(stream:Variant, persistent:bool = false) -> AudioStreamPlayer:
	var player := _create_audio_stream_player(stream)
	if persistent:
		add_child(player)
	else:
		get_tree().current_scene.add_child(player)
	_play_and_remove(player)
	return player

func _create_audio_stream_player(stream:Variant) -> AudioStreamPlayer:
	assert(stream is String or stream is AudioStreamPlayer)
	var player:AudioStreamPlayer
	
	if stream is String:
		var node = %RegisteredSounds.find_child(stream)
		if node is AudioStreamPlayer:
			player = node.duplicate()
		else:
			player = AudioStreamPlayerWithSettings.new()
			player.stream = load(stream)
			return player
	else:
		player = stream.duplicate()
	
	return player.duplicate()

func _play_and_remove(player:AudioStreamPlayer) -> void:
	player.finished.connect(func():
		player.queue_free()
		)
	player.play()
