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
