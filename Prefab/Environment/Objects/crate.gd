extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum CRATE_STATE {IDLE, HIT1, HIT2, HIT3, DEAD}
var death_flag : bool = false
var hit_counter : int = 0
var animation_trigger : bool = false
#var current_hits : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	death()
	
func death():
	if animation_trigger == false and death_flag == true:
		print("DEAD")
		queue_free()

func crate_health():
	match hit_counter:
		1:
			print("hit1")
			animated_sprite_2d.play("hit1")
		2:
			print("hit2")
			animated_sprite_2d.play("hit2")
		3:
			print("hit4")
			animated_sprite_2d.play("hit3")
		4:
			animation_trigger = true
			print("broke crate")
			animated_sprite_2d.play("dead")
			death_flag = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	print("crate entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		hit_counter += 1
		print(hit_counter)
		crate_health()
		
	elif area.has_method("get_damage_amount"):
		hit_counter += 1
		print(hit_counter)
		crate_health()
		
func _on_animation_finished():
	animation_trigger = false
