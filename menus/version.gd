extends Label

func _ready() -> void:
	var version:String = ProjectSettings.get_setting("application/config/version")
	text = "Version " + version
