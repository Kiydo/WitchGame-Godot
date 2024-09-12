# Script attached to Area2D of Skeleton Entity for when player body interacts with Skeleton body

extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var patrol_points : Node # gets the patrol points node after assigning from inspector
@export var GRAVITY : int = 3000
@export var SPEED = 1500

enum State {IDLE, WALK, ATTACK}
var current_state : State
var direction : Vector2 = Vector2.LEFT
# Variables for enemeny patrol points
var number_of_points : int
var point_positions: Array[Vector2]
var current_point : Vector2
var current_point_position : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size() # gets how many patrol points
		for point in patrol_points.get_children(): # gets data from PatrolPoints
			point_positions.append(point.global_position) #Assigned position of points into array
		current_point = point_positions[current_point_position] # sets 1st point as current point position, current_point_position = 0 in array currently
	else:
		print("Skeleton no patrol point")
			
	current_state = State.IDLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animations()

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta: float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	current_state = State.IDLE
	
func enemy_walk(delta: float):
	if abs(position.x - current_point.x) > 0.5: # if current position is further than 0.5 from patrol point keep walking
		velocity.x = direction.x * SPEED * delta
		current_state = State.WALK
	else:
		current_point_position += 1 # change patrol point position via array
		
	if current_point_position >= number_of_points: # to keep same logic when 2nd patrol point is reached so that array doesn't go over
		current_point_position = 0
	
	current_point = point_positions[current_point_position]
	
	if current_point.x > position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	
	if direction == Vector2.LEFT: # sprite direction facing
		# if player goes left it flips sprite animation to indicate direction
		animated_sprite_2d.flip_h = false if direction == Vector2.RIGHT else true
	
func enemy_animations():
	match current_state:
		State.IDLE:
			animated_sprite_2d.play("idle")
		State.WALK:
			animated_sprite_2d.play("walk")
		State.ATTACK:
			animated_sprite_2d.play("attack")
