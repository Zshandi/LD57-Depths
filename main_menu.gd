extends Node

func _ready() -> void:
	%Start.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://game.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed() -> void:
	%MainMenu.hide()
	%OptionsMenu.show()


func _on_options_menu_exited() -> void:
	%MainMenu.show()
	%Start.grab_focus()
	%OptionsMenu.hide()
