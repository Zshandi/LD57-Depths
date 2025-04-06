extends Node2D

var has_moved := false
var has_jumped := false
var has_floated := false

@export
var player:CharacterBody2D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	if !has_moved:
		%MovementHelp.show()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		has_moved = true
		%MovementHelp.hide()
	if Input.is_action_just_pressed("jump"):
		has_jumped = true
		%JumpHelp.hide()
	if player != null and player.is_floating:
		has_floated = true
		%FloatHelp.hide()

func _on_jump_trigger_body_entered(body: Node2D) -> void:
	if body != player: return
	await get_tree().create_timer(6).timeout
	if !has_jumped:
		%JumpHelp.show()

var float_attempt_count := 0
func _on_float_trigger_body_entered(body: Node2D) -> void:
	if body != player: return
	if float_attempt_count < 2:
		float_attempt_count += 1
		return
	await get_tree().create_timer(3).timeout
	if !has_floated:
		%FloatHelp.show()
