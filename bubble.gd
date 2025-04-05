@tool
extends CollisionShape2D
class_name Bubble

signal pop_finished

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%BubbleColor.modulate = value

@export
var base_scale := 1.0:
	set(value):
		base_scale = value
		scale = Vector2(value, value)
	get: return base_scale

@export
var wobble_on_ready := false
@export
var wobble_anim_scale := 1.0

@export
var max_stretch := 0.5

@export
var should_print_debug := false

var is_wobbling := false
var wobble_time := 0.0

var current_wobbles:Array[Wobble] = []

func start_wobble():
	is_wobbling = true

func pop(play_sound:bool = true):
	%AnimationPlayer.play("pop")
	if play_sound:
		%AudioPlayer_Pop.play()

func reset():
	%AnimationPlayer.play("RESET")
	is_wobbling = false

func _ready() -> void:
	%BubbleColor.modulate = color
	if Engine.is_editor_hint(): return
	if wobble_on_ready:
		start_wobble()

func add_wobble_push(direction:Vector2, amount:float) -> void:
	add_wobble(-1.2*amount, 85, 0.96, direction)
	var offset1 := randf_range(-PI/8, PI/8)
	var offset2 := randf_range(-PI/8, PI/8)
	var rotation1 := randi_range(-1, 1)
	var rotation2 := randi_range(-1, 1)
	# We don't want these subtle movements being scaled up too much
	amount = clampf(amount, 0, 1)
	add_rotating_wobble(-0.08*amount, 10, 0.99, direction.rotated(offset1), rotation1)
	add_rotating_wobble(-0.015*amount, 6, 0.998, direction.rotated(offset2), rotation2)

func process_wobble_animation(delta:float) -> void:
	wobble_time -= delta
	if wobble_time <= 0:
		wobble_time = randf_range(1.5, 2.5)
		var direction1 := Vector2.UP.rotated(randf_range(0, TAU))
		var direction2 := Vector2.UP.rotated(randf_range(0, TAU))
		var rotation1 := randi_range(-1, 1)
		var rotation2 := randi_range(-1, 1)
		add_rotating_wobble(0.1 * wobble_anim_scale, 12, 0.98, direction1, rotation1)
		add_rotating_wobble(0.03 * wobble_anim_scale, 6, 0.99, direction2, rotation2)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_wobbling:
		process_wobble_animation(delta)
	
	var trans = Transform2D.IDENTITY.scaled(Vector2(base_scale, base_scale))
	if current_wobbles.size() > 0:
		var min_wobble_val := 0.0001 / base_scale
		var to_remove := []
		for wobble in current_wobbles:
			wobble._process(delta)
			trans = add_stretch(trans, wobble.current_stretch, wobble.direction)
			if abs(wobble.current_speed) + abs(wobble.current_stretch) < min_wobble_val:
				to_remove.push_back(wobble)
		
		for wobble in to_remove:
			var idx = current_wobbles.find(wobble)
			current_wobbles.remove_at(idx)
			if should_print_debug:
				print_debug("Removing wobble ", wobble, " at current_wobbles[", idx, "]")
		
		transform = trans
	elif not %AnimationPlayer.is_playing():
		transform = trans

# Internal for calculations
func add_stretch(to:Transform2D, scale_distance:float, direction:Vector2) -> Transform2D:
	
	var rotation = direction.angle_to(Vector2.UP)
	to = to.rotated(rotation)
	
	var scale := Vector2(1.0 - scale_distance, 1.0 + scale_distance)
	to = to.scaled(scale)
	
	to = to.rotated(-rotation)
	return to

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	if anim_name == &"pop":
		pop_finished.emit()

func add_wobble(starting_speed:float, spring_constant:float, attenuation:float, direction:Vector2) -> Wobble:
	var wobble := Wobble.new()
	wobble.current_speed = starting_speed
	wobble.spring_constant = spring_constant
	wobble.attenuation = attenuation
	wobble.direction = direction
	wobble.max_stretch = max_stretch
	current_wobbles.append(wobble)
	return wobble

func add_rotating_wobble(starting_speed:float, spring_constant:float, attenuation:float, direction:Vector2, rotation_dir:int = 1) -> void:
	var first := add_wobble(starting_speed, spring_constant, attenuation, direction)
	var period := first.get_rate_seconds()
	var delay := period / 4
	var second_starting_speed := starting_speed * Bubble.attenuation_per_delta(attenuation, delay)
	
	await get_tree().create_timer(delay).timeout
	add_wobble(second_starting_speed, spring_constant, attenuation, direction.rotated(rotation_dir*PI/4))

static func get_spring_constant_for_period(period:float) -> float:
	# period = 2*PI * sqrt(1/spring_constant)
	# (period / (2*PI))^2 = 1/spring_constant
	# spring_constant = 1/(period / (2*PI))^2
	return 1.0 / pow(period / (2*PI), 2)

static func get_speed_for_distance(dist:float, spring_const:float) -> float:
	# (1/2)mv^2 = (1/2)kx^2 (from Google)
	# v = sqrt(kx^2/m), but m is 1, so
	# v = sqrt(kx^2)
	return sqrt(spring_const * dist * dist)

class Wobble:
	extends RefCounted
	
	var current_stretch := 0.0
	var current_speed := 0.0
	
	var spring_constant := 1.0
	var max_stretch := 0.5
	var attenuation := 0.9
	var direction := Vector2.UP
	
	func _process(delta:float) -> void:
		current_stretch += current_speed * delta
		
		if (current_stretch > max_stretch or current_stretch < -max_stretch):
			print_debug("max_stretch reached: ", current_stretch, current_speed)
			current_stretch = clampf(current_stretch, -max_stretch, max_stretch)
			current_speed = 0
		
		current_speed -= current_stretch * spring_constant * delta
		current_speed *= Bubble.attenuation_per_delta(attenuation, delta)
	
	func get_rate_seconds() -> float:
		return 2*PI * sqrt(1/spring_constant)

static func attenuation_per_delta(attenuation:float, delta:float) -> float:
	return 1.0/pow(1.0/attenuation, delta*60)
