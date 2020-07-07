tool
extends KinematicBody2D

# Signals
signal died
signal wall_detected

# Preload resources
onready var bullet_scene = preload("res://Bullets/Hostile Bullet.tscn")
onready var ally_scene = preload("res://Allies/Ally.tscn")

# Get nodes
onready var enemies_collection_node = get_parent()
onready var level_node = enemies_collection_node.get_parent()
onready var bullets_collection_node = level_node.get_node("Bullets")
onready var allies_collection_node = level_node.get_node("Allies")
onready var wall_detector_raycast = get_node("Wall Detector")
onready var sprite = get_node("Sprite")
onready var collision_shape = get_node("CollisionShape2D")
onready var queue_free_after_death_timer = get_node("Queue Free After Death")

# Constants
const WALL_DETECTOR_CAST_LENGTH = 60

const BULLET_SPEED = 800
const SHOOT_CHANCE = 0.0005

const ENEMY_TEXTURES = [
	preload("res://Enemies/Enemy0.png"),
	preload("res://Enemies/Enemy1.png"),
	preload("res://Enemies/Enemy2.png"),
	preload("res://Enemies/Enemy3.png"),
	preload("res://Enemies/Enemy4.png")
]
const ENEMIES_NUM_MOVEMENT_FRAMES = [2, 2, 2, 2, 2]

const SPRITE_Z_INDEX_AFTER_DEATH = -1

# Exports
export (int, 4) var type = 0 setget set_type

# Variables
var can_shoot = false
var direction = 1
var immortal = false
var dead = false

onready var enemy_num_movement_frames = ENEMIES_NUM_MOVEMENT_FRAMES[type]

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	sprite.texture = ENEMY_TEXTURES[type]
	
	wall_detector_raycast.cast_to.x = WALL_DETECTOR_CAST_LENGTH

func set_type(t) -> void:
	type = t
	sprite = get_node("Sprite")
	if sprite:
		sprite.texture = ENEMY_TEXTURES[type]

func _physics_process(_delta) -> void:
	if Engine.editor_hint:
		return
	
	if wall_detector_raycast.is_colliding():
		emit_signal("wall_detected")

func shoot(dir : Vector2) -> void:
	var bullet = bullet_scene.instance()
	bullet.position = position
	bullet.velocity = dir * BULLET_SPEED
	bullets_collection_node.add_child(bullet)

func die() -> void:
	dead = true
	collision_shape.set_deferred("disabled", true)
	emit_signal("died", self)

	sprite.z_index = SPRITE_Z_INDEX_AFTER_DEATH
	# Because a Sprite node's frame starts at 0, this variable, which accounts for the number of movement frames, is also equal to the index of the last frame (death frame)
	sprite.frame = enemy_num_movement_frames
	
	var ally = ally_scene.instance()
	ally.position = position
	allies_collection_node.call_deferred("add_child", ally)
	
	yield(ally, "ready")
	ally.sprite.texture = sprite.texture
	ally.sprite.scale = sprite.scale
	ally.collision_shape.shape.extents = collision_shape.shape.extents
	
	queue_free_after_death_timer.start()

func _on_Before_Can_Shoot_timeout() -> void:
	can_shoot = true

func _on_Queue_Free_After_Death_timeout() -> void:
	queue_free()
