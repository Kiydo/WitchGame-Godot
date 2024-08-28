extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# NOTES
# "_" used as "private" only to be used on this script
# !is_on_floor available via "Characterbody2D"
# Variables
const GRAVITY = 2000
const SPEED =  1000
const JUMPFORCE = -1500
const JUMP_HORIZONTAL = 100
const JUMP_START_TIMER = 0.5
const JUMP_END_TIMER = 0.5
# List of States of the player
enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END}
# variable to represent current state of player 
var current_state
var animation_trigger = false
#var can_change_animation = true # So animations can finish

# _ready(): first function called only once
func _ready():
	# To initialize idle state first
	current_state = State.IDLE
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))

# _process(delta): every frame by time delta
# _physics_prcoess(delta): for physics interactions and animations for player
func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	move_and_slide()
	
	#print(can_change_animation)
	#if !can_change_animation:
		#_on_animation_finished()
	
	player_animations()
	
# Function for player gravity
func player_falling(delta):
	# checks if player is on floor, (!is_on_floor available via "Characterbody2D")
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			current_state = State.JUMP_UP
		else:
			current_state = State.JUMP_FALL
	elif current_state == State.JUMP_FALL:
		current_state = State.JUMP_END
	elif is_on_floor():
		current_state = State.IDLE

func player_jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMPFORCE
		current_state = State.JUMP_START
	if !is_on_floor():
		if current_state == State.JUMP_UP or current_state == State.JUMP_FALL:
			var direction = Input.get_axis("move_left", "move_right")
			if direction != 0 and !is_on_floor():
				animated_sprite_2d.flip_h = false if direction > 0 else true
				velocity.x += direction * JUMP_HORIZONTAL * delta
		

func player_idle(delta):
	if is_on_floor() and current_state != State.JUMP_END:
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
	if direction != 0 and is_on_floor():
		current_state = State.RUN
		# if player goes left it flips sprite animation to indicate direction
		animated_sprite_2d.flip_h = false if direction > 0 else true

# Function for playing sprite animation, ("play" available via AnimationPlayer )
func player_animations():
	match current_state:
		State.IDLE:
			if animation_trigger == false:
				animated_sprite_2d.play("idle")
		State.RUN:
			if animation_trigger == false:
				animated_sprite_2d.play("run")
		State.JUMP_START:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("jump_start")
			
		State.JUMP_UP:
			if animation_trigger == false:
				animated_sprite_2d.play("jump_up")
		State.JUMP_FALL:
			if animation_trigger == false:
				animated_sprite_2d.play("jump_fall")
		State.JUMP_END:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("jump_end")

func _on_animation_finished():
	animation_trigger = false
#func player_animations():
	#match current_state:
		#State.IDLE:
			#if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "idle":
				#animated_sprite_2d.play("idle")
		#State.RUN:
			#if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "run":
				#animated_sprite_2d.play("run")
		#State.JUMP_START:
			#
			#animated_sprite_2d.play("jump_start")
			#if not animated_sprite_2d.is_playing():
				#current_state = State.JUMP_UP
		#State.JUMP_UP:
			#if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "jump_up":
				#animated_sprite_2d.play("jump_up")
		#State.JUMP_FALL:
			#if not animated_sprite_2d.is_playing() or animated_sprite_2d.animation != "jump_fall":
				#animated_sprite_2d.play("jump_fall")
		#State.JUMP_END:
			#print("landed")
			#animated_sprite_2d.play("jump_end")
			#if not animated_sprite_2d.is_playing():
				#print("idle")
				#current_state = State.IDLE
