extends Area2D

@export var MELEEDAMAGE = 10
var direction : int
enum Melee_direction {LEFT, RIGHT}

var current_melee_direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if current_melee_direction == Melee_direction.LEFT:
		move_local_x(-1 * delta)
	elif current_melee_direction == Melee_direction.RIGHT:
		move_local_x(1 * delta)

func get_damage_amount():
	return MELEEDAMAGE


func _on_body_entered(body: Node2D) -> void:
	print("enemy melee hit player")


func _on_area_entered(area: Area2D) -> void:
	print("enemy melee hit wall")


func _on_timer_timeout() -> void:
	queue_free()
