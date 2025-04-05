@tool
extends RigidBody2D
class_name BubbleCharacter

@export
var color_weight := 0.5

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%Bubble.color = value

@export
var bubble_speed := 100.0

var min_combine_duration := 0.13
var max_combine_duration := 0.25
var min_combine_radius := 30.0
var max_combine_radius := 150.0

@onready
var starting_scale:float = %Bubble.base_scale

@onready
var current_scale:float = %Bubble.base_scale

signal started
signal died

var is_dead := false
var is_starting := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Bubble.color = color
	
	if Engine.is_editor_hint(): return
	freeze = true
	is_starting = true
	
	print_debug("Starting scale: ", %Bubble.global_scale)
	print_debug("Starting hue: ", %Bubble.color.h)
	
	# Unit(ish) tests
	assert(is_equal_approx(0.5, size_to_area(area_to_size(0.5))))
	assert(is_equal_approx(0.5, area_to_size(size_to_area(0.5))))
	assert(is_equal_approx(1, size_to_area(area_to_size(1))))
	assert(is_equal_approx(1, area_to_size(size_to_area(1))))
	assert(is_equal_approx(3, size_to_area(area_to_size(3))))
	assert(is_equal_approx(3, area_to_size(size_to_area(3))))

func get_normalized_direction() -> Vector2:
	var direction = -(get_global_mouse_position() - global_position)
	return direction.normalized()

var move_pressed := false
var move_just_pressed = false

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed("move"):
		if !move_pressed:
			move_just_pressed = true
		move_pressed = true
	else:
		move_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if move_just_pressed:
		move_just_pressed = false
		
		if is_starting:
			freeze = false
			is_starting = false
			started.emit()
		
		var direction = get_normalized_direction()
		
		apply_central_impulse(direction * bubble_speed)
		SoundPlayer.play_bubble_movement()
		
		add_wobble(direction)
	
	if get_colliding_bodies().size() > 0:
		die()
	
	# Debug
	if OS.is_debug_build():
		if Input.is_action_just_pressed("spawn_bubble"):
			# Spawn a new bubble at cursor
			var bubble = preload("res://levels/objects/bubble_collectible.tscn").instantiate()
			get_tree().root.add_child(bubble)
			bubble.owner = get_tree().root
			bubble.global_position = get_global_mouse_position()
			SoundPlayer.play_bubble_movement()
		
		if Input.is_action_just_pressed("reset_size"):
			%Bubble.base_scale = starting_scale

func add_wobble(direction:Vector2) -> void:
	%Bubble.add_wobble_push(direction, 1.0 / (%Bubble.base_scale / starting_scale))

func die():
	is_dead = true
	died.emit()
	get_tree().paused = true
	MusicPlayer.pause()
	
	# Hit stop!
	await get_tree().create_timer(0.5).timeout
	# Pop it
	%Bubble.process_mode = PROCESS_MODE_ALWAYS
	%Bubble.pop()
	await %Bubble.pop_finished
	await get_tree().create_timer(1).timeout
	
	# Resume and reload
	get_tree().paused = false
	MusicPlayer.play()
	get_tree().reload_current_scene()

static func size_to_area(radius:float) -> float:
	return PI*pow(radius, 2)

static func area_to_size(area:float) -> float:
	return pow(area/PI, 1.0/2)

func collect_bubble(size: float, bubble:BubbleCollectible):
	var current_size = get_radius()
	
	var current_area = size_to_area(current_size)
	var added_area = size_to_area(size)
	var new_area = current_area + added_area
	var new_size = area_to_size(new_area)
	
	print_debug("new_size: ", new_size, ", current_size: ", current_size)
	
	var new_scale = current_scale * new_size / current_size
	current_scale = new_scale
	print_debug("New scale: ", new_scale)
	
	var new_color = color
	if bubble.should_mix_color:
		# Average the color with the new one
		new_color = lerp(color, bubble.color, color_weight)
		# Restore some saturation and value if they were lost in the lerp
		new_color.v = lerp(color.v, bubble.color.v, color_weight)
		new_color.s = lerp(color.s, bubble.color.s, color_weight)
	else:
		new_color = bubble.color
	print_debug("New color: ", color)
	print_debug("New HSV: (", color.h*360, ", ", color.s*100, ", ", color.v*100, ")")
	
	SoundPlayer.play_bubble_collect()
	
	var combine_duration_scale := (size - min_combine_radius) / (max_combine_radius - min_combine_radius)
	var bubble_combine_duration := lerpf(min_combine_duration, max_combine_duration, combine_duration_scale)
	bubble_combine_duration = clampf(bubble_combine_duration, min_combine_duration, max_combine_duration)
	print_debug("Combine duration: ", bubble_combine_duration)
	
	# Animate the size and color
	var tween = create_tween().set_parallel(true)
	tween.tween_property(%Bubble, "base_scale", new_scale, bubble_combine_duration)
	tween.tween_property(self, "color", new_color, bubble_combine_duration)
	tween.play()
	
	# Calculate an acceleration & deceleration
	# d = (1/2) * a * t²
	# d = (1/2) * a * t²
	# 2*d / t² = a
	# Where d is distance (in this case, 1/2 the distance, since we're speeding then slowing)
	#	and t is time (in this case, 1/2 the time, same deal)
	var desired_movement := (bubble.global_position - global_position).normalized() * size / 2
	var distance := desired_movement.length()/2
	var time := bubble_combine_duration/2
	var accel_amount := 2*distance / pow(time, 2)
	var accel := accel_amount * desired_movement.normalized()
	var force := accel * mass # mass is currently just 1, but that could change
	
	# Apply the acceleration, then deceleration
	# Final accel is slightly lower to account for air resistance
	add_constant_central_force(force)
	get_tree().create_timer(bubble_combine_duration/2, false).timeout.connect(func():
		add_constant_central_force(-force)
		add_constant_central_force(-force*0.9)
		get_tree().create_timer(bubble_combine_duration/2, false).timeout.connect(func():
			add_constant_central_force(force*0.9)
			)
		)
	
	# Calculate a stretch amount
	var desired_stretch_distance := size / 3
	var required_stretch_percent:float = desired_stretch_distance / get_radius()
	var stretch_direction := (bubble.global_position - global_position).normalized()
	var spring_const := Bubble.get_spring_constant_for_period(bubble_combine_duration*4)
	var starting_speed := Bubble.get_speed_for_distance(required_stretch_percent, spring_const)
	%Bubble.add_wobble(starting_speed, spring_const, 0.8, stretch_direction)
	

func get_radius() -> float:
	return %Bubble.shape.radius * current_scale
