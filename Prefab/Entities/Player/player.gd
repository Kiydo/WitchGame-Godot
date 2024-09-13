extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D/AnimatedSprite2D2
@onready var hotbar = $"../Ui/CanvasLayer/bottom/Hotbar"

# NOTES
# "_" used as "private" only to be used on this script
# !is_on_floor available via "Characterbody2D"

# Variables
@export var SPEED : int = 1500
@export var GRAVITY : int = 3000
@export var JUMPFORCE : int = -1500
@export var JUMP_HORIZONTAL : int = 100
@export var DASH_SPEED : int = 5000
@export var DASH_DURATION = 0.6
@export var DASH_TIME_LEFT = 0
# List of States of the player
enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}
# variable to represent current state of player 
var current_state : State # to make it static variable to States only
var animation_trigger = false # to prevent other animations from overiding current animation playing
var character_sprite : Sprite2D
#var can_change_animation = true # So animations can finish
var is_recharging : bool = false
var has_jumped : bool = false
var has_doublejumped : bool = false

var current_slot # index for a, s, d = 3,4,5
# _ready(): first function called only once
func _ready():
	# To initialize idle state first
	current_state = State.IDLE
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	print(hotbar)

# _process(delta): every frame by time delta
# _physics_prcoess(delta): for physics interactions and animations for player
func _physics_process(delta : float):
	if is_recharging == false:
		player_dash(delta)
		if current_state != State.DASH:
			player_falling(delta)
			player_idle(delta)
			player_run(delta)
			player_jump(delta)
			player_doublejump(delta)
			player_attack(delta)
			player_hotbar(delta)
		
	
	player_recharge(delta)
	
	move_and_slide()
	
	player_animations()
	

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction

# Function for player gravity
func player_falling(delta : float):
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
		has_jumped = false
		has_doublejumped = false
		current_state = State.IDLE

func player_jump(delta : float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMPFORCE
		current_state = State.JUMP_START
		has_jumped = true
	if !is_on_floor():
		if current_state == State.JUMP_UP or current_state == State.JUMP_FALL:
			var direction = input_movement()
			if direction != 0 and !is_on_floor():
				animated_sprite_2d.flip_h = false if direction > 0 else true
				velocity.x += direction * JUMP_HORIZONTAL * delta

func player_doublejump(delta : float):
	if Input.is_action_just_pressed("jump") and !is_on_floor() and has_doublejumped == false:
		print("has double jumped")
		has_jumped = false
		velocity.y = JUMPFORCE
		current_state = State.DOUBLEJUMP
		has_doublejumped = true

func player_idle(delta : float):
	if is_on_floor() and current_state != State.JUMP_END:
		current_state = State.IDLE

func player_run(delta : float):
	# Gets player direction depending on user input (created through project settings>input map)
	var direction = input_movement()
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

func player_dash(delta : float):
	if Input.is_action_just_pressed("dash"):
		current_state = State.DASH
		DASH_TIME_LEFT = DASH_DURATION
		var direction = 1
		if animated_sprite_2d.flip_h:
			direction = -1
		
		velocity.x = direction * (DASH_SPEED * 50) * delta
		
	if current_state == State.DASH:
		DASH_TIME_LEFT -= delta
		if DASH_TIME_LEFT <= 0:
			current_state = State.IDLE

func player_recharge(delta : float):
	if Input.is_action_pressed("recharge") and is_on_floor:
		if !is_recharging:
			velocity = Vector2.ZERO
			if velocity == Vector2.ZERO:
				is_recharging = true
				velocity.y += GRAVITY * delta
			current_state = State.RECHARGE
	elif !Input.is_action_pressed("recharge"):
		if is_recharging:
			print("stopped animatiojns")
			is_recharging = false
			animated_sprite_2d_2.play("nothing")
			animation_trigger = false
			return
		#animated_sprite_2d.play("idle")

func player_hotbar(delta : float):
	if Input.is_action_just_pressed("slotA"):
		current_slot = 3
		hotbar.select(current_slot)
		print(current_slot)
	if Input.is_action_just_pressed("slotS"):
		current_slot = 4
		hotbar.select(current_slot)
		print(current_slot)
	if Input.is_action_just_pressed("slotD"):
		current_slot = 5
		hotbar.select(current_slot)
		print(current_slot)
		

func player_attack(delta : float):
	if Input.is_action_just_pressed("melee"):
		if is_on_floor():
			current_state = State.MELEE
		if !is_on_floor():
			current_state = State.MELEE_AIR
	if Input.is_action_just_pressed("magic_attack") and current_slot != null:
		match current_slot:
			3: # Magic Bullet
				print("magic bullet")
				current_state = State.BULLET
			4: # Fire Ball
				print("fire ball")
				current_state = State.FIREBALL
			5: # Magic Beam
				if !is_on_floor():
					print("beam air")
					current_state = State.BEAM_AIR
				else:
					print("beam ground")
					current_state = State.BEAM


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
		State.RECHARGE:
			if animation_trigger == false and is_recharging == true:
				animation_trigger = true
				animated_sprite_2d.play("recharge")
				animated_sprite_2d_2.play("recharge")
		State.DOUBLEJUMP:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("double_jump")
		State.DASH:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("dash")
		State.BULLET:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("bullet")
		State.FIREBALL:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("fireball")
		State.BEAM:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("beam")
		State.BEAM_AIR:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("beam_air")
		State.MELEE:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("melee")
		State.MELEE_AIR:
			if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("melee_air")

func _on_animation_finished():
	animation_trigger = false
