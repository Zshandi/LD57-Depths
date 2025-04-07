extends Enemy

func player_attack(character:Character):
	get_tree().change_scene_to_file("res://victory.tscn")

func hurt_player(player):
	pass
