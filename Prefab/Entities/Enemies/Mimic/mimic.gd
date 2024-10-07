extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var player : CharacterBody2D

func _ready() -> void:
	animated_sprite_2d.connect("animation_finished", Callable(self, "_on_animation_finished"))
	player = get_tree().get_nodes_in_group("Player")[0] as CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func on_physics_process(delta : float):
	#var direction
	#if global_position > player.global_position:
		#animated_sprite_2d.flip_h = true
		#direction = -1

func mimic_attack():
	var direction
	if self.global_position > player.global_position:
		animated_sprite_2d.flip_h = true
		direction = -1
	print("mimic attacking")
	animated_sprite_2d.play("attack")

func _on_hitbox_area_entered(area: Area2D) -> void:
	#print("crate entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		mimic_attack()
		
	elif area.has_method("get_damage_amount"):
		mimic_attack()
