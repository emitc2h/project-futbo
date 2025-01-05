class_name CameraController
extends Node3D

@export var subject: Node3D

@onready var camera: Camera3D = $Camera3D

var camera_default_rotation: Vector3
var camera_initial_position: Vector3

signal camera_changed(rotation: Vector3, position_delta: Vector3, fov: float)

func _ready() -> void:
	global_position = subject.global_position
	
	camera_default_rotation = camera.rotation
	camera_initial_position = camera.global_position


func _process(delta: float) -> void:
	global_position.x = lerp(global_position.x, subject.global_position.x, 4.8 * delta)
	global_position.y = lerp(global_position.y, subject.global_position.y, 6.0 * delta)
		
	camera_changed.emit(camera.rotation, camera.global_position - camera_initial_position, camera.fov)
	

func interpolate_between(x: float, start_x: float, stop_x: float, start_param: float, stop_param: float) -> float:
	return stop_param - ((x - stop_x) / (start_x - stop_x)) * (stop_param - start_param)
