class_name CameraController
extends Node3D

@export var subject: Node3D
@export var stop_zooming_x: float = -40.0
@export var start_zooming_x: float = -60.0
@export var zoom_factor: float = 2.0

@onready var camera: Camera3D = $Camera3D

var near_camera_z: float
var near_camera_y: float
var far_camera_z: float
var far_camera_y: float
var camera_default_rotation: Vector3


func _ready() -> void:
	global_position = subject.global_position
	near_camera_y = camera.global_position.y
	near_camera_z = camera.global_position.z
	
	far_camera_y = near_camera_y * zoom_factor
	far_camera_z = near_camera_z * zoom_factor
	
	camera_default_rotation = camera.rotation
	
	camera.global_position.y = far_camera_y
	camera.global_position.z = far_camera_z


func _process(delta: float) -> void:
	global_position.x = lerp(global_position.x, subject.global_position.x, 4.8 * delta)
	global_position.y = lerp(global_position.y, subject.global_position.y, 6.0 * delta)
	
	if subject.global_position.x > stop_zooming_x:
		camera.global_position.y = lerp(camera.global_position.y, near_camera_y, 1.0 * delta)
		camera.global_position.z = lerp(camera.global_position.z, near_camera_z, 1.0 * delta)
		camera.rotation = lerp(camera.rotation, camera_default_rotation, 1.0 * delta)
		
	elif subject.global_position.x < start_zooming_x:
		camera.global_position.y = lerp(camera.global_position.y, far_camera_y, 4.8 * delta)
		camera.global_position.z = lerp(camera.global_position.z, far_camera_z, 4.8 * delta)
		camera.rotation = lerp(camera.rotation, camera_default_rotation, 4.8 * delta)
		
	else:
		camera.global_position.y = lerp(camera.global_position.y, interpolate_between(subject.global_position.x, start_zooming_x, stop_zooming_x, far_camera_y, near_camera_y), delta)
		camera.global_position.z = lerp(camera.global_position.z, interpolate_between(subject.global_position.x, start_zooming_x, stop_zooming_x, far_camera_z, near_camera_z), delta)
		camera.look_at(subject.global_position)
	

func interpolate_between(x: float, start_x: float, stop_x: float, start_param: float, stop_param: float) -> float:
	return stop_param - ((x - stop_x) / (start_x - stop_x)) * (stop_param - start_param)
