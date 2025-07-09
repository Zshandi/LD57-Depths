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
	_update_textures()

func _on_visibility_changed() -> void:
	if is_inside_tree() and is_visible_in_tree():
		%Back.grab_focus()

func _on_back_pressed() -> void:
	exited.emit()

func _on_music_volume_value_changed(value: float) -> void:
	Options.music_volume = %MusicVolume.value / 100
	Options.save_settings()
	_play_music_sample()
	_update_textures()

func _play_music_sample():
	%MusicSampleTimer.start(5)
	%MusicSampleFadePlayer.play(&"RESET")
	if !%MusicSamplePlayer.playing:
		%MusicSamplePlayer.play()

func _on_music_sample_timer_timeout() -> void:
	%MusicSampleFadePlayer.play(&"music_sample_fade")

func _on_music_sample_fade_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"music_sample_fade":
		%MusicSamplePlayer.stop()
		%MusicSampleFadePlayer.play(&"RESET")

func _on_sound_volume_value_changed(value: float) -> void:
	Options.sound_volume = %SoundVolume.value / 100
	Options.save_settings()
	_play_sound_sample()
	_update_textures()

func _play_sound_sample():
	SoundPlayer.play_stream(%SoundSample)

func _update_textures():
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
