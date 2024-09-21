extends AnimatedSprite2D
@onready var cast_time: Timer = $Cast_Time

@export var BULLETDAMAGE = 20

var bullet_impact_effect = preload("res://Prefab/Entities/Enemies/enemy_death_effect.tscn")

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
	#print(current_bullet_direction)
	if current_bullet_direction == 0: # bullet goes right
		flip_h = false # can just use flip_h due to AnimatedSprite2D already being extended
		move_local_x(1 * speed * delta)
		
	if current_bullet_direction == 1: # bullet goes left
		flip_h = true
		move_local_x(-1 * speed * delta)

func _on_timer_timeout():
	queue_free() # deletes bullet

func get_damage_amount():
	return BULLETDAMAGE

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("fireball area entered")
	bullet_impact()


func _on_hitbox_body_entered(body: Node2D) -> void:
	print("fireball entered body")
	bullet_impact()
	
func bullet_impact():
	print("impacting bullet")
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()
