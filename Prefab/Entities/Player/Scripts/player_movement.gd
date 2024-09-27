extends Node
# STATE LISTS
enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE_1, MELEE_2, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}

# EXPORTED VARIABLES
@export var SPEED : int = 1500
@export var GRAVITY : int = 3000
@export var JUMPFORCE : int = -1500
@export var JUMP_HORIZONTAL : int = 100
@export var DASH_SPEED : int = 5000
@export var DASH_DURATION = 0.6
@export var DASH_TIME_LEFT = 0
# BOOLEONS
var has_jumped : bool = false
var has_doublejumped : bool = false
# gravity logic for the player
func player_falling(delta : float, player: CharacterBody2D, velocity : Vector2):
	if !player.is_on_floor():
		player.velocity.y += GRAVITY * delta
		if player.velocity.y < 0:
			player.current_state = State.JUMP_UP
		else:
			player.current_state = State.JUMP_FALL
	elif player.current_state == State.JUMP_FALL:
		player.current_state = State.JUMP_END
	elif player.is_on_floor():
		has_jumped = false
		has_doublejumped = false
		player.current_state = State.IDLE
# jump logic for the player
func player_jump(delta : float, player: CharacterBody2D, velocity : Vector2):
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = JUMPFORCE
		player.current_state = State.JUMP_START
		has_jumped = true
	if !player.is_on_floor():
		if player.current_state == State.JUMP_UP or player.current_state == State.JUMP_FALL:
			var direction = player.input_movement()
			if direction != 0 and !player.is_on_floor():
				player.animated_sprite_2d.flip_h = false if direction > 0 else true
				player.velocity.x += direction * JUMP_HORIZONTAL * delta
# double jump spell logic for the player
func player_doublejump(delta : float, player: CharacterBody2D):
	if Input.is_action_just_pressed("jump") and !player.is_on_floor() and has_doublejumped == false:
		print("has double jumped")
		has_jumped = false
		#player.animation_trigger2 = true
		player.velocity.y = JUMPFORCE
		player.current_state = State.DOUBLEJUMP
		has_doublejumped = true
# function for when the player is idle (not doing anything : DEFAULT)
func player_idle(delta : float, player: CharacterBody2D):
	if player.is_on_floor() and player.current_state != State.JUMP_END:
		player.current_state = State.IDLE
# Player running logic
func player_run(delta : float, player: CharacterBody2D, velocity : Vector2):
	# Gets player direction depending on user input (created through project settings>input map)
	var direction = player.input_movement()
	# If player is running or not
	if direction:
		player.velocity.x = direction * SPEED # speed of the player horizontal movement
	else:
		player.velocity.x = move_toward(velocity.x, 0 ,SPEED) # gradually reduces speed when zero input
	# Sets Run State
	if direction != 0 and player.is_on_floor():
		player.current_state = State.RUN
		# if player goes left it flips sprite animation to indicate direction
		player.animated_sprite_2d.flip_h = false if direction > 0 else true
# Player dash spell logic
func player_dash(delta : float, player: CharacterBody2D, velocity : Vector2):
	if Input.is_action_just_pressed("dash"):
		player.current_state = State.DASH
		player.audio_dash.play() # moved audio player here due to dash state being repeated
		DASH_TIME_LEFT = DASH_DURATION
		var direction = 1
		if player.animated_sprite_2d.flip_h:
			direction = -1
		player.velocity.x = direction * (DASH_SPEED * 50) * delta
	if player.current_state == State.DASH:
		DASH_TIME_LEFT -= delta
		if DASH_TIME_LEFT <= 0:
			player.current_state = State.IDLE
