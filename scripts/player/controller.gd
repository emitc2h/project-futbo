class_name Controller
extends Node3D

@export var player: Player

# Disable controls for cut scenes
var _enabled: bool = true
@export var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		for controller in get_children():
			controller.set_physics_process(value)
