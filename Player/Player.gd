extends KinematicBody2D

signal queue_freed

# Preload resources
onready var bullet_scene = preload("res://Bullets/Friendly Bullet.tscn")

# Get nodes
onready var level_node = get_parent()
onready var bullets_collection_node = level_node.get_node("Bullets")
onready var shoot_delay_timer = get_node("Shoot Delay")
onready var sprite = get_node("Sprite")
onready var collision_shape = get_node("CollisionShape2D")
onready var animate_movement_timer = get_node("Animate Movement")
onready var queue_free_after_death_timer = get_node("Queue Free After Death")
onready var shoot_sfx = get_node("Shoot")
onready var hurt_sfx = get_node("Hurt")

# Constants
const SPEED = 500
const BULLET_SPEED = 800
const NUM_MOVEMENT_FRAMES = 2

# Variables
var velocity = Vector2()
var can_shoot = true
var current_bullet = null
var immortal = false
var dead = false

func _physics_process(_delta) -> void:
	get_input()
	movement()

func get_input() -> void:
	if dead:
		return
	
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
	bullet.connect("died", self, "_on_bullet_death")
	bullets_collection_node.add_child(bullet)
	current_bullet = bullet
	
	shoot_sfx.play()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)

	# Because a Sprite node's frame starts at 0, this variable, which accounts for the number of movement frames, is also equal to the index of the last frame (death frame)
	sprite.frame = NUM_MOVEMENT_FRAMES
	
	queue_free_after_death_timer.start()
	animate_movement_timer.stop()
	
	hurt_sfx.play()

func _on_Shoot_Delay_timeout() -> void:
	can_shoot = true

func _on_bullet_death() -> void:
	current_bullet = null

func _on_Animate_Movement_timeout() -> void:
	if velocity.length() > 0:
		sprite.frame = (sprite.frame + 1) % NUM_MOVEMENT_FRAMES

func _on_Queue_Free_After_Death_timeout() -> void:
	queue_free()
	emit_signal("queue_freed")
