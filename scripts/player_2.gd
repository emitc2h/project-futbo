class_name Player2
extends CharacterBody2D

# Nodes controlled by this node
@export var sprite: AnimatedSprite2D

# Dynamic properties
var can_run_backward: bool = false

signal facing_left()
signal facing_right()


func _on_facing_left() -> void:
	facing_left.emit()


func _on_facing_right() -> void:
	facing_right.emit()
