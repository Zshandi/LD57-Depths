@tool
extends VBoxContainer

signal back_button_pressed

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

enum AntiAliasingSetting
{
	NONE, # No anti-aliasing
	LOW,  # 2x MSAA & Screen Space AA
	MEDIUM, # 4x MSAA, Screen Space AA, and TAA
	HIGH # 8x MSAA, Screen Space AA, and TAA
}

var anti_aliasing := AntiAliasingSetting.NONE:
	get:
		return anti_aliasing
	set(value):
		anti_aliasing = value
		match value:
			AntiAliasingSetting.NONE:
				get_viewport().use_taa = false
				get_viewport().msaa_2d = Viewport.MSAA_DISABLED
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			AntiAliasingSetting.LOW:
				get_viewport().use_taa = false
				get_viewport().msaa_2d = Viewport.MSAA_2X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			AntiAliasingSetting.MEDIUM:
				get_viewport().use_taa = true
				get_viewport().msaa_2d = Viewport.MSAA_4X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			AntiAliasingSetting.HIGH:
				get_viewport().use_taa = true
				get_viewport().msaa_2d = Viewport.MSAA_8X
				get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

var music_sample:AudioStreamPlayer
var music_sample_fade:Tween = null

func _ready() -> void:pass
	#if Engine.is_editor_hint():
		#return
	#
	#music_sample = MusicPlayer.create_audio_player()
	#
	## Default values
	#
	##if OS.has_feature("pc"):
		### Default to Medium anti-aliasing on Desktop
		##anti_aliasing = AntiAliasingSetting.MEDIUM
	##elif OS.has_feature("web"):
		### compatibility renderer used for web does not yet support anti-aliasing
		##%AntiAliasing.hide()
	#music_volume = 0.7
	#sound_volume = 0.7
	#
	#load_settings()
	#update_full_screen_text()
	#%MusicVolumeSlider.set_value_no_signal(music_volume)
	#%SoundVolumeSlider.set_value_no_signal(sound_volume)
	#%AntiAliasingButton.select(anti_aliasing as int)
	#
	#add_child(music_sample)

func update_full_screen_text():
	if is_full_screen:
		$FullscreenToggle.text = "Full Screen Enabled"
	else:
		$FullscreenToggle.text = "Full Screen Disabled"

func _on_fullscreen_toggle_pressed() -> void:
	is_full_screen = !is_full_screen
	# Hack: In web, the DisplayServer.window_get_mode() does not update immediately
	await get_tree().create_timer(0.05).timeout
	update_full_screen_text()
	save_settings()

func _on_music_volume_slider_value_changed(value: float) -> void:
	music_volume = value
	save_settings()
	# Play the music sampler
	if !music_sample.playing:
		music_sample.play()
	reset_music_sample_fade()
	# Fade the volume after delay,
	#  but allow to cancel it if slider adjusted again
	music_sample_fade = create_tween()
	music_sample_fade.tween_interval(5)
	music_sample_fade.tween_callback(func():print_debug("fade start"))
	music_sample_fade.tween_property(music_sample, "volume_db", linear_to_db(0.001), 2)
	music_sample_fade.tween_callback(func():print_debug("fade complete"))
	music_sample_fade.play()
	await music_sample_fade.finished
	print_debug("fade finished")
	music_sample.stop()
	reset_music_sample_fade()

func reset_music_sample_fade():
	print_debug("fade reset")
	music_sample.volume_db = linear_to_db(1)
	if music_sample_fade != null:
		music_sample_fade.stop()
		music_sample_fade = null

var sound_play_delay = false

func _on_sound_volume_slider_value_changed(value: float) -> void:
	sound_volume = value
	save_settings()
	# Play a sound if we haven't recently
	if !sound_play_delay:
		if randf() > 0.4:
			SoundPlayer.play_bubble_collect()
		else: SoundPlayer.play_bubble_movement()
		sound_play_delay = true
		await get_tree().create_timer(0.13).timeout
		sound_play_delay = false

func _on_anti_aliasing_button_item_selected(index: int) -> void:
	anti_aliasing = index as AntiAliasingSetting
	save_settings()

func _on_back_pressed() -> void:
	music_sample.stop()
	reset_music_sample_fade()
	back_button_pressed.emit()


func save_settings() -> void:pass
	#var save_dict := {}
	#save_dict["music_volume"] = music_volume
	#save_dict["sound_volume"] = sound_volume
	#save_dict["is_full_screen"] = is_full_screen
	#save_dict["anti_aliasing"] = anti_aliasing
	#
	#var save_file := FileAccess.open("user://settings", FileAccess.WRITE)
	#save_file.store_var(save_dict)
	#save_file.close()

func load_settings() -> void:pass
	#if !FileAccess.file_exists("user://settings"):
		## If no settings have been saved, leave values as default
		#print_debug("Loading default settings...")
		#return
	#
	#var save_file := FileAccess.open("user://settings", FileAccess.READ)
	#var save_dict:Dictionary = save_file.get_var()
	#
	#music_volume = save_dict["music_volume"]
	#sound_volume = save_dict["sound_volume"]
	#is_full_screen = save_dict["is_full_screen"]
	#anti_aliasing = save_dict["anti_aliasing"]

@export
# This is an editor-only value used to conveniently clear the data for testing
var clear_settings:bool:
	get: return false
	set(value):
		print_debug("Deleting settings file...")
		DirAccess.remove_absolute("user://settings")
