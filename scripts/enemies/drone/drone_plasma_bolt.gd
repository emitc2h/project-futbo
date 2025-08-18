class_name DronePlasmaBolt
extends Node3D

## Inject Skeleton3D Dependency
@export var skeletonModifier: SkeletonModifier3D
@export var parent_bone_name: String
@export var bolt_speed: float = 60.0
@export var bolt_size: float = 0.0

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
var player: Player

const TRANS_TO_FIRE: String = "to fire"
const TRANS_TO_HIT: String = "to hit"
const TRANS_TO_MISS: String = "to miss"
const TRANS_TO_OFF: String = "to off"


func _ready() -> void:
	bone_idx = skeletonModifier.get_skeleton().find_bone(parent_bone_name)


# off state
# -----------------------------------------
func _on_off_state_entered() -> void:
	## Reset bolt mesh
	bolt_mesh.visible = false
	bolt_mesh.position = Vector3.ZERO


# fire state
# -----------------------------------------
func _on_fire_state_entered() -> void:
	## Show the bolt
	bolt_mesh.visible = true


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
		if raycast.get_collider() is Player:
			sc.send_event(TRANS_TO_HIT)
		else:
			sc.send_event(TRANS_TO_MISS)
	else:
		bolt_mesh.position.y = updated_distance


# hit state
# -----------------------------------------
func _on_hit_state_entered() -> void:
	Signals.player_knocked.emit(Vector3.ZERO, recorded_collision_point)
	shrapnel_particles.restart()
	shrapnel_particles.emitting = true
	await impact_animation.hit()
	sc.send_event(TRANS_TO_OFF)


# miss state
# -----------------------------------------
func _on_miss_state_entered() -> void:
	shrapnel_particles.restart()
	shrapnel_particles.emitting = true
	sc.send_event(TRANS_TO_OFF)


func fire() -> void:
	sc.send_event(TRANS_TO_FIRE)
