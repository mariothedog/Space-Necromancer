extends Node

# Preload resources
onready var enemy_scene = preload("res://Enemies/Enemy.tscn")

# Get nodes
onready var enemies_collection_node = get_node("Enemies")
onready var move_enemies_timer = get_node("Move Enemies")
onready var player = get_node("Player")
onready var enemy_shoot_timer = get_node("Enemy Shoot")
onready var hud = get_node("HUD")

# Constants
const NUM_OF_ENEMIES_IN_ROW = 11
const NUM_OF_ROWS = 5

onready var TOP_ROW_POS = get_node("Top Row Start Pos").position

const ROW_GAP_Y = 45
const ENEMY_GAP_X = 50

const ENEMY_MOVEMENT_SPEED_X = 30
const ENEMY_MOVEMENT_SPEED_Y = 70

const ENEMY_SHOOT_DIRECTION = Vector2.DOWN
const MIN_ENEMY_SHOOT_COOLDOWN = 0.5
const MAX_ENEMY_SHOOT_COOLDOWN = 1.5

# Variables
var enemy_rows = []
var num_of_movements = 0
var num_of_moments_on_last_wall_detection
var game_over = false

func _ready() -> void:
	randomize()
	
	reset_enemies()
	move_enemies_timer.start()

func reset_enemies() -> void:
	enemy_rows = []
	for r in range(NUM_OF_ROWS):
		enemy_rows.append([])
		for i in range(NUM_OF_ENEMIES_IN_ROW):
			var enemy = enemy_scene.instance()
			var x_pos = TOP_ROW_POS.x + ENEMY_GAP_X * i
			var y_pos = TOP_ROW_POS.y + ROW_GAP_Y * r
			enemy.position = Vector2(x_pos, y_pos)
			enemy.type = r
			enemy.connect("died", self, "_on_enemy_death")
			enemy.connect("wall_detected", self, "_on_wall_detected")
			enemies_collection_node.call_deferred("add_child", enemy)
			enemy_rows[r].append(enemy)

func _on_Move_Enemies_timeout() -> void:
	num_of_movements += 1
	for row in enemy_rows:
		for enemy in row:
			if enemy != null and not enemy.dead:
				enemy.position.x += ENEMY_MOVEMENT_SPEED_X * enemy.direction
				enemy.sprite.frame = (enemy.sprite.frame + 1) % enemy.enemy_num_movement_frames

func _on_wall_detected() -> void:
	if num_of_movements == num_of_moments_on_last_wall_detection:
		return
	
	num_of_moments_on_last_wall_detection = num_of_movements
	for row in enemy_rows:
		for enemy in row:
			if enemy != null:
				enemy.direction *= -1
				enemy.wall_detector_raycast.cast_to.x *= -1
				enemy.position.y += ENEMY_MOVEMENT_SPEED_Y

func _process(_delta) -> void:
	if not game_over:
		for row in enemy_rows:
			for enemy in row:
				if enemy != null and enemy.position.y >= player.position.y:
					lose_game()
					return

func lose_game() -> void: # TODO
	game_over = true
	move_enemies_timer.stop()
	
	if get_tree().change_scene("res://UI/Game Over.tscn") != OK:
		print_debug("An error occurred while attempting to change to the game over scene.")

func _on_Player_died() -> void:
	lose_game()

func _on_Enable_Enemy_Shoot_timeout() -> void:
	enemy_shoot_timer.wait_time = rand_range(MIN_ENEMY_SHOOT_COOLDOWN, MAX_ENEMY_SHOOT_COOLDOWN)
	enemy_shoot_timer.start()

func _on_Enemy_Shoot_timeout() -> void:
	enemy_shoot_timer.wait_time = rand_range(MIN_ENEMY_SHOOT_COOLDOWN, MAX_ENEMY_SHOOT_COOLDOWN)
	var rand_enemy = null
	while rand_enemy == null:
		rand_enemy = enemy_rows[randi() % NUM_OF_ROWS][randi() % NUM_OF_ENEMIES_IN_ROW]
	rand_enemy.shoot(ENEMY_SHOOT_DIRECTION)

func _on_enemy_death() -> void:
	hud.score += 1
	
	if are_all_enemies_dead():
		reset_enemies()

func are_all_enemies_dead() -> bool:
	for row in enemy_rows:
		for enemy in row:
			if enemy != null and not enemy.dead:
				return false
	return true
