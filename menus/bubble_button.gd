extends Area2D

signal pressed

@export_file("*.tscn")
var load_scene_path:String = ""

@export
var wobble_push_on_mouse := false
@export
var wobble_push_divisor := 1200

var mouse_velocity := Vector2.ZERO
var mouse_over := false
var mouse_was_over := false

const max_push_timeouts := 3
const push_timeout_seconds := 1.5

var push_timeouts:Array[float] = []

func add_push_timeout() -> bool:
	if push_timeouts.size() < max_push_timeouts:
		push_timeouts.push_back(push_timeout_seconds)
		return true
	return false

func _process(delta: float) -> void:
	var i := 0
	while i < push_timeouts.size():
		push_timeouts[i] -= delta
		if push_timeouts[i] < 0:
			push_timeouts.remove_at(i)
		else:
			i += 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && mouse_over:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			$BubbleCollision.pop()
			await $BubbleCollision.pop_finished
			await get_tree().create_timer(1).timeout
			if load_scene_path != "":
				get_tree().change_scene_to_file(load_scene_path)
			pressed.emit()
			MusicPlayer.play()
	
	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		mouse_velocity = mouse_event.velocity
		
		if wobble_push_on_mouse and mouse_over != mouse_was_over:
			mouse_was_over = mouse_over
			
			# Limit pushing
			if !add_push_timeout():
				return
			
			var speed = mouse_velocity.length()
			if not mouse_over: speed = -speed
			$BubbleCollision.add_wobble_push(mouse_velocity, speed / wobble_push_divisor)
			


func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
