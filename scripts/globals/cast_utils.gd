extends Node

const BALL_DRIBBLED_NODE_NAME = "CharNode"
const BALL_INERT_NODE_NAME = "RigidNode"

func hits_ball(ray_cast: RayCast3D) -> bool:
	if ray_cast.is_colliding():
		match ray_cast.get_collider().name:
			BALL_DRIBBLED_NODE_NAME:
				return true
			BALL_INERT_NODE_NAME:
				return true
			_:
				return false
	else:
		return false


# Assumes the collision mask is set to detect the ball only
func get_ball(ray_cast: RayCast3D) -> Ball:
	if ray_cast.is_colliding():
		var colliding_object: Node3D = ray_cast.get_collider() as Node3D
		return colliding_object.get_parent() as Ball
	else:
		return null
