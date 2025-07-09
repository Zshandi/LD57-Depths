extends CanvasItem

signal exited

var sound_normal = preload("res://assets/icons/sound.png")
var sound_low = preload("res://assets/icons/sound_low.png")
var sound_muted = preload("res://assets/icons/sound_mute.png")
var music_normal = preload("res://assets/icons/music.png")
var music_low = preload("res://assets/icons/music_low.png")
var music_muted = preload("res://assets/icons/music_mute.png")

func _ready() -> void:
	%MusicVolume.set_value_no_signal(Options.music_volume * 100)
	%SoundVolume.set_value_no_signal(Options.sound_volume * 100)
	%FullScreenButton.set_pressed_no_signal(Options.is_full_screen)
	update_textures()

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		%Back.grab_focus()

func _on_back_pressed() -> void:
	exited.emit()

func _on_music_volume_value_changed(value: float) -> void:
	Options.music_volume = %MusicVolume.value / 100
	Options.save_settings()
	update_textures()

func _on_sound_volume_value_changed(value: float) -> void:
	Options.sound_volume = %SoundVolume.value / 100
	Options.save_settings()
	update_textures()

func update_textures():
	if %SoundVolume.value == 0:
		%SoundTexture.texture = sound_muted
	elif %SoundVolume.value < 50:
		%SoundTexture.texture = sound_low
	else:
		%SoundTexture.texture = sound_normal
	
	if %MusicVolume.value == 0:
		%MusicTexture.texture = music_muted
	elif %MusicVolume.value < 50:
		%MusicTexture.texture = music_low
	else:
		%MusicTexture.texture = music_normal

func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	Options.is_full_screen = toggled_on
	Options.save_settings()
