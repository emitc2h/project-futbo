class_name Controller3D
extends Node3D

@export var player: Player3D

# Disable controls for cut scenes
var _enabled: bool = true
@export var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		for controller in get_children():
			controller.set_physics_process(value)
