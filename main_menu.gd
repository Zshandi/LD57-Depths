extends Node2D

func _ready() -> void:
	$Start.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://game.tscn")


func _on_quit_pressed():
	get_tree().quit()
