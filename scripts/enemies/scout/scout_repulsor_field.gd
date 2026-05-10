class_name ScoutRepulsorField
extends Node3D

@export_group("Dependencies")
@export var scout: Scout

@export_group("Parameters")
@export var inner_radius: float = 0.19
@export var outer_radius: float = 1.0
@export var max_force: float = 150.0
@export var force_dampening: float = 6.0
@export var min_scout_collision_reporting_force: float = 10.0

## Internal parameters
var _raycasts: Array[RayCast3D]
var _scout_collision_reported: bool = false

## Signals
signal colliding_with_other_scout

func _ready() -> void:
	for child in get_children():
		if child is RayCast3D:
			## Register the raycast in the array
			_raycasts.append(child)
			
			## Adjust the target position to match the outer radius
			child.target_position.y = -outer_radius
			
			## First inherit the char_node's collision mask
			child.collision_mask = scout.movement_states.char_node.collision_mask


# utilities
#========================================
func sync_collision_mask_to(node: CollisionObject3D) -> void:
	for raycast in _raycasts:
		raycast.collision_mask = node.collision_mask


func get_repulsion_force() -> Vector3:
	var cumulative_force_vector: Vector3 = Vector3.ZERO
	_scout_collision_reported = false
	
	for raycast in _raycasts:
		raycast.force_update_transform()
		raycast.force_raycast_update()
		
		if not raycast.is_colliding():
			continue
		
		var collider: Node3D = raycast.get_collider() as Node3D
		if collider.is_in_group("ScoutPhysicsGroup"):
			if not _scout_collision_reported:
				_scout_collision_reported = true
		
		var space_vector: Vector3 = raycast.get_collision_point() - self.global_position
		var space_vector_length: float = space_vector.length() - inner_radius
		
		## Add some perpendicular force when encountering the player
		if collider.is_in_group("PlayerGroup"):
			space_vector = space_vector.rotated(Vector3.UP, (outer_radius - space_vector_length) / outer_radius)
		
		## Force should be maximal when space_vector_length
		var force_magnitude: float = -max_force * exp(-force_dampening * space_vector_length)
		
		cumulative_force_vector += force_magnitude * space_vector.normalized()
		
	if _scout_collision_reported and cumulative_force_vector.length() > min_scout_collision_reporting_force:
		colliding_with_other_scout.emit()
	
	return cumulative_force_vector
