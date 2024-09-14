extends AnimatedSprite2D
@onready var cast_time: Timer = $Cast_Time

enum Bullet_direction {LEFT, RIGHT}

var current_bullet_direction
var speed : int = 2800
var direction : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	bullet_movement(delta)
	#spell_cast_time(delta)
#
#func spell_cast_time(delta):
	#cast_time.one_shot = true
	#cast_time.start()
	#await cast_time.timeout
	#bullet_movement(delta)

func bullet_movement(delta):
	if current_bullet_direction == 0: # bullet goes right
		flip_h = false # can just use flip_h due to AnimatedSprite2D already being extended
		move_local_x(1 * speed * delta)
		
	if current_bullet_direction == 1: # bullet goes left
		flip_h = true
		move_local_x(-1 * speed * delta)

func _on_timer_timeout():
	queue_free() # deletes bullet
