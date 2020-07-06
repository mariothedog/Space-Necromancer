extends Node

func _unhandled_input(_event):
	if Input.is_action_just_pressed("restart"):
		restart()

func restart():
	if get_tree().change_scene("res://Level/Level.tscn") != OK:
		print_debug("An error occurred while attempting to restart the level!")
