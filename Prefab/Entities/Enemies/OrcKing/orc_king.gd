extends CharacterBody2D

var enemy_death_effect = preload("res://Prefab/Entities/Enemies/enemy_death_effect.tscn")

const SPEED = 300.0
@export var HEALTH = 100


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
func enemy_health():
	var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
	enemy_death_effect_instance.global_position = global_position
	get_parent().add_child(enemy_death_effect_instance)
	queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("hurtbox area enetered skeleton")
	if area.get_parent().has_method("get_damage_amount"):
		print("inside tinhgy")
		var node = area.get_parent() as Node
		HEALTH -= node.BULLETDAMAGE
		print("health: ", HEALTH)
		if HEALTH <= 0:
			enemy_health()
	elif area.has_method("get_damage_amount"):
		HEALTH -= area.BULLETDAMAGE
		print("health: ", HEALTH)
		if HEALTH <= 0:
			enemy_health()
