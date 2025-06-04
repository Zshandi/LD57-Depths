extends CanvasItem

signal exited

func _ready() -> void:
	%MusicVolume.set_value_no_signal(Options.music_volume * 100)
	%SoundVolume.set_value_no_signal(Options.sound_volume * 100)
	%FullScreenButton.set_pressed_no_signal(Options.is_full_screen)

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		%Back.grab_focus()

func _on_back_pressed() -> void:
	exited.emit()

func _on_music_volume_value_changed(value: float) -> void:
	Options.music_volume = %MusicVolume.value / 100
	Options.save_settings()

func _on_sound_volume_value_changed(value: float) -> void:
	Options.sound_volume = %SoundVolume.value / 100
	Options.save_settings()


func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	Options.is_full_screen = toggled_on
	Options.save_settings()
