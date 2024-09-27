# player.gd is the main script related to the player, the other player scripts such as "player_attack" and "player_movement" use this script
# player.gd script is responsible for the timers required for the attacks and animation player
# NOTES
# "_" used as "private" only to be used on this script
# !is_on_floor available via "Characterbody2D"

extends CharacterBody2D
# ANIMATION NODES
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D/AnimatedSprite2D2
# IMPORTED NODES
@onready var hotbar = $"../Ui/CanvasLayer/bottom/Hotbar"
@onready var wand : Marker2D = $Wand
# SFX
@onready var audio_jump: AudioStreamPlayer = $AudioManager/Jump
@onready var audio_doublejump: AudioStreamPlayer = $AudioManager/doublejump
@onready var audio_dash: AudioStreamPlayer = $AudioManager/dash
@onready var audio_melee_1: AudioStreamPlayer = $AudioManager/melee1
@onready var audio_melee_2: AudioStreamPlayer = $AudioManager/melee2
@onready var audio_jumpland: AudioStreamPlayer = $AudioManager/jumpland
@onready var audio_bullet: AudioStreamPlayer = $AudioManager/bullet
@onready var audio_fireballcast: AudioStreamPlayer = $AudioManager/fireballcast
@onready var audio_fireball: AudioStreamPlayer = $AudioManager/fireball
# PRELOADED SCRIPTS AND NODES
@onready var movement = preload("res://Prefab/Entities/Player/Scripts/player_movement.gd").new()
@onready var attack = preload("res://Prefab/Entities/Player/Scripts/player_attack.gd").new()
var bullet = preload("res://Prefab/Entities/Projectiles/bullet.tscn")
var fireball = preload("res://Prefab/Entities/Projectiles/fireball.tscn")
# EXPORTED VALUES
@onready var attack_duration : float = 0.1
@export var PLAYERHEALTH = 100


# STATES
enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE_1, MELEE_2, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}
enum ComboState {NONE, MELEE_1, MELEE_2}
enum Player_direction {RIGHT, LEFT} # player direction state
# VARIABLES
# variable to represent current state of player 
var current_state : State # to make it static variable to States only
var current_player_direction
var current_combo_state: ComboState = ComboState.NONE
var animation_trigger = false # to prevent other animations from overiding current animation playing
var animation_trigger2 = false
var character_sprite : Sprite2D
var is_recharging : bool = false
var wand_position # for the wand position where attack spells spawn
# Variables related to the timers
var combo_reset_time: float = 1.0 # time to reset combo if no follow-up attack happens 
var attack_cooldown : float = 1
var is_on_cooldown : bool = false
var is_attacking : bool = false
# TIMERS
var combo_timer: Timer = null
var cooldown_timer : Timer = null
var bullet_timer : Timer = null

# _ready(): first function called only once
func _ready():
	current_state = State.IDLE
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))
	animated_sprite_2d_2.connect("animation_finished", Callable(self, "_on_animation_finished2"))
	
	combo_timer = Timer.new()
	combo_timer.wait_time = combo_reset_time
	combo_timer.one_shot = true
	add_child(combo_timer)
	combo_timer.connect("timeout", Callable(self, "_on_combo_reset"))
	
	print(hotbar)
	wand_position = wand.position

# _process(delta): every frame by time delta
# _physics_prcoess(delta): for physics interactions and animations for player
func _physics_process(delta : float):
	if is_recharging == false:
		movement.player_dash(delta, self, velocity)
		if current_state != State.DASH:
			player_face_direction()
			movement.player_falling(delta, self, velocity)
			movement.player_idle(delta, self)
			movement.player_run(delta, self, velocity)
			movement.player_jump(delta, self, velocity)
			movement.player_doublejump(delta, self)
			attack.player_attack(delta, self)
			attack.player_hotbar(delta, self)
	attack.player_recharge(delta, self)
	move_and_slide()
	player_animations()

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction

# determines which direction the player is facing and saves it into a variable
func player_face_direction():
	var direction = input_movement()
	if direction > 0:
		current_player_direction = Player_direction.RIGHT
	elif direction < 0:
		current_player_direction = Player_direction.LEFT

# to prevent desynced timers
func on_timer_timeout():
	bullet_timer.queue_free()
	bullet_timer = null

# The amount of time the attack takes
func run_timer(duration: float) -> void:
	if bullet_timer !=null:
		#print("Timer already running")
		return
	#print("casting time: " )
	bullet_timer = Timer.new()
	bullet_timer.wait_time = duration
	bullet_timer.one_shot = true
	add_child(bullet_timer)
	bullet_timer.start()
	await bullet_timer.timeout
	is_attacking = false
	bullet_timer.queue_free()
	bullet_timer.timeout.connect(on_timer_timeout) 

# spell cooldown timer to prevent player spam
func spell_cooldown(cooldown: float) -> void:
	#print("cooldown")
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	is_on_cooldown = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()
	await cooldown_timer.timeout
	is_on_cooldown = false

# matching times depending on which spell is cast
func player_cast_time(this_slot: int, casttime):
	match this_slot:
		3:
			await run_timer(casttime)
		4:
			await run_timer(casttime)
		5:
			await run_timer(casttime)
			
# starts the combo timer
func _start_combo_timer():
	combo_timer.start()
# resets combo
func _on_combo_reset():
	current_combo_state = ComboState.NONE

# Function for playing sprite animation, ("play" available via AnimationPlayer )
func player_animations():
	if animation_trigger2 == false:
		#print(State)
		animated_sprite_2d_2.play("nothing")
	match current_state:
		State.IDLE:
			if animation_trigger == false:
				animated_sprite_2d.play("idle")
		State.RUN:
			if animation_trigger == false:
				animated_sprite_2d.play("run")
		State.JUMP_START:
			audio_jump.play()
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
			if is_recharging == true:
				animation_trigger = true
				animation_trigger2 = true
				animated_sprite_2d.play("recharge")
				animated_sprite_2d_2.play("recharge")
		State.DOUBLEJUMP:
			audio_doublejump.play()
			animation_trigger = true
			animation_trigger2 = true
			animated_sprite_2d.play("double_jump")
			animated_sprite_2d_2.play("doublejump")
		State.DASH:
			animation_trigger = true
			animated_sprite_2d.play("dash")
		State.BULLET:
			audio_bullet.play()
			animation_trigger = true
			animated_sprite_2d.play("bullet")
		State.FIREBALL:
			audio_fireballcast.play()
			animation_trigger = true
			animated_sprite_2d.play("fireball")
			audio_fireball.play()
				
		State.BEAM:
			animation_trigger = true
			animated_sprite_2d.play("beam")
				
		State.BEAM_AIR:
			animation_trigger = true
			animated_sprite_2d.play("beam_air")
				
		State.MELEE_1:
			audio_melee_1.play()
			animation_trigger = true
			animated_sprite_2d.play("melee_1")
		State.MELEE_2:
			audio_melee_2.play()
			animation_trigger= true
			animated_sprite_2d.play("melee_2")
		State.MELEE_AIR:
			animation_trigger = true
			animated_sprite_2d.play("melee_air")

# For when animations finish
func _on_animation_finished():
	animation_trigger = false
func _on_animation_finished2():
	animation_trigger2 = false
