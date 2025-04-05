extends Node

var level_collection:LevelCollection = preload("res://levels/level_manager/levels.tres")

var current_level_index:int = 0
var current_level:LevelInfo = null

func load_current_level():
	# Wrap level index
	if current_level_index < 0:
		current_level_index = level_collection.levels.size()-1
	elif current_level_index >= level_collection.levels.size():
		current_level_index = 0
	
	current_level = level_collection.levels[current_level_index]
	
	if get_tree().current_scene is Level:
		var current_level_node := current_level.scene.instantiate()
		
		get_tree().root.add_child(current_level_node)
		current_level_node.owner = get_tree().root
		get_tree().current_scene.queue_free()
		get_tree().current_scene = current_level_node
	else:
		get_tree().change_scene_to_packed(current_level.scene)
	

func load_next_level():
	current_level_index += 1
	load_current_level()
