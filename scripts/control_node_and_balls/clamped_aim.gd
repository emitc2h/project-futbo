class_name ClampedAim
extends Node3D

## Angle conventions when doing vector2.angle()
## - Lower quadrants are negative
## - Upper quadrants are positive
## - Right-facing quadrants are abs(angle) < PI/2
## - Left-facing quadrants are abs(angle) > PI/2
## - UP direction is PI/2
## - DOWN direction is -PI/2
## - LEFT direction is 1.0 and/or -1.0
## - RIGHT direction is 0.0

func clamp_aim_angle_to_direction_faced(angle: float) -> float:
	if angle > 0.0:
		return PI/2
	else:
		return -PI/2


func clamp_aim_angle_above_ground(angle: float, direction: Enums.Direction, ground_normal: float = PI/2) -> float:
	if angle < 0.0:
		if direction == Enums.Direction.LEFT:
			return Vector2.LEFT.angle()
		else:
			return Vector2.RIGHT.angle()
	return angle


func aim_angle_face_right(aim_vector: Vector2) -> float:
	var raw_angle: float = aim_vector.angle()
	if abs(raw_angle) > PI/2:
		return clamp_aim_angle_to_direction_faced(raw_angle)
	else:
		return raw_angle


func aim_angle_face_left(aim_vector: Vector2) -> float:
	var raw_angle: float = aim_vector.angle()
	if abs(raw_angle) < PI/2:
		return clamp_aim_angle_to_direction_faced(raw_angle)
	else:
		return raw_angle


func get_angle(aim_vector: Vector2, direction: Enums.Direction) -> float:
	if direction == Enums.Direction.LEFT:
		if aim_vector.is_zero_approx():
			return Vector2.LEFT.angle()
		else:
			return clamp_aim_angle_above_ground(aim_angle_face_left(aim_vector), direction)
	else:
		if aim_vector.is_zero_approx():
			return Vector2.RIGHT.angle()
		else:
			return clamp_aim_angle_above_ground(aim_angle_face_right(aim_vector), direction)


func get_vector(aim_vector: Vector2, direction: Enums.Direction) -> Vector3:
	return Converters.vec3_from(Vector2.from_angle(get_angle(aim_vector, direction)))
