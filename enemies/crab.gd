extends Enemy

@export
var movement_speed := 5.0

@export_enum("Left:-1", "Right:1")
var initial_direction := -1

var starting_position:Vector2
var current_direction:int

func _ready() -> void:
	super._ready()
	current_direction = initial_direction

func _physics_process(delta: float) -> void:
	if not activated: return
	velocity = Vector2(current_direction * movement_speed, 0) + get_gravity()
	print_debug("velocity: ", velocity)
	move_and_slide()
	
	if is_on_wall():
		# Turn around
		current_direction = 1 if current_direction == -1 else -1
