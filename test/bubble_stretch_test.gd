extends Node2D

@export
var reset := false

@export
var set_stretch := false

@export
var scale_distance := 0.0

@export
var stretch_direction := Vector2.UP

func _process(delta: float) -> void:
	if set_stretch:
		var trans = Transform2D.IDENTITY.scaled(Vector2(%Bubble.base_scale, %Bubble.base_scale))
		trans = %Bubble.add_stretch(trans, scale_distance, stretch_direction)
		%Bubble.transform = trans
		set_stretch = false
	elif reset:
		%Bubble.transform = Transform2D.IDENTITY.scaled(Vector2(%Bubble.base_scale, %Bubble.base_scale))
		reset = false
