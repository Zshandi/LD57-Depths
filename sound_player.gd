extends Node

func play_bubble_movement() -> AudioStreamPlayer:
	return play_stream("res://assets/sounds/Bubble bloop.wav")

func play_bubble_collect() -> AudioStreamPlayer:
	return play_stream("res://assets/sounds/Bubble bloop high (echo).wav", 6)

func play_stream_persistant(stream_name:String, volume_db:float) -> AudioStreamPlayer:
	var player := create_stream(stream_name, volume_db)
	add_child(player)
	play_and_remove(player)
	return player

func play_stream(stream_name:String, volume_db:float = 0) -> AudioStreamPlayer:
	var player := create_stream(stream_name, volume_db)
	get_tree().current_scene.add_child(player)
	play_and_remove(player)
	return player

func create_stream(stream_name:String, volume_db:float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(stream_name)
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.8, 1.2)
	return player

func play_and_remove(player:AudioStreamPlayer) -> void:
	player.finished.connect(func():
		player.queue_free()
		)
	player.play()
