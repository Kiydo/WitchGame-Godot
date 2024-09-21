extends Node

enum State {IDLE, RUN, JUMP, JUMP_START, JUMP_UP, JUMP_FALL, JUMP_END, RECHARGE, DASH, MELEE_1, MELEE_2, MELEE_AIR, BEAM, BEAM_AIR, FIREBALL, BULLET, DOUBLEJUMP}
enum Melee_direction {LEFT, RIGHT}
@export var GRAVITY : int = 3000
#@onready var hotbar = $"res://Prefab/Ui/CanvasLayer/bottom/Hotbar"

var bullet = preload("res://Prefab/Entities/Projectiles/bullet.tscn")
var fireball = preload("res://Prefab/Entities/Projectiles/fireball.tscn")
var melee_hitbox = preload("res://Prefab/Entities/Player/player_melee_hit_box.tscn")
#@onready var wand : Marker2D = $Wand

var current_slot # index for a, s, d = 3,4,5
enum Player_direction {RIGHT, LEFT}
var current_player_direction
var is_recharging : bool = false
var attack_cooldown : float = 1
var is_on_cooldown : bool = false
var magic_bullet_casttime : float = 0.1
var magic_bullet_cooldown : float = 0.2
var fireball_casttime : float = 0.8
var fireball_cooldown : float = 0.4
var magic_beam_casttime : float = 1
var magic_beam_cooldown : float = 0.2
var bullet_timer: Timer
var cooldown_timer : Timer

#var wand_position


func player_recharge(delta : float, player: CharacterBody2D):
	if Input.is_action_pressed("recharge"):
		
		if !player.is_recharging:
			
			player.velocity = Vector2.ZERO
			player.current_state = State.RECHARGE
			
			if player.velocity == Vector2.ZERO:
				player.is_recharging = true
				player.velocity.y += GRAVITY * delta
			player.current_state = State.RECHARGE
	elif !Input.is_action_pressed("recharge"):
		if player.is_recharging:
			
			player.is_recharging = false
			player.animated_sprite_2d_2.play("nothing")
			player.animation_trigger = false
			return

func player_hotbar(delta : float, player: CharacterBody2D):
	if Input.is_action_just_pressed("slotA"):
		current_slot = 3
		player.hotbar.select(current_slot)
		print(current_slot)
	if Input.is_action_just_pressed("slotS"):
		current_slot = 4
		player.hotbar.select(current_slot)
		print(current_slot)
	if Input.is_action_just_pressed("slotD"):
		current_slot = 5
		player.hotbar.select(current_slot)
		print(current_slot)

func spawn_melee_hitbox(player: CharacterBody2D):
	var melee_hitbox_instance = melee_hitbox.instantiate() as Node2D
	if player.current_player_direction == player.Player_direction.RIGHT:
		melee_hitbox_instance.current_melee_direction = current_player_direction
		player.wand.position.x = player.wand_position.x + 60 # readjust for melee hitbox
	elif player.current_player_direction == player.Player_direction.LEFT:
		melee_hitbox_instance.current_melee_direction = player.current_player_direction
		player.wand.position.x = -player.wand_position.x + 210
	
	#melee_hitbox_instance.direction = player.current_player_direction
	melee_hitbox_instance.global_position = player.wand.global_position
	player.get_parent().add_child(melee_hitbox_instance)

func player_attack(delta : float, player: CharacterBody2D):
	var direction = player.input_movement() # get current direction of player
	if Input.is_action_just_pressed("melee") and is_on_cooldown == false:
		match player.current_combo_state:
			player.ComboState.NONE, player.ComboState.MELEE_2:
				spawn_melee_hitbox(player)
				player.current_state = State.MELEE_1
				player.current_combo_state = player.ComboState.MELEE_1 # switches to combo
				player._start_combo_timer()
			
			player.ComboState.MELEE_1:
				spawn_melee_hitbox(player)
				player.current_state = State.MELEE_2
				player.current_combo_state = player.ComboState.MELEE_2
				player._start_combo_timer()
		
	if Input.is_action_just_pressed("magic_attack") and current_slot != null and is_on_cooldown == false:
		is_on_cooldown = true
		player.is_attacking = true
		match current_slot:
			3: # Magic Bullet
				#if direction != 0: # this added for running animation when I make one
				player.current_state = State.BULLET
				await player.player_cast_time(current_slot, magic_bullet_casttime)
				var bullet_instance = bullet.instantiate() as Node2D 
				
				print("magic bullet")
				if player.current_player_direction == player.Player_direction.RIGHT:
					bullet_instance.current_bullet_direction = current_player_direction
					player.wand.position.x = player.wand_position.x
				if player.current_player_direction == player.Player_direction.LEFT:
					bullet_instance.current_bullet_direction = player.current_player_direction
					player.wand.position.x = -player.wand_position.x
				
				bullet_instance.direction = direction
				bullet_instance.global_position = player.wand.global_position
				player.get_parent().add_child(bullet_instance)
				await player.spell_cooldown(magic_bullet_cooldown)
				
			4: # Fire Ball
				player.current_state = State.FIREBALL
				await player.player_cast_time(current_slot, fireball_casttime)
				print("fire ball")
				var fireball_instance = fireball.instantiate() as Node2D
				if player.current_player_direction == player.Player_direction.RIGHT:
					fireball_instance.current_bullet_direction = player.current_player_direction
					player.wand.position.x = player.wand_position.x
				if player.current_player_direction == player.Player_direction.LEFT:
					fireball_instance.current_bullet_direction = player.current_player_direction
					player.wand.position.x = -player.wand_position.x
				print("next")
				fireball_instance.direction = direction
				fireball_instance.global_position = player.wand.global_position
				player.get_parent().add_child(fireball_instance)
				print("shot fireball")
				await player.spell_cooldown(fireball_cooldown)
				
			5: # Magic Beam
				if !player.is_on_floor():
					print("beam air")
					player.current_state = State.BEAM_AIR
					await player.player_cast_time(current_slot, magic_beam_casttime)
					
					await player.spell_cooldown(magic_beam_cooldown)
				else:
					print("beam ground")
					player.current_state = State.BEAM
					await player.player_cast_time(current_slot, magic_beam_casttime)
					
					await player.spell_cooldown(magic_beam_cooldown)
		
		is_on_cooldown = false
