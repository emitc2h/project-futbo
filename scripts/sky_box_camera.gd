class_name SkyBoxCamera
extends Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_camera_rotated(rotation: Vector3) -> void:
	self.rotation = rotation
