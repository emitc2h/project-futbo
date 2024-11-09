class_name CameraController
extends Node3D

@export var subject: Node3D

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	global_position = subject.global_position


func _process(delta: float) -> void:
	global_position.x = lerp(global_position.x, subject.global_position.x, 0.08)
	global_position.y = lerp(global_position.y, subject.global_position.y, 0.1)
