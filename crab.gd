extends CharacterBody2D

func _ready() -> void:
	%Animation.play("default")

func hurt_player(player:Character) -> void:
	player.take_damage(1, self)

func player_attack() -> void:
	%DeathSound.play()
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	await %DeathSound.finished
	queue_free()
