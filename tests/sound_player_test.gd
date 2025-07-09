extends Node2D

func _ready() -> void:
	get_viewport().snap_2d_vertices_to_pixel = false
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	
	# Account for scene to finish loading
	await get_tree().create_timer(0.1).timeout
	
	var last_played_sound:AudioStreamPlayer
	
	var starting_nodes := get_tree().get_node_count()
	
	write_log("Testing play_stream($AudioStreamPlayerWithSettings)")
	write_log("Listen for 4 quick then 2 slow, varied pitch")
	await test_method(func(): return SoundPlayer.play_stream($AudioStreamPlayerWithSettings))
	
	write_log("Testing play_stream(\"TestSound\")")
	write_log("Listen for 4 quick then 2 slow, same pitch")
	await test_method(func(): return SoundPlayer.play_stream("TestSound"))
	
	write_log("Testing play_stream(\"res://assets/sounds/crab death underwater.wav\")")
	write_log("Listen for 4 quick then 2 slow, varied pitch")
	await test_method(func(): return SoundPlayer.play_stream("res://assets/sounds/crab death underwater.wav"))
	
	
	write_log("Testing play_stream_persistent($AudioStreamPlayerWithSettings)")
	write_log("Listen for 4 quick then 2 slow, varied pitch")
	await test_method(func(): return SoundPlayer.play_stream_persistent($AudioStreamPlayerWithSettings))
	
	write_log("Testing play_stream_persistent(\"TestSound\")")
	write_log("Listen for 4 quick then 2 slow, same pitch")
	await test_method(func(): return SoundPlayer.play_stream_persistent("TestSound"))
	
	write_log("Testing play_stream_persistent(\"res://assets/sounds/crab death underwater.wav\")")
	write_log("Listen for 4 quick then 2 slow, varied pitch")
	await test_method(func(): return SoundPlayer.play_stream_persistent("res://assets/sounds/crab death underwater.wav"))
	
	write_log("Done!")

func test_method(play_stream_callback:Callable) -> void:
	await get_tree().create_timer(0.5).timeout
	var starting_nodes := get_tree().get_node_count()
	for i in range(0, 3):
		play_stream_callback.call()
		await get_tree().create_timer(0.25).timeout
	for i in range(0, 3):
		await play_stream_callback.call().finished
		await get_tree().create_timer(0.1).timeout
	await check_node_count(starting_nodes)
	await get_tree().create_timer(0.5).timeout

func check_node_count(starting_nodes:int) -> void:
	await get_tree().create_timer(0.1).timeout
	if get_tree().get_node_count() > starting_nodes:
		write_log("ERROR: current nodes > starting nodes: " + str(get_tree().get_node_count()) + " > " + str(starting_nodes))
	else:
		write_log("node count good")

func write_log(text:String):
	if %Label.text != "":
		%Label.text += "\n"
	%Label.text += text
