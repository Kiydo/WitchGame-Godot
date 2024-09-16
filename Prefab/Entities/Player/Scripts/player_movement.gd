extends Node

enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}

# Variables
@export var SPEED : int = 1500
@export var GRAVITY : int = 3000
@export var JUMPFORCE : int = -1500
@export var JUMP_HORIZONTAL : int = 100
@export var DASH_SPEED : int = 5000
@export var DASH_DURATION = 0.6
@export var DASH_TIME_LEFT = 0

var has_jumped : bool = false
var has_doublejumped : bool = false

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction

func player_falling(delta : float, velocity : Vector2, current_state : State):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			current_state = State.JUMP_UP
		else:
			current_state = State.JUMP_FALL
	elif current_state == State.JUMP_FALL:
		current_state = State.JUMP_END
