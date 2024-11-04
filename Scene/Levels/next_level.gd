extends Area2D
@export var character_body_2d : CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_body_2d = get_parent().get_node("Player")
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_area_entered(area: Area2D) -> void:
	print("touched next level")
	if character_body_2d.is_in_group("Player"):
		print("going to next level")
		var current_scene_file = get_tree().current_scene.scene_file_path
		print("current level path: ", current_scene_file)
		var next_level_number = current_scene_file.to_int() + 1
		
		var next_level_path = "res://Scene/Levels/level" + str(next_level_number) + ".tscn"
		call_deferred("change_scene", next_level_path) # call defered used to delay scene change untill after the physics is okay with it

func change_scene(next_level_path: String) -> void:
	get_tree().change_scene_to_file(next_level_path)
