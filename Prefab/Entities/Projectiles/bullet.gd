extends AnimatedSprite2D

enum Bullet_direction {LEFT, RIGHT}

var current_bullet_direction
var speed : int = 2800
var direction : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	bullet_movement(delta)

func bullet_movement(delta):
	#print(current_bullet_direction)
	if current_bullet_direction == null: # bullet goes right
		#print("bullet going right")
		move_local_x(1 * speed * delta)
	if current_bullet_direction == 1: # bullet goes left
		#print("bullet going left")
		move_local_x(-1 * speed * delta)

func _on_timer_timeout():
	queue_free() # deletes bullet
