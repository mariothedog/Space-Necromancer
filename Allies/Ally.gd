extends KinematicBody2D

# Preload resources
var bullet_scene = preload("res://Bullets/Friendly Bullet.tscn")

# Get nodes
onready var allies_collection_node = get_parent()
onready var level_node = allies_collection_node.get_parent()
# warning-ignore:unused_class_variable
onready var sprite = get_node("Sprite")
# warning-ignore:unused_class_variable
onready var collision_shape = get_node("CollisionShape2D")
onready var hurt_sfx = get_node("Hurt")
onready var bullets_collection_node = level_node.get_node("Bullets")
onready var player = level_node.get_node("Player")
onready var shoot_timer = get_node("Shoot")

# Constants
onready var ALLIES_POS_Y = level_node.get_node("Allies Pos Y").position.y
const BULLET_SPEED = 400.0
const MOVE_TO_ALLY_POS_Y_SPEED = 10
const SHOOT_DIRECTION = Vector2.UP

const MIN_SHOOT_TIME = 0.5
const MAX_SHOOT_TIME = 1.5

const MIN_MOVE_OFFSET = 0
const MAX_MOVE_OFFSET = 2 * PI
var MOVE_OFFSET = rand_range(MIN_MOVE_OFFSET, MAX_MOVE_OFFSET)
const MIN_MOVE_RANGE = 100
const MAX_MOVE_RANGE = 600
var MOVE_RANGE = rand_range(MIN_MOVE_RANGE, MAX_MOVE_RANGE)
const MIN_MOVE_PERIOD = 2
const MAX_MOVE_PERIOD = 10
var MOVE_PERIOD = rand_range(MIN_MOVE_PERIOD, MAX_MOVE_PERIOD)

# Variables
var immortal = true
var elapsed_time = 0

func _ready() -> void:
	shoot_timer.wait_time = rand_range(MIN_SHOOT_TIME, MAX_SHOOT_TIME)
	shoot_timer.start()

func _physics_process(delta) -> void:
	elapsed_time += delta
	
	if position.y != ALLIES_POS_Y:
		position.y = move_toward(position.y, ALLIES_POS_Y, MOVE_TO_ALLY_POS_Y_SPEED)
	
	position.x = lerp(position.x, player.position.x + sin(elapsed_time / MOVE_PERIOD + MOVE_OFFSET) * MOVE_RANGE, delta)

func die() -> void:
	queue_free()
	
	hurt_sfx.play()

func shoot(dir : Vector2) -> void:
	var bullet = bullet_scene.instance()
	bullet.position = position
	bullet.velocity = dir * BULLET_SPEED
	bullets_collection_node.add_child(bullet)

func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	if anim_name == "Turn to Ally":
		immortal = false

func _on_Shoot_timeout():
	shoot(SHOOT_DIRECTION)
