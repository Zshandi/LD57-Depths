extends CanvasLayer

# Note that this is needed to distinguish regular
#  pausing from scene tree pausing for other reasons (i.e. hit stop)
var is_paused := false

var pause_button_mouse_over := false

func _on_pause_button_mouse_entered() -> void:
	pause_button_mouse_over = true

func _on_pause_button_mouse_exited() -> void:
	pause_button_mouse_over = false

var pause_pressed := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if (!pause_pressed):
			toggle_paused()
		pause_pressed = true
	else:
		pause_pressed = false
	
	if event is InputEventMouseButton && pause_button_mouse_over && !get_tree().paused:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			get_viewport().set_input_as_handled()
			toggle_paused()

func hide_button() -> void:
	%BubbleCollision.pop(false)
	%PauseSprite.hide()
	
func show_button() -> void:
	%BubbleCollision.reset()
	%PauseSprite.show()

func toggle_paused():
	if !get_tree().paused && !is_paused:
		hide_button()
		%Pause.show()
		is_paused = true
		get_tree().paused = true
		MusicPlayer.pause()
	elif is_paused:
		show_button()
		%Pause.hide()
		is_paused = false
		get_tree().paused = false
		_on_settings_back_button_pressed()
		MusicPlayer.play()

func _ready():
	# In case I am editing it and forget to re-set the visibilities
	show()
	%Buttons.show()
	%Settings.hide()
	%Pause.hide()


func _on_quit_to_title_pressed() -> void:
	get_tree().paused = false
	MusicPlayer.stop()
	get_tree().change_scene_to_packed(preload("res://menus/title_menu.tscn"))


func _on_restart_level_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_settings_pressed() -> void:
	%Settings.show()
	%Buttons.hide()
	%Title.text = "Settings"


func _on_settings_back_button_pressed() -> void:
	%Settings.hide()
	%Buttons.show()
	%Title.text = "Paused"
