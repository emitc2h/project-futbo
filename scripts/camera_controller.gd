class_name CameraController
extends Node3D

@export var subject: Node3D

@onready var sc: StateChart = $StateChart
@onready var _camera_pos: Node3D = $TargetPosition
@onready var _camera_yaw: Node3D = $TargetPosition/CameraYaw
@onready var _camera_pitch: Node3D = $TargetPosition/CameraYaw/CameraPitch
@onready var _camera: Camera3D = $TargetPosition/CameraYaw/CameraPitch/Camera3D


@export_group("Behavior")
@export var sync_to_subject_on_ready: bool = true


# Disable controls for cut scenes
@export_group("Controls the Camera")
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
		return _camera_pos.global_position
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not state == State.TRACKING:
			_camera_pos.global_position = value

@export_range(-90, 90, 0.1, "radians_as_degrees") var camera_yaw_angle: float:
	get:
		return _camera_yaw.rotation.z
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not state == State.TRACKING:
			_camera_yaw.rotation.z = value

@export_range(-90, 90, 0.1, "radians_as_degrees") var camera_pitch_angle: float:
	get:
		return _camera_pitch.rotation.x
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not state == State.TRACKING:
			_camera_pitch.rotation.x = value

@export var camera_fov: float:
	get:
		return _camera.fov
	set(value):
		# Can't set values if the camera is being controlled by the Controller
		if not state == State.TRACKING:
			_camera.fov = value

# Zoom controls
@export_group("Zoom Settings")
@export var zoom_min: float = 5.0
@export var zoom_max: float = 15.0
@export var default_zoom: float = 8.0
@export var lerp_zoom: float = 0.5
@export var zoom: float:
	get:
		return _camera_pos.position.z
	set(value):
		_camera_pos.position.z = value

@export var zoom_target: float = 10.0

# Fly mode parameters
@export_group("Fly Mode")
@export var movement_speed: float = 5.0
@export var look_sensitivity: float = 1.0

## States Enum
enum State {TRACKING = 0, ANIMATED = 1, FLY = 2}
var state: State = State.TRACKING

## State transition constants
const TRANS_TO_TRACKING: String = "to tracking"
const TRANS_TO_ANIMATED: String = "to animated"
const TRANS_TO_FLY: String = "to fly"

var camera_initial_position: Vector3


func _ready() -> void:
	Signals.update_zoom.connect(_change_zoom)
	Signals.debug_on.connect(_on_debug_on)
	Signals.debug_off.connect(_on_debug_off)
	
	if sync_to_subject_on_ready:
		global_position = subject.global_position
	camera_initial_position = _camera_pos.global_position


func _process(delta: float) -> void:
	## Always sync the skybox
	Signals.camera_changed.emit(_camera.global_rotation, _camera.global_position - camera_initial_position, _camera.fov)


# tracking state
#----------------------------------------
func _on_tracking_state_processing(delta: float) -> void:
	_camera_pos.global_position.x = lerp(_camera_pos.global_position.x, subject.global_position.x, lerp_x * delta)
	_camera_pos.global_position.y = lerp(_camera_pos.global_position.y, subject.global_position.y, lerp_y * delta)
	if _z_tracking_enabled:
		_camera_pos.global_position.z = lerp(_camera_pos.global_position.z, subject.global_position.z, lerp_z * delta)

	zoom = lerp(zoom, zoom_target, lerp_zoom * delta)


# fly state
#----------------------------------------
var _pos_node_transform: Transform3D
var _yaw_node_transform: Transform3D
var _pitch_node_transform: Transform3D

func _on_fly_state_entered() -> void:
	## If we go to fly mode, cache the transforms so they can be recovered when leaving fly mode
	_pos_node_transform = _camera_pos.transform
	_yaw_node_transform = _camera_yaw.transform
	_pitch_node_transform = _camera_pitch.transform


func _on_fly_state_processing(delta: float) -> void:
	var yaw_axis: float = Input.get_axis("aim_left", "aim_right")
	_camera_yaw.rotation.y -= yaw_axis * delta * look_sensitivity
	
	var pitch_axis: float = Input.get_axis("aim_up", "aim_down")
	if _camera_pitch.rotation.x > PI/2:
		_camera_pitch.rotation.x = PI/2
	elif _camera_pitch.rotation.x < -PI/2:
		_camera_pitch.rotation.x = -PI/2
	else:
		_camera_pitch.rotation.x -= pitch_axis * delta * look_sensitivity
	
	var movement_vector: Vector2 = Input.get_vector("move_down", "move_up", "move_left", "move_right", 0.2)
	var movement_direction: Vector3 = _camera_yaw.basis.x * movement_vector.y -\
		 _camera_yaw.basis.z.rotated(_camera_yaw.basis.x, _camera_pitch.rotation.x) * movement_vector.x
	_camera_yaw.position += movement_direction * delta * movement_speed

func _on_fly_state_exited() -> void:
	## Recover the cached transforms
	_camera_pos.transform = _pos_node_transform
	_camera_yaw.transform = _yaw_node_transform
	_camera_pitch.transform = _pitch_node_transform


# signal handling
#----------------------------------------
func _change_zoom(target: Enums.Zoom) -> void:
	zoom_target = Constants.ZOOM_VALUES[target]


func _on_debug_on() -> void:
	sc.send_event(TRANS_TO_FLY)


func _on_debug_off() -> void:
	sc.send_event(TRANS_TO_TRACKING)
