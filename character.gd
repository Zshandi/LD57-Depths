extends CharacterBody2D
class_name Character

# Constants

var max_speed_x := 35.0
var accel_x := 30.0
var decel_x := 60.0
var break_x := 120.0

var last_direction := 1.0
var current_direction := 0.0

var max_speed_y := 55.0
var max_speed_float := 30.0
var jump_speed := 55.0
var float_accel := 42.0
var jump_accel := 48.0

var double_tap_interval_ms := 400

# State

var is_jumping_held := false
var is_jumping_up := false

var jump_from := 0.0
var jump_pressed_time_ms := 0

var is_floating := false

var invincible_frames := false
var invincibility_time := 2

var is_attacking := false
var is_attack_windup := false
var should_release_attack := false

# Stats

var health := 6

# Logic

func _ready():
	$breath_gauge.frame = health

func _process(delta: float) -> void:
	%AnimatedSprite.scale.x = last_direction
	if is_attacking:
		if is_attack_windup:
			if %AnimatedSprite.animation != &"attack_windup":
				%AnimatedSprite.play("attack_windup")
		else:
			%AnimatedSprite.play("attack_swing")
	elif is_on_floor():
		if current_direction != 0:
			%AnimatedSprite.play("walking")
		else:
			%AnimatedSprite.play("default")
	else:
		%AnimatedSprite.play("jump")

func process_attack(delta: float) -> void:
	if is_attacking:
		if not Input.is_action_pressed("action"):
			should_release_attack = true
		if not %AnimatedSprite.is_playing():
			if is_attack_windup:
				if should_release_attack:
					should_release_attack = false
					is_attack_windup = false
					for body in %HammerHit_0.get_overlapping_bodies():
						if "player_attack" in body:
							body.player_attack()
					await get_tree().create_timer(0.35).timeout
					var enemy_found = null
					for body in %HammerHit_1.get_overlapping_bodies():
						if "player_attack" in body:
							body.player_attack()
							if "global_position" in body:
								enemy_found = body.global_position
					if enemy_found != null:
						knockback(enemy_found, 5)
					else:
						await get_tree().create_timer(0.05).timeout
						%HammerHitAudio.play()
			else:
				is_attacking = false
	else:
		if is_on_floor() and Input.is_action_just_pressed("action"):
			velocity = Vector2.ZERO
			is_attacking = true
			is_attack_windup = true
			should_release_attack = false
	

func process_movement(delta: float) -> void:
	
	if is_floating:
		velocity.y -= float_accel * delta
		if is_on_ceiling():
			is_floating = false
	else:
		velocity += get_gravity()
	
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
			is_jumping_held = true
			is_jumping_up = true
		elif is_jumping_up or is_floating:
			is_floating = not is_floating
	
	if is_jumping_held and velocity.y < 0:
		if Input.is_action_pressed("jump"):
			velocity.y -= jump_accel * delta
		else:
			is_jumping_held = false
	else:
		is_jumping_held = false
	
	if velocity.y >= 0:
		is_jumping_up = false
	
	var x_change := 0.0
	current_direction = Input.get_axis("left", "right")
	if current_direction == 0:
		if abs(velocity.x) < decel_x:
			x_change = -velocity.x
		else:
			x_change = -sign(velocity.x) * decel_x
	elif sign(current_direction) != sign(velocity.x):
		x_change = current_direction * break_x
	else:
		x_change = current_direction * accel_x
	
	if current_direction != 0:
		last_direction = current_direction
	
	if !is_on_floor():
		x_change *= 0.2
	velocity.x += x_change * delta
	
	if is_floating:
		velocity.y = clampf(velocity.y, -max_speed_float, max_speed_float)
	else:
		velocity.y = clampf(velocity.y, -max_speed_y, max_speed_y)
	velocity.x = clampf(velocity.x, -max_speed_x, max_speed_x)
	

func process_collision(delta: float) -> void:
	
	move_and_slide()
	
	for index in range(0, get_slide_collision_count()):
		var collision := get_slide_collision(index)
		
		var what := collision.get_collider()
		
		if what is Node and "hurt_player" in what:
			what.hurt_player(self)

func _physics_process(delta: float) -> void:
	process_attack(delta)
	if not is_attacking:
		process_movement(delta)
	process_collision(delta)

func take_damage(amount:int, from:Node2D = null, knockback:float = 40):
	if invincible_frames: return
	
	health -= amount
	$breath_gauge.frame = health
	if from != null and knockback > 0:
		$CPUParticles2D_2.restart()
		$CPUParticles2D_2.emitting = true
		%AnimationPlayer.play("hurt_flash")
		invincible_frames = true
		knockback(from.global_position, knockback)
		await get_tree().create_timer(invincibility_time).timeout
		%AnimationPlayer.play("RESET")
		invincible_frames = false
	
	

func knockback(from_global:Vector2, amount:float):
	var direction_x := signf(global_position.x - from_global.x)
	var direction := Vector2(direction_x, -0.7).normalized()
	velocity = amount * direction


func _on_in_view_area_body_entered(body: Node2D) -> void:
	if "activate" in body:
		body.activate()


func _on_breath_timer_timeout():
	take_damage(1)
