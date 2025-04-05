extends CharacterBody2D

var max_speed_x := 35.0
var accel_x := 0.5
var decel_x := 1.0
var break_x := 2.0

var max_speed_y := 55.0
var max_speed_float := 30.0
var jump_speed := 50.0
var float_accel := 0.7
var jump_accel := 0.7
var is_jumping := false

var jump_from := 0.0

var double_tap_interval_ms := 400
var jump_pressed_time_ms := 0

var is_floating := false

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		var current_time := Time.get_ticks_msec()
		if current_time <= jump_pressed_time_ms + double_tap_interval_ms:
			is_floating = not is_floating
		
		if is_floating or is_on_floor():
			jump_pressed_time_ms = current_time
	
	if is_floating:
		velocity.y -= float_accel
	else:
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
	
	if is_floating:
		velocity.y = clampf(velocity.y, -max_speed_float, max_speed_float)
	else:
		velocity.y = clampf(velocity.y, -max_speed_y, max_speed_y)
	velocity.x = clampf(velocity.x, -max_speed_x, max_speed_x)
	
	move_and_slide()
