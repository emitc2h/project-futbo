extends Node3D

@onready var char_ball: CharacterBody3D = $CharacterBall
@onready var char_ball_arrow: Node3D = $MomentumArrowChar

@onready var rigid_ball_left: RigidBody3D = $RigidBallLeft
@onready var rigid_ball_left_arrow: Node3D = $MomentumArrowRigidLeft

@onready var rigid_ball_right: RigidBody3D = $RigidBallRight
@onready var rigid_ball_right_arrow: Node3D = $MomentumArrowRigidRight

@export var max_speed: float = 3.0

func _physics_process(_delta: float) -> void:
	apply_momentum_to_arrow(rigid_ball_left.global_position, rigid_ball_left.linear_velocity, rigid_ball_left_arrow)
	apply_momentum_to_arrow(rigid_ball_right.global_position, rigid_ball_right.linear_velocity, rigid_ball_right_arrow)
	apply_momentum_to_arrow(char_ball.global_position, char_ball.velocity, char_ball_arrow)


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
	
	arrow.scale = Vector3.ONE * min(1.1, speed / max_speed)
