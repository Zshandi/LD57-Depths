extends CharacterBody2D
class_name Enemy

var activated := false

func _ready() -> void:
	if %Animation != null:
		%Animation.play("default")

func hurt_player(player:Character) -> void:
	player.take_damage(1, self)

func player_attack() -> void:
	if %DeathSound != null:
		%DeathSound.play()
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
		await %DeathSound.finished
		queue_free()

func activate() -> void:
	activated = true
