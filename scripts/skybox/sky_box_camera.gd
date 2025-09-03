class_name SkyBoxCamera
extends Camera3D

var initial_position: Vector3
var parallax_factor: float

func _ready() -> void:
	self.initial_position = self.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_camera_changed(rotation: Vector3, position_delta: Vector3, fov: float) -> void:
	self.rotation = rotation
	self.global_position = initial_position + parallax_factor * position_delta
	self.fov = fov
	
