class_name Head
extends Node3D

@onready var ray_cast_left: RayCast3D = $RayCastLeft
@onready var ray_cast_right: RayCast3D = $RayCastRight


func scan_for_ball() -> Ball3D:
	ray_cast_left.force_raycast_update()
	var ball_left: Ball3D = CastUtils.get_ball(ray_cast_left)
	if ball_left:
		return ball_left
	else:
		ray_cast_right.force_raycast_update()
		return CastUtils.get_ball(ray_cast_right)
