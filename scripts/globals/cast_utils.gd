extends Node

const BALL_DRIBBLED_NODE_NAME = "CharNode"
const BALL_INERT_NODE_NAME = "RigidNode"

func hits_ball(ray_cast: RayCast3D) -> bool:
	if ray_cast.is_colliding():
		print("raycast is colliding with something")
		match ray_cast.get_collider().name:
			BALL_DRIBBLED_NODE_NAME:
				print("CharNode detected")
				return true
			BALL_INERT_NODE_NAME:
				print("RigidNode detected")
				return true
			_:
				print("SomethingElse detected")
				return false
	else:
		print("raycast doesn't detect anything")
		return false


# Assumes the collision mask is set to detect the ball only
func get_ball(ray_cast: RayCast3D) -> Ball:
	if ray_cast.is_colliding():
		var colliding_object: Node3D = ray_cast.get_collider() as Node3D
		return colliding_object.get_parent() as Ball
	else:
		return null
