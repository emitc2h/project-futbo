class_name DronePlasmaBolt
extends Node3D

## Inject Skeleton3D Dependency
@export var skeletonModifier: SkeletonModifier3D
@export var parent_bone_name: String
@export var bolt_speed: float = 40.0
@export var bolt_size: float = 0.0

@onready var bolt: Node3D = $DronePlasmaBoltModel
@onready var sc: StateChart = $StateChart
@onready var raycast: RayCast3D = $RayCast3D

var bone_idx: int
var travel_distance: float
var trans_after_fire: String
var hit_player: bool = false

const TRANS_TO_FIRE: String = "to fire"
const TRANS_TO_HIT: String = "to hit"
const TRANS_TO_MISS: String = "to miss"
const TRANS_TO_OFF: String = "to off"


func _ready() -> void:
	bone_idx = skeletonModifier.get_skeleton().find_bone(parent_bone_name)


func _physics_process(delta: float) -> void:
	await skeletonModifier.modification_processed
	self.transform = skeletonModifier.get_skeleton().get_bone_global_pose(bone_idx)


# off state
# -----------------------------------------
func _on_off_state_entered() -> void:
	bolt.visible = false
	bolt.position = Vector3.ZERO


# fire state
# -----------------------------------------
func _on_fire_state_entered() -> void:
	self.transform = skeletonModifier.get_skeleton().get_bone_global_pose(bone_idx)
	bolt.visible = true
	if raycast.is_colliding():
		travel_distance = raycast.get_collision_point().distance_to(self.global_position) - bolt_size
		trans_after_fire = TRANS_TO_HIT
		if raycast.get_collider() is Player:
			Signals.player_knocked.emit(Vector3.ZERO, raycast.get_collision_point())
	else:
		travel_distance = raycast.target_position.y
		trans_after_fire = TRANS_TO_MISS
	
	print("travel distance: ", travel_distance)


func _on_fire_state_physics_processing(delta: float) -> void:
	self.transform = skeletonModifier.get_skeleton().get_bone_global_pose(bone_idx)
	var updated_distance: float = bolt.position.y + bolt_speed * delta
	if updated_distance > travel_distance:
		sc.send_event(TRANS_TO_HIT)
	else:
		bolt.position.y = updated_distance


# hit state
# -----------------------------------------
func _on_hit_state_entered() -> void:
	sc.send_event(TRANS_TO_OFF)

# miss state
# -----------------------------------------
func _on_miss_state_entered() -> void:
	sc.send_event(TRANS_TO_OFF)


func fire() -> void:
	sc.send_event(TRANS_TO_FIRE)
