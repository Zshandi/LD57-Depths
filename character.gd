extends CharacterBody2D

@export
var max_speed_x := 65.0
@export
var accel_x := 0.5
@export
var decel_x := 1.0
@export
var break_x := 2.0

@export
var max_speed_y := 100.0
@export
var jump_speed := 50.0
@export
var jump_accel := 0.7
var is_jumping := false

var jump_from := 0.0


func _physics_process(delta: float) -> void:
	
	velocity += get_gravity()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed
		is_jumping = true
	elif is_jumping and velocity.y < 0:
		if Input.is_action_pressed("jump"):
			velocity.y -= jump_accel
		else:
			is_jumping = false
	
	var x_change := 0.0
	var horizontal := Input.get_axis("left", "right")
	if horizontal == 0:
		if abs(velocity.x) < decel_x:
			x_change = -velocity.x
		else:
			x_change = -sign(velocity.x) * decel_x
	elif sign(horizontal) != sign(velocity.x):
		x_change = horizontal * break_x
	else:
		x_change = horizontal * accel_x
	
	if !is_on_floor():
		x_change *= 0.2
	velocity.x += x_change
	
	velocity.y = clampf(velocity.y, -max_speed_y, max_speed_y)
	velocity.x = clampf(velocity.x, -max_speed_x, max_speed_x)
	
	move_and_slide()
