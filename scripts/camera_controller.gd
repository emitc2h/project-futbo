extends Node3D

@export var subject: Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = subject.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x = lerp(global_position.x, subject.global_position.x, 0.08)
	global_position.y = lerp(global_position.y, subject.global_position.y, 0.1)
