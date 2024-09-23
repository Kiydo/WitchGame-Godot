extends AnimatedSprite2D

var bullet_impact_effect = preload("res://Prefab/Entities/Projectiles/enemy_bullet_impact_effect.tscn")

@export var BULLETDAMAGE = 10

enum Bullet_direction {LEFT, RIGHT}

var current_bullet_direction
var speed : int = 1500
var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bullet_movement(delta)

func bullet_movement(delta):
	if direction != null:
		global_position += direction * speed * delta

func get_damage_amount() -> int:
	return BULLETDAMAGE

func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	print("enemy bullet area entered")
	bullet_impact()


func _on_hitbox_body_entered(body: Node2D) -> void:
	print("enemy bullet entered body")
	bullet_impact()
	
func bullet_impact():
	print("impacting bullet")
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()
