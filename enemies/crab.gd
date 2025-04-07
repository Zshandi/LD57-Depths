@tool
extends Enemy

@export
var movement_speed := 20.0

@export_enum("Left:-1", "Right:1")
var initial_direction:int

var starting_position:Vector2
var current_direction:int

func hurt_player(player:Character) -> void:
	pass

func _ready() -> void:
	if initial_direction == 0:
		initial_direction = -1
	current_direction = initial_direction
	if not Engine.is_editor_hint():
		super._ready()

func _physics_process(delta: float) -> void:
	if not activated: return
	velocity = Vector2(current_direction * movement_speed, 0) + get_gravity()
	print_debug("current_direction: ", current_direction)
	move_and_slide()
	
	for index in range(0, get_slide_collision_count()):
		var collision := get_slide_collision(index)
		
		var what := collision.get_collider()
		
		if what is Character:
			what.take_damage(1, self)
	
	if is_on_wall():
		# Turn around
		current_direction = 1 if current_direction == -1 else -1
