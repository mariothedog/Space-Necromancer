extends Area2D

# Get nodes
onready var visibility_notifier = get_node("VisibilityNotifier2D")

# Variables
var velocity = Vector2()
var collisions = 0
var max_collisions = 1
var immortal = false

func _ready():
	if connect("body_entered", self, "_on_Bullet_body_entered") != OK:
		print_debug("An error occurred while connecting the body_entered bullet signal to the _on_Bullet_body_entered method.")
	
	if visibility_notifier.connect("screen_exited", self, "_on_bullet_screen_exit") != OK:
		print_debug("An error occurred while connecting the visibility_notifier's screen_exited signal to the _on_bullet_screen_exit method.")

func _physics_process(delta) -> void:
	position += velocity * delta

func _on_Bullet_body_entered(body) -> void:
	if body.immortal:
		return
	
	body.die()
	collisions += 1
	if collisions >= max_collisions:
		queue_free()

func _on_bullet_screen_exit() -> void:
	queue_free()
