@tool
extends Area2D
class_name BubbleCollectible

signal collected

@export
var color := Color.WHITE:
	get:
		return color
	set(value):
		color = value
		if is_node_ready():
			%BubbleCollision.color = value

@export
var should_mix_color := true

@export
var randomize_color := true

@export
var animate_hue := false

@export_range(0.0, 1.0, 0.001)
var hue_shift_per_second := 0.1

@export
var is_required_to_complete_level := true

@export
var previous_collectible:Node2D:
	set(value):
		previous_collectible = value
		queue_redraw()

@export
var show_total_size:bool:
	set(value):
		show_total_size = value
		queue_redraw()

var wobble_time := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	if animate_hue:
		color.h += hue_shift_per_second * delta
		%BubbleCollision.color = color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BubbleCollision.color = color
	if Engine.is_editor_hint(): return
	if randomize_color:
		color.h = randf()
		%BubbleCollision.color = color

func _on_body_entered(body: Node2D) -> void:
	if body is BubbleCharacter:
		var character = body as BubbleCharacter
		
		character.collect_bubble(get_radius(), self)
		collected.emit()
		
		animate_collected(character)

func animate_collected(character:BubbleCharacter) -> void:
	var desired_movement := (character.global_position - global_position).normalized() * get_radius() / 2
	var new_position := position + desired_movement
	var tween := create_tween().set_parallel()
	# 0.12 is the shortest duration of the character's animation
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.12)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", new_position, 0.12)
	tween.play()
	
	await tween.finished
	queue_free()

func _draw() -> void:
	if !Engine.is_editor_hint(): return
	if show_total_size:
		draw_circle(Vector2.ZERO, get_totalled_radius() / global_scale.x, Color.BLACK, false)

func get_radius() -> float:
	var current_scale = %BubbleCollision.base_scale * global_scale.x
	return %BubbleCollision.shape.radius * current_scale

func get_totalled_radius() -> float:
	var area := BubbleCharacter.size_to_area(get_radius())
	if previous_collectible != null:
		if previous_collectible.has_method("get_totalled_radius"):
			area += BubbleCharacter.size_to_area(previous_collectible.get_totalled_radius())
		elif previous_collectible.has_method("get_radius"):
			area += BubbleCharacter.size_to_area(previous_collectible.get_radius())
	return BubbleCharacter.area_to_size(area)
