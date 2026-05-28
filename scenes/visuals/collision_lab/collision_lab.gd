extends Node3D

@onready var char_ball: CharacterBody3D = $CharacterBall
@onready var char_ball_arrow: Node3D = $MomentumArrowChar

@onready var rigid_ball_left: RigidBody3D = $RigidBallLeft
@onready var rigid_ball_left_arrow: Node3D = $MomentumArrowRigidLeft

@onready var rigid_ball_right: RigidBody3D = $RigidBallRight
@onready var rigid_ball_right_arrow: Node3D = $MomentumArrowRigidRight

@onready var camera: Camera3D = $Camera3D

@export var max_speed: float = 4.0

var _camera_front_view: Transform3D
var _camera_top_view: Transform3D = Transform3D(Basis(Vector3.LEFT, PI/2), Vector3(0.0, 10.0, 0.0))
var _is_camera_front_view: bool = true

func _ready() -> void:
	_camera_front_view = camera.transform


func _physics_process(_delta: float) -> void:
	
	## Handle camera view switch
	if Input.is_action_just_pressed("debug"):
		if _is_camera_front_view:
			camera.transform = _camera_top_view
			_is_camera_front_view = false
		else:
			camera.transform = _camera_front_view
	
	## Orient arrows According to the momentum of the objects they represent
	apply_momentum_to_arrow(rigid_ball_left.global_position, rigid_ball_left.linear_velocity, rigid_ball_left_arrow)
	apply_momentum_to_arrow(rigid_ball_right.global_position, rigid_ball_right.linear_velocity, rigid_ball_right_arrow)
	apply_momentum_to_arrow(char_ball.global_position, char_ball.get_real_velocity(), char_ball_arrow)


func apply_momentum_to_arrow(global_pos: Vector3, velocity: Vector3, arrow: Node3D) -> void:
	arrow.set_identity()
	arrow.global_position = global_pos
	var cross_product: Vector3 = arrow.basis.y.cross(velocity).normalized()
	var angle: float = velocity.angle_to(arrow.basis.y)
	var speed: float = velocity.length()
	
	if not cross_product == Vector3.ZERO:
		arrow.rotate(cross_product, angle)
	## Cross product of opposite vectors cancel out, so just rotate 180 degrees
	else:
		arrow.rotate(arrow.basis.x, PI)
	
	arrow.scale = Vector3.ONE * min(1.0, sqrt(speed / max_speed))
