extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# NOTES
# "_" used as "private" only to be used on this script
# !is_on_floor available via "Characterbody2D"
# Variables
const GRAVITY = 1000
const SPEED =  1000
# List of States of the player
enum State {IDLE, RUN, JUMP}
# variable to represent current state of player 
var current_state

# _ready(): first function called only once
func _ready():
	# To initialize idle state first
	current_state = State.IDLE

# _process(delta): every frame by time delta
# _physics_prcoess(delta): for physics interactions and animations for player
func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	
	move_and_slide()
	
	player_animations()
	
# Function for player gravity
func player_falling(delta):
	# checks if player is on floor, (!is_on_floor available via "Characterbody2D")
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = State.IDLE

func player_run(delta):
	# Gets player direction depending on user input (created through project settings>input map)
	var direction = Input.get_axis("move_left", "move_right")
	# If player is running or not
	if direction:
		velocity.x = direction * SPEED # speed of the player horizontal movement
	else:
		velocity.x = move_toward(velocity.x, 0 ,SPEED) # gradually reduces speed when zero input
		
	# Sets Run State
	if direction != 0:
		current_state = State.RUN
		# if player goes left it flips sprite animation to indicate direction
		animated_sprite_2d.flip_h = false if direction > 0 else true

# Function for playing sprite animation, ("play" available via AnimationPlayer )
func player_animations():
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
	elif current_state == State.JUMP:
		animated_sprite_2d.play("jump")
		
