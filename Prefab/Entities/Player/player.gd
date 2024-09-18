extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D/AnimatedSprite2D2
@onready var hotbar = $"../Ui/CanvasLayer/bottom/Hotbar"
@onready var wand : Marker2D = $Wand
@onready var movement = preload("res://Prefab/Entities/Player/Scripts/player_movement.gd").new()
@onready var attack = preload("res://Prefab/Entities/Player/Scripts/player_attack.gd").new()

var bullet = preload("res://Prefab/Entities/Projectiles/bullet.tscn")
var fireball = preload("res://Prefab/Entities/Projectiles/fireball.tscn")

# NOTES
# "_" used as "private" only to be used on this script
# !is_on_floor available via "Characterbody2D"

# Variables
@export var PLAYERHEALTH = 100
# List of States of the player
enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}
# variable to represent current state of player 
var current_state : State # to make it static variable to States only
var animation_trigger = false # to prevent other animations from overiding current animation playing
var character_sprite : Sprite2D
#var can_change_animation = true # So animations can finish
var is_recharging : bool = false

var wand_position

enum Player_direction {RIGHT, LEFT}
var current_player_direction

var attack_cooldown : float = 1
var is_on_cooldown : bool = false
var is_attacking : bool = false
var cooldown_timer : Timer = null
var bullet_timer : Timer = null
# _ready(): first function called only once
func _ready():
	current_state = State.IDLE
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
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

		
func player_face_direction():
	var direction = input_movement()
	
	if direction > 0:
		current_player_direction = Player_direction.RIGHT
	elif direction < 0:
		current_player_direction = Player_direction.LEFT

func on_timer_timeout():
	bullet_timer.queue_free()
	bullet_timer = null

func run_timer(duration: float) -> void:
	if bullet_timer !=null:
		print("Timer already running")
		return
	
	print("casting time: " )
	bullet_timer = Timer.new()
	bullet_timer.wait_time = duration
	bullet_timer.one_shot = true
	add_child(bullet_timer)
	bullet_timer.start()
	await bullet_timer.timeout
	is_attacking = false
	bullet_timer.queue_free()
	
	bullet_timer.timeout.connect(on_timer_timeout) 

func spell_cooldown(cooldown: float) -> void:
	print("cooldown")
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	is_on_cooldown = true
	cooldown_timer.wait_time = cooldown
	cooldown_timer.start()
	await cooldown_timer.timeout
	is_on_cooldown = false

func player_cast_time(this_slot: int, casttime):
	match this_slot:
		3:
			await run_timer(casttime)
		4:
			await run_timer(casttime)
		5:
			await run_timer(casttime)


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
			if is_recharging == true:
				animation_trigger = true
				animated_sprite_2d.play("recharge")
				animated_sprite_2d_2.play("recharge")
		State.DOUBLEJUMP:
			if is_attacking == false:
				animation_trigger = true
				animated_sprite_2d.play("double_jump")
		State.DASH:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("dash")
		State.BULLET:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("bullet")
		State.FIREBALL:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("fireball")
		State.BEAM:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("beam")
		State.BEAM_AIR:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("beam_air")
		State.MELEE:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("melee")
		State.MELEE_AIR:
			#if animation_trigger == false:
				animation_trigger = true
				animated_sprite_2d.play("melee_air")

func _on_animation_finished():
	animation_trigger = false
