class_name DroneShield
extends StaticBody3D

@onready var drone_shield_closed_model: DroneClosedShieldModel = $DroneClosedShieldModel
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _enabled: bool = true
var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		collision_shape.disabled = !value
		

func hit() -> void:
	Signals.debug_log.emit("hitting the shield")
	drone_shield_closed_model.hit()
	
