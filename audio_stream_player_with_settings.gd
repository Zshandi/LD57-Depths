extends AudioStreamPlayer
class_name AudioStreamPlayerWithSettings

@export_category("Pitch Variation")
@export_range(0.1, 4.0, 0.01)
var min_pitch:float = 0.8
@export_range(0.1, 4.0, 0.01)
var max_pitch:float = 1.2

func _ready() -> void:
	pitch_scale = randf_range(min_pitch, max_pitch)
