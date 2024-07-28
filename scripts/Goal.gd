class_name Goal
extends Node2D

signal scored
signal reset

func _on_goal_area_body_entered(body: RigidBody2D) -> void:
	scored.emit()


func _on_goal_area_body_exited(body: RigidBody2D) -> void:
	reset.emit()
