extends ShapeCast3D

@export var drone: Drone

var player_detected: bool
var control_node_detected: bool

func scan(scan_for_control_node: bool = true, scan_for_player: bool = true) -> void:
	self.force_shapecast_update()
	if self.is_colliding():
		for i in range(self.get_collision_count()):
			var collider: Object = self.get_collider(i)
			
			## Scan for the control node entering the shapecast
			if scan_for_control_node and collider.get_parent() is ControlNode:
				if not control_node_detected:
					drone.control_node_proximity_triggered.emit()
					control_node_detected = true
			else:
				control_node_detected = false
			
			## Scan for the player entering the shapecast
			if scan_for_player and collider is Player3D:
				if not player_detected:
					drone.target = collider
					drone.player_proximity_triggered.emit()
					player_detected = true
			else:
				player_detected = false
