@tool
class_name PlayerController
extends Node

@onready var character: CharacterBase = self.get_parent()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not get_parent() is CharacterBase:
		warnings.append("Parent node should be a BasePlayer")
	return warnings


func _physics_process(_delta: float) -> void:
	var left_right_axis: float = Input.get_axis("move_left", "move_right")
	if abs(left_right_axis) > 0.0:
		character.move(left_right_axis)
	else:
		character.idle()
