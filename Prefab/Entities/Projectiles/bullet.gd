extends AnimatedSprite2D

var bullet_impact_effect = preload("res://Prefab/Entities/Projectiles/bullet_impact_effect.tscn")

@export var BULLETDAMAGE = 5

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

func get_damage_amount() -> int:
	return BULLETDAMAGE

func _on_timer_timeout():
	queue_free() # deletes bullet


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("bullet area entered")
	bullet_impact()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("bullet entered body")
	bullet_impact()
	
	
func bullet_impact():
	print("impacting bullet")
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()
