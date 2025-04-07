extends Enemy


func _ready() -> void:
	pass

func player_attack(character:Character) -> void:
	%DeathSound.play()
