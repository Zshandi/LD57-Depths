extends Node

var music_volume:float:
	get:
		var index = AudioServer.get_bus_index(&"Music")
		return db_to_linear(AudioServer.get_bus_volume_db(index))
	set(value):
		var index = AudioServer.get_bus_index(&"Music")
		AudioServer.set_bus_volume_db(index, linear_to_db(value))

var sound_volume:float:
	get:
		var index = AudioServer.get_bus_index(&"Master")
		return db_to_linear(AudioServer.get_bus_volume_db(index))
	set(value):
		var index = AudioServer.get_bus_index(&"Master")
		AudioServer.set_bus_volume_db(index, linear_to_db(value))

var last_windowed_mode := DisplayServer.WINDOW_MODE_WINDOWED

var is_full_screen:bool:
	get:
		return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	set(value):
		if value == is_full_screen: return
		if (value):
			last_windowed_mode = DisplayServer.window_get_mode()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(last_windowed_mode)

func save_settings() -> void:
	var save_dict := {}
	save_dict["music_volume"] = music_volume
	save_dict["sound_volume"] = sound_volume
	save_dict["is_full_screen"] = is_full_screen
	
	var save_file := FileAccess.open("user://settings", FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func load_settings() -> void:
	if !FileAccess.file_exists("user://settings"):
		# If no settings have been saved, leave values as default
		print_debug("Loading default settings...")
		return
	
	var save_file := FileAccess.open("user://settings", FileAccess.READ)
	var save_dict:Dictionary = save_file.get_var()
	
	music_volume = save_dict["music_volume"]
	sound_volume = save_dict["sound_volume"]
	is_full_screen = save_dict["is_full_screen"]

func _ready() -> void:
	load_settings()
