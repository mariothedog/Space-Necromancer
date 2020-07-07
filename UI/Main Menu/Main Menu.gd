extends MarginContainer

func _on_Play_pressed() -> void:
	if get_tree().change_scene("res://Level/Level.tscn") != OK:
		print_debug("An error occurred while attempting to play the level!")
