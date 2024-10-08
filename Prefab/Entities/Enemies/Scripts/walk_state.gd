extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var SPEED : int
@export var GRAVITY : int = 3000

var player : CharacterBody2D

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	enemy_gravity(delta)
	var direction : int
	
	if character_body_2d.global_position > player.global_position and !character_body_2d.is_in_group("Slime"):
		animated_sprite_2d.flip_h = true
		direction = -1
	elif character_body_2d.global_position < player.global_position and !character_body_2d.is_in_group("Slime"):
		animated_sprite_2d.flip_h = false
		direction = 1
	# Below strictly for slime because of sprite default faceing
	elif character_body_2d.global_position > player.global_position and character_body_2d.is_in_group("Slime"):
		animated_sprite_2d.flip_h = false
		direction = -1
	elif character_body_2d.global_position < player.global_position and character_body_2d.is_in_group("Slime"):
		animated_sprite_2d.flip_h = true
		direction = 1

	animated_sprite_2d.play("walk")
	
	character_body_2d.velocity.x += direction * SPEED * delta
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -SPEED, SPEED)
	character_body_2d.move_and_slide()

func enemy_gravity(delta: float):
	character_body_2d.velocity.y += GRAVITY * delta

func enter():
	if is_inside_tree() and get_tree() != null:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0] as CharacterBody2D
		else:
			print("No players found in the group.")
	else:
		print("Node is not inside the scene tree or get_tree() is null.")

func exit():
	pass
