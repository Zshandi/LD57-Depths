@tool
extends Node2D

func _ready() -> void:
	global_position.x = roundf(global_position.x)
	global_position.y = roundf(global_position.y)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		global_position.x = roundf(global_position.x)
		global_position.y = roundf(global_position.y)
