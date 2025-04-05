extends Node2D

func _ready() -> void:
	# In case I'm editing the settings menu and haven't switched back
	_on_settings_back_button_pressed()
	MusicPlayer.stop()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	%MainMenu.hide()
	%SettingsMenu.show()


func _on_settings_back_button_pressed() -> void:
	%MainMenu.show()
	%SettingsMenu.hide()


func _on_play_button_pressed() -> void:
	LevelManager.load_current_level()
