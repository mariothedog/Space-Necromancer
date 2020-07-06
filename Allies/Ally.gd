extends KinematicBody2D

# Get nodes
onready var allies_collection_node = get_parent()
onready var level_node = allies_collection_node.get_parent()
onready var sprite = get_node("Sprite")
onready var collision_shape = get_node("CollisionShape2D")

# Constants
onready var ALLIES_POS_Y = level_node.get_node("Allies Pos Y").position.y

# Variables
var immortal = true

func _physics_process(_delta):
	if position.y != ALLIES_POS_Y:
		position.y = move_toward(position.y, ALLIES_POS_Y, 10)

func die() -> void:
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Turn to Ally":
		immortal = false
