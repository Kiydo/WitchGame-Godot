extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var animation_trigger = false
var open_flag : bool = false

func _ready() -> void:
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation_trigger == false and open_flag == true:
		animated_sprite_2d.play("opened")
	
func chest_open():
	animation_trigger = true
	animated_sprite_2d.play("open")

func _on_animation_finished():
	animation_trigger = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if open_flag == false:
		#print("crate entered")
		if area.get_parent().has_method("get_damage_amount"):
			var node = area.get_parent() as Node
			open_flag = true
			#print(hit_counter)
			chest_open()
			
		elif area.has_method("get_damage_amount"):
			open_flag = true
			#print(hit_counter)
			chest_open()
