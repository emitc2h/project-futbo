class_name CameraController
extends Node3D

@export var subject: Node3D

@onready var camera: Camera3D = $Camera3D

@export_group("Behavior")
@export var sync_to_subject_on_ready: bool = true


# Disable controls for cut scenes
@export_group("Controls the Camera")
var _enabled: bool = true
@export var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value

var _z_tracking_enabled: bool = true
@export var z_tracking_enabled: bool:
	get:
		return _z_tracking_enabled
	set(value):
		_z_tracking_enabled = value


@export_group("Lerp Factors")
@export var lerp_x: float = 4.8
@export var lerp_y: float = 6.0
@export var lerp_z: float = 2.0


# Animation handles
@export_group("Animation Handles")
@export var camera_position: Vector3:
	get:
		return camera.global_position
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not _enabled:
			camera.global_position = value

@export var camera_rotation: Vector3:
	get:
		return camera.rotation
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not _enabled:
			camera.rotation = value

@export var camera_fov: float:
	get:
		return camera.fov
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not _enabled:
			camera.fov = value

var camera_initial_position: Vector3

signal camera_changed(rotation: Vector3, position_delta: Vector3, fov: float)

func _ready() -> void:
	if sync_to_subject_on_ready:
		global_position = subject.global_position
	camera_initial_position = camera.global_position


func _process(delta: float) -> void:
	## Only follow the subject if enabled
	if _enabled:
		global_position.x = lerp(global_position.x, subject.global_position.x, lerp_x * delta)
		global_position.y = lerp(global_position.y, subject.global_position.y, lerp_y * delta)
		if _z_tracking_enabled:
			global_position.z = lerp(global_position.z, subject.global_position.z, lerp_z * delta)
	
	## Always sync the skybox
	camera_changed.emit(camera.rotation, camera.global_position - camera_initial_position, camera.fov)
