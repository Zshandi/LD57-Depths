extends CharacterBody2D

func _ready() -> void:
	%Animation.play("default")

func hurt_player(player:Character):
	player.take_damage(1, self)
