class_name FieldOfView
extends Node3D

var target: Node3D

var sees_player: bool:
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
