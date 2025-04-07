extends Enemy

func player_attack(character:Character):
	var bubbles = preload("res://bubbles.tscn").instantiate()
	bubbles.global_position = global_position
	add_sibling(bubbles)
	character.health = 6
	character.take_damage(0)
	super.player_attack(character)

func hurt_player(player):
	pass
