class_name DroneFieldOfView
extends Node3D

var target: Node3D

var sees_target: bool:
	get:
		for child in self.get_children():
			if child is RayCast3D and child.is_colliding():
				target = child.get_collider()
				return true
		target = null
		return false


var range: float:
	get:
		return self.get_children()[0].target_position.z
	set(value):
		for child in self.get_children():
			if child is RayCast3D:
				child.target_position.z = value


var angles: Array[float]
var _focus: float = 1.0
var focus: float:
	get:
		return _focus
	set(value):
		_focus = value
		for i in range(self.get_child_count()):
			var child: Node3D = self.get_children()[i]
			if child is RayCast3D:
				child.rotation_degrees.x = angles[i] / _focus


var enabled: bool:
	get:
		var result: bool = false
		for child in self.get_children():
			if child is RayCast3D:
				if child.enabled:
					result = true
		return result
	set(value):
		for child in self.get_children():
			if child is RayCast3D:
				child.enabled = value


func _ready() -> void:
	for child in self.get_children():
		if child is RayCast3D:
			angles.append(child.rotation_degrees.x)
