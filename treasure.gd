extends Enemy

signal collected

func player_attack(character:Character):
	var bubbles = preload("res://bubbles.tscn").instantiate()
	bubbles.global_position = global_position
	add_sibling(bubbles)
	character.clear_panic_mode()
	collected.emit()
	super.player_attack(character)

func hurt_player(player):
	pass
