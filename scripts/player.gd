class_name Player
extends CharacterBody2D

# Nodes controlled by this node
@export var sprite: AnimatedSprite2D

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
