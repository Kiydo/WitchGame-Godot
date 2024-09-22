# Script attached to Area2D of Skeleton Entity for when player body interacts with SLIME body

extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var timer: Timer = $Timer # timer for how long to wait in idle state
@export var patrol_points : Node # gets the patrol points node after assigning from inspector
@export var GRAVITY : int = 3000
@export var SPEED = 15000
@export var HEALTH = 10
#@export var wait_time : int = 3

var enemy_death_effect = preload("res://Prefab/Entities/Enemies/enemy_death_effect.tscn")

enum State {IDLE, WALK, ATTACK}
var current_state : State
var direction : Vector2 = Vector2.LEFT
#var can_walk : bool
var can_flip_sprite : bool
# Variables for enemeny patrol points
var number_of_points : int
var point_positions: Array[Vector2]
var current_point : Vector2
var current_point_position : int

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#if patrol_points != null:
		#print("slime has patrol points")
		#number_of_points = patrol_points.get_children().size() # gets how many patrol points
		#for point in patrol_points.get_children(): # gets data from PatrolPoints
			#point_positions.append(point.global_position) #Assigned position of points into array
		#current_point = point_positions[current_point_position] # sets 1st point as current point position, current_point_position = 0 in array currently
	#else:
		#print("SLime no patrol point")
			#
	##timer.wait_time = wait_time # set timer wait time easier and for diversity
	#
	##current_state = State.WALK
	#
	##animated_sprite_2d.flip_h = direction.x < 1
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float):
	#enemy_gravity(delta)
	##enemy_idle(delta)
	#enemy_walk(delta)
	#
	#move_and_slide()
	#
	#enemy_animations()
#
#func enemy_gravity(delta: float):
	#velocity.y += GRAVITY * delta
#
#func enemy_idle(delta: float):
	##if !can_walk:
		#velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		#current_state = State.IDLE
	#
#func enemy_walk(delta: float):
	##if !can_walk:
		##return
		#
	#if abs(position.x - current_point.x) > 1: # if current position is further than 0.5 from patrol point keep walking
		#velocity.x = direction.x * SPEED * delta
		#current_state = State.WALK
	#else:
		#
		#current_point_position += 1 # change patrol point position via array
		#
		#if current_point_position >= number_of_points: # to keep same logic when 2nd patrol point is reached so that array doesn't go over
			#current_point_position = 0
		#
		#current_point = point_positions[current_point_position]
		#
		#if current_point.x > position.x:
			#direction = Vector2.RIGHT
		#else:
			#direction = Vector2.LEFT
			#
		##timer.start()
		##can_walk = false
		#can_flip_sprite = false
		#
	##if can_flip_sprite == true:
	#animated_sprite_2d.flip_h = direction.x > 0 # sprite direction facing
		#
	#
#func enemy_animations():
	#match current_state:
		#State.IDLE:
			#animated_sprite_2d.play("idle")
		#State.WALK:
			#animated_sprite_2d.play("walk")
		#State.ATTACK:
			#animated_sprite_2d.play("attack")
#
#
#
##func _on_timer_timeout() -> void:
	##can_walk = true
	##can_flip_sprite = true
func enemy_health():
	var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
	enemy_death_effect_instance.global_position = global_position
	get_parent().add_child(enemy_death_effect_instance)
	queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("hurtbox area enetered")
	if area.get_parent().has_method("get_damage_amount"):
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
