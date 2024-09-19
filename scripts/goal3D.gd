class_name Goal3D
extends Node3D

signal scored
signal reset

func _on_goal_area_body_entered(body: Node3D) -> void:
	scored.emit()


func _on_goal_area_body_exited(body: Node3D) -> void:
	reset.emit()
