extends CanvasItem

signal exited

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		%Back.grab_focus()



func _on_back_pressed() -> void:
	exited.emit()
