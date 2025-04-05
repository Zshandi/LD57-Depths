extends Node

var audio_player:AudioStreamPlayer

var playing := false

var timer := Timer.new()

func _ready() -> void:
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_player = create_audio_player()
	audio_player.finished.connect(_audio_player_finished)
	get_tree().root.add_child.call_deferred(audio_player)
	get_tree().root.add_child.call_deferred(timer)

func create_audio_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = preload("res://assets/music/whispering-vinyl-loops-lofi-beats-281193.mp3")
	player.bus = &"Music"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	return player

func play() -> void:
	if !playing:
		playing = true
		audio_player.play()
	if audio_player.process_mode == Node.PROCESS_MODE_DISABLED:
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		timer.process_mode = Node.PROCESS_MODE_ALWAYS

func pause():
	if !playing: return
	audio_player.process_mode = Node.PROCESS_MODE_DISABLED
	timer.process_mode = Node.PROCESS_MODE_DISABLED

func stop():
	playing = false
	audio_player.stop()
	timer.stop()

func _audio_player_finished():
	if playing:
		timer.start(27)
		await timer.timeout
		if playing and !audio_player.playing:
			audio_player.play()
