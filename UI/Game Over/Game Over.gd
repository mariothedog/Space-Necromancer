extends MarginContainer

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("restart"):
		restart()

func restart() -> void:
	if get_tree().change_scene("res://Level/Level.tscn") != OK:
		print_debug("An error occurred while attempting to go to the level scene.")
