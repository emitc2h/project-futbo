extends Node

# Project a 2D Vector into the 3D xy plane
func vec3_from(vector2: Vector2) -> Vector3:
	return Vector3(vector2.x, vector2.y, 0)


# Flip the y-axis, producing a vector2 meant to live  in the
# xy-plane of a 3D space
func vec2_from(vector2: Vector2) -> Vector2:
	return Vector2(vector2.x, -vector2.y)


func vec2_from_vec3(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, -vector3.y)
	
