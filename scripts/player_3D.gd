class_name Player3D
extends CharacterBody3D

# Nodes controlled by this node
@export var sprite: AnimatedSprite3D

# Dynamic properties
var can_run_backward: bool = false

# signals
signal facing_left()
signal facing_right()


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# Signal transmission from abilities
func _on_facing_left() -> void:
	facing_left.emit()


func _on_facing_right() -> void:
	facing_right.emit()
