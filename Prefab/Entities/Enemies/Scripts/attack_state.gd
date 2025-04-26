extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var SPEED : int
@export var GRAVITY : int = 3000
@export var enemy_type : String

var bullet = preload("res://Prefab/Entities/Projectiles/enemy_bullet.tscn")
var melee_hitbox = preload("res://Prefab/Entities/Projectiles/enemy_melee_hit_box.tscn")


var player : CharacterBody2D
var direction_vector
# Goblin Variables
var goblin_fire_rate : float = 1.1
var goblin_can_attack : bool = true
var goblin_cooldown_timer : Timer

# Skeleton Variables
enum Melee_Direction {LEFT, RIGHT}
var skeleton_fire_rate : float = 0.4
var skeleton_can_attack : bool = true
var skeleton_cooldown_timer : Timer

func _ready():
	# Goblin Attack Timer
	goblin_cooldown_timer = Timer.new()
	goblin_cooldown_timer.one_shot = true
	goblin_cooldown_timer.wait_time = goblin_fire_rate
	add_child(goblin_cooldown_timer)
	goblin_cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_complete"))
	# Skeleton Attack Timer
	skeleton_cooldown_timer = Timer.new()
	skeleton_cooldown_timer.one_shot = true
	skeleton_cooldown_timer.wait_time = skeleton_fire_rate
	add_child(skeleton_cooldown_timer)
	skeleton_cooldown_timer.connect("timeout", Callable(self, "_on_cooldown_complete"))

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	enemy_gravity(delta)
	var direction : int
	
	if character_body_2d.global_position > player.global_position and !character_body_2d.is_in_group("Slime"): # default left
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

	animated_sprite_2d.play("attack")
	
	if character_body_2d.is_in_group("Skeleton"):
		skeleton_attack(delta, direction)
	elif character_body_2d.is_in_group("Slime"):
		slime_attack(delta, direction)
	elif character_body_2d.is_in_group("Goblin"):
		goblin_attack(delta, direction)

func spawn_melee():
	print("Spawning Enemy melee")
	var melee_hitbox_instance = melee_hitbox.instantiate() as Node2D
	if character_body_2d.global_position > player.global_position and !character_body_2d.is_in_group("Slime"):
		melee_hitbox_instance.current_melee_direction = -1
	elif character_body_2d.global_position < player.global_position and !character_body_2d.is_in_group("Slime"):
		melee_hitbox_instance.current_melee_direction = 1
	return melee_hitbox_instance

func skeleton_attack(delta: float, direction : int):
	if skeleton_can_attack:
		print("skeleton attack")
		# sprite placement
		character_body_2d.velocity.x += direction * SPEED * delta
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -SPEED, SPEED)
		character_body_2d.move_and_slide()
		var enemy_melee = spawn_melee()
		var direction_vector = (player.global_position - character_body_2d.global_position).normalized()
		print("direction vector for skeleton attack: ", direction_vector)
		if direction_vector.x >= 0:
			enemy_melee.current_melee_direction = Melee_Direction.LEFT
		elif direction_vector.x < 0:
			enemy_melee.current_melee_direction = Melee_Direction.RIGHT
		
		#enemy_melee.direction = direction_vector
		print("direction for melee: ", direction_vector)
		enemy_melee.global_position = character_body_2d.global_position
		get_parent().add_child(enemy_melee)
		skeleton_can_attack = false
		skeleton_cooldown_timer.start()
	else:
		print("skeleton attack on cooldown")

func slime_attack(delta: float, direction: int):
	print("slime attack")
	character_body_2d.velocity.x += direction * SPEED * delta
	character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -SPEED, SPEED)
	character_body_2d.move_and_slide()
	
func goblin_attack(delta: float, direction : int):
	if goblin_can_attack:
		
		#print("goblin attack")
		var bullet_instance = bullet.instantiate() as Node2D
		
		var direction_vector = (player.global_position - character_body_2d.global_position).normalized()
		
		bullet_instance.direction = direction_vector
		print(direction)
		
		bullet_instance.global_position = character_body_2d.global_position
		get_parent().add_child(bullet_instance)
		
		goblin_can_attack = false
		goblin_cooldown_timer.start()

func _on_cooldown_complete():
	goblin_can_attack = true
	print("goblin cooldown complete")

func enemy_gravity(delta: float):
	character_body_2d.velocity.y += GRAVITY * delta

func enter():
	player = get_tree().get_nodes_in_group("Player")[0] as CharacterBody2D

func exit():
	pass
