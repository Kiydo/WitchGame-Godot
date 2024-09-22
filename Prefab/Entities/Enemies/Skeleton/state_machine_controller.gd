extends Node

@export var node_state_machine : NodeStateMachine


func _on_attack_area_2d_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		node_state_machine.transition_to("attack")


func _on_attack_area_2d_body_exited(body: Node2D):
	if body.is_in_group("Player"):
		node_state_machine.transition_to("walk")


func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		node_state_machine.transition_to("walk")


func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		node_state_machine.transition_to("idle")
		




#extends Node
#var in_range : bool = false
#var is_attacking : bool = false
#var attack_time : float = 1.2
#var attack_timer : Timer
#var remaining_time : float
#
#@export var node_state_machine : NodeStateMachine
#
#func _ready():
	#attack_timer = Timer.new()
	#attack_timer.one_shot = true
	#attack_timer.wait_time = attack_time
	#attack_timer.connect("timeout", Callable(self, "_on_attack_complete"))
	#add_child(attack_timer)
#
#func _on_attack_area_2d_body_entered(body: Node2D):
	#if body.is_in_group("Player") and not is_attacking:
		#print("Starting attack")
		#is_attacking = true
		#node_state_machine.transition_to("attack")
		#attack_timer.start()
#
#
#func _on_attack_area_2d_body_exited(body: Node2D):
	#if body.is_in_group("Player") and not is_attacking:
		#node_state_machine.transition_to("walk")
#
#
#func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	#in_range = true
	#if body.is_in_group("Player") and not is_attacking:
		#node_state_machine.transition_to("walk")
#
#
#func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	#in_range = false
	#if body.is_in_group("Player") and not is_attacking:
		#node_state_machine.transition_to("idle")
		#
#func _on_attack_complete():
	#print("Attack complete")
	#is_attacking = false  # Reset the attack flag to allow new attacks
	## Here you can check conditions to decide the next state
	#if in_range:
		#node_state_machine.transition_to("walk")
	#else:
		#node_state_machine.transition_to("idle")
