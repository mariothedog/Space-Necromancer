extends CanvasLayer

# Get nodes
onready var score_label = get_node("MarginContainer/VBoxContainer/Score")

# Variables
var score = 0

func _process(_delta):
	score_label.text = "Score: " + str(score)
