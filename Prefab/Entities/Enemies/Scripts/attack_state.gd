extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var SPEED : int
@export var GRAVITY : int = 3000
@export var enemy_type : String

var player : CharacterBody2D

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	enemy_gravity(delta)
	var direction : int
	
	if character_body_2d.global_position > player.global_position:
		animated_sprite_2d.flip_h = true
		direction = -1
	elif character_body_2d.global_position < player.global_position:
		animated_sprite_2d.flip_h = false
		direction = 1

	animated_sprite_2d.play("attack")
	
	if character_body_2d.is_in_group("Skeleton"):
		skeleton_attack(delta, direction)
	elif character_body_2d.is_in_group("Slime"):
		slime_attack(delta, direction)

func skeleton_attack(delta: float, direction : int):
	character_body_2d.velocity.x += direction * SPEED * delta
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -SPEED, SPEED)
	character_body_2d.move_and_slide()

func slime_attack(delta: float, direction: int):
	character_body_2d.velocity.x += direction * SPEED * delta
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -SPEED, SPEED)
	character_body_2d.move_and_slide()

func enemy_gravity(delta: float):
	character_body_2d.velocity.y += GRAVITY * delta

func enter():
	player = get_tree().get_nodes_in_group("Player")[0] as CharacterBody2D

func exit():
	pass
