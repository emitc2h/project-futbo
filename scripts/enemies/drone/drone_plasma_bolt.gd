class_name DronePlasmaBolt
extends Node3D

## Inject Skeleton3D Dependency
@export var skeletonModifier: SkeletonModifier3D
@export var parent_bone_name: String
@export var bolt_speed: float = 60.0
@export var bolt_size: float = 0.0
@export var hit_enabled: bool = false
@export var hit_force: float = 17.0

@onready var bolt_model: Node3D = $DronePlasmaBoltModel
@onready var bolt_mesh: MeshInstance3D = $DronePlasmaBoltModel/bolt
@onready var impact_mesh: MeshInstance3D = $DronePlasmaBoltModel/impact
@onready var sc: StateChart = $StateChart
@onready var raycast: RayCast3D = $RayCast3D
@onready var impact_animation: DronePlasmaBoltImpactAnimation = $ImpactAnimation
@onready var shrapnel_particles: GPUParticles3D = $ShrapnelParticles3D

var bone_idx: int
var travel_distance: float
var trans_after_fire: String
var hit_player: bool = false
var recorded_collision_point: Vector3
var recorded_bolt_global_pos: Vector3
var recorded_impact_global_pos: Vector3
var impulse_vector: Vector3

const TRANS_TO_FIRE: String = "to fire"
const TRANS_TO_HIT_PLAYER: String = "to hit player"
const TRANS_TO_HIT_CONTROL_NODE: String = "to hit control node"
const TRANS_TO_MISS: String = "to miss"
const TRANS_TO_OFF: String = "to off"

signal did_hit

func _ready() -> void:
	bone_idx = skeletonModifier.get_skeleton().find_bone(parent_bone_name)


# off state
# -----------------------------------------
func _on_off_state_entered() -> void:
	## Reset bolt mesh
	bolt_mesh.visible = false
	


func _on_off_state_physics_processing(_delta: float) -> void:
	if recorded_bolt_global_pos:
		bolt_mesh.global_position = recorded_bolt_global_pos
	if recorded_impact_global_pos:
		impact_mesh.global_position = recorded_impact_global_pos


# fire state
# -----------------------------------------
func _on_fire_state_entered() -> void:
	## Show the bolt
	bolt_mesh.visible = true
	bolt_mesh.position = Vector3.ZERO
	impact_mesh.position = Vector3.ZERO


func _on_fire_state_physics_processing(delta: float) -> void:
	## Apply the look at modifier and retrieve the em spinner bone pose
	await skeletonModifier.modification_processed
	self.transform = skeletonModifier.get_skeleton().get_bone_global_pose(bone_idx)
	
	## Update the bolt destination information
	if raycast.is_colliding():
		recorded_collision_point = raycast.get_collision_point()
		travel_distance = recorded_collision_point.distance_to(self.global_position) - bolt_size
		impact_mesh.position.y = travel_distance
		shrapnel_particles.position.y = travel_distance
	else:
		travel_distance = raycast.target_position.y
	
	## Calculate how much further the bolt will travel this frame
	var updated_distance: float = bolt_mesh.position.y + bolt_speed * delta
	
	## If the bolt has made it the whole way then consider if it's a hit
	if updated_distance > travel_distance:
		var collider: Node3D = raycast.get_collider() as Node3D
		
		## Figure out an impulse vector from the direction of the bolt in global space
		impulse_vector = (bolt_mesh.global_position - global_position).normalized()
		impulse_vector = Vector3(impulse_vector.x, impulse_vector.y, 0.0)
		
		bolt_mesh.position.y = travel_distance
		recorded_bolt_global_pos = bolt_mesh.global_position
		recorded_impact_global_pos = impact_mesh.global_position
		
		if collider:
			if (collider.is_in_group("PlayerGroup")) or (collider is TargetMesh):
				sc.send_event(TRANS_TO_HIT_PLAYER)
			elif collider.is_in_group("ControlNodeGroup") or collider.is_in_group("ControlNodeShieldGroup"):
				sc.send_event(TRANS_TO_HIT_CONTROL_NODE)
			else:
				sc.send_event(TRANS_TO_MISS)
	else:
		bolt_mesh.position.y = updated_distance


# hit player state
# -----------------------------------------
func _on_hit_player_state_entered() -> void:
	if hit_enabled:
		Signals.player_takes_damage.emit(Vector3.ZERO, recorded_collision_point, false)
		did_hit.emit()
	shrapnel_particles.restart()
	shrapnel_particles.emitting = true
	await impact_animation.hit()
	sc.send_event(TRANS_TO_OFF)


# hit control node state
# -----------------------------------------
func _on_hit_control_node_state_entered() -> void:
	if hit_enabled:
		Signals.control_node_shield_hit.emit(false)
		Signals.control_node_impulse.emit(hit_force * impulse_vector)
		did_hit.emit()
	shrapnel_particles.restart()
	shrapnel_particles.emitting = true
	await impact_animation.hit()
	sc.send_event(TRANS_TO_OFF)


# hit state
# -----------------------------------------
func _on_hit_state_physics_processing(_delta: float) -> void:
	if recorded_bolt_global_pos:
		bolt_mesh.global_position = recorded_bolt_global_pos
	if recorded_impact_global_pos:
		impact_mesh.global_position = recorded_impact_global_pos


# miss state
# -----------------------------------------
func _on_miss_state_entered() -> void:
	shrapnel_particles.restart()
	shrapnel_particles.emitting = true
	sc.send_event(TRANS_TO_OFF)


func fire() -> void:
	sc.send_event(TRANS_TO_FIRE)
