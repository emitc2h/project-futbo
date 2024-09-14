class_name ClampedAim3D
extends Node3D


func clamp_aim_angle(angle: float) -> float:
	if angle > 0.0:
		return PI/2
	else:
		return -PI/2


func aim_angle_face_right(aim_vector: Vector2) -> float:
	var raw_angle: float = aim_vector.angle()
	print("raw_angle: ", raw_angle * (180.0/PI))
	if abs(raw_angle) > PI/2:
		return clamp_aim_angle(raw_angle)
	else:
		return raw_angle


func aim_angle_face_left(aim_vector: Vector2) -> float:
	print("aim_angle_face_left")
	var raw_angle: float = aim_vector.angle()
	print("raw_angle: ", raw_angle * (180.0/PI))
	if abs(raw_angle) < PI/2:
		return clamp_aim_angle(raw_angle)
	else:
		return raw_angle


func get_angle(aim_vector: Vector2, direction: Enums.Direction) -> float:
	if direction == Enums.Direction.LEFT:
		if aim_vector.is_zero_approx():
			return Vector2.LEFT.angle()
		else:
			return aim_angle_face_left(aim_vector)
	else:
		if aim_vector.is_zero_approx():
			return Vector2.RIGHT.angle()
		else:
			return aim_angle_face_right(aim_vector)


func get_vector(aim_vector: Vector2, direction: Enums.Direction) -> Vector2:
	return Vector2.from_angle(get_angle(aim_vector, direction))
