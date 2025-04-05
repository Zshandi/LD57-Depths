extends Node2D

var default_position:Vector2

func _ready() -> void:
	default_position = position

func _process(delta: float) -> void:
	position = default_position
	global_position.x = roundf(global_position.x)
	global_position.y = roundf(global_position.y)
