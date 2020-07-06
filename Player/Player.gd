extends KinematicBody2D

signal died

# Preload resources
onready var bullet_scene = preload("res://Bullets/Friendly Bullet.tscn")

# Get nodes
onready var level_node = get_parent()
onready var bullets_collection_node = level_node.get_node("Bullets")
onready var shoot_delay_timer = get_node("Shoot Delay")

# Constants
const SPEED = 500
const BULLET_SPEED = 800

# Variables
var velocity = Vector2()
var can_shoot = true
var current_bullet = null
var immortal = false

func _physics_process(_delta) -> void:
	get_input()
	movement()

func get_input() -> void:
	var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = input_x * SPEED
	
	if Input.is_action_pressed("shoot") and current_bullet == null and can_shoot:
		shoot(Vector2.UP)
		can_shoot = false
		shoot_delay_timer.start()

func movement() -> void:
	velocity = move_and_slide(velocity)

func shoot(dir : Vector2) -> void:
	var bullet = bullet_scene.instance()
	bullet.position = position
	bullet.velocity = dir * BULLET_SPEED
	bullets_collection_node.add_child(bullet)
	current_bullet = bullet

func die() -> void:
	emit_signal("died")
	queue_free()

func _on_Shoot_Delay_timeout() -> void:
	can_shoot = true
