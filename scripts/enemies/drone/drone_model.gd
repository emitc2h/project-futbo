class_name DroneModel
extends Node3D

@export var drone: Drone

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var physical_bones: PhysicalBoneSimulator3D = $Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var body_bone: PhysicalBone3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY"
@onready var lightning_particles: GPUParticles3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY/LightningParticles3D"
@onready var smoke_particles: GPUParticles3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY/SmokeParticles3D"

var anim_state: AnimationNodeStateMachinePlayback

## Decide which state to aim for after opening up
var trans_openup_to_idle_opened: bool = true
var trans_openup_to_targeting_opened: bool = false

## Decide which state to aim for after stopping thrust
var trans_stopthrust_to_idle_opened: bool = true
var trans_stopthrust_to_targeting_opened: bool = false

## Decide which state to aim for after firing
var trans_fire_to_idle_opened: bool = true
var trans_fire_to_targeting_opened: bool = false

func open_paths_to_targeting() -> void:
	trans_openup_to_idle_opened = false
	trans_stopthrust_to_idle_opened = false
	trans_fire_to_idle_opened = false
	
	trans_openup_to_targeting_opened = true
	trans_stopthrust_to_targeting_opened = true
	trans_fire_to_targeting_opened = true


func open_paths_to_idle() -> void:
	trans_openup_to_idle_opened = true
	trans_stopthrust_to_idle_opened = true
	trans_fire_to_idle_opened = true
	
	trans_openup_to_targeting_opened = false
	trans_stopthrust_to_targeting_opened = false
	trans_fire_to_targeting_opened = false

## More reliable animation signals
signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)

func _ready() -> void:
	lightning_particles.emitting = false
	lightning_particles.amount_ratio = 0.0
	smoke_particles.emitting = false
	smoke_particles.amount_ratio = 0.0
	anim_state = anim_tree.get("parameters/playback")
	$AnimationTree/AnimationStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	$AnimationTree/AnimationStateChangeTracker.anim_state_started.connect(_on_anim_state_started)

	for bone in physical_bones.get_children():
		bone.drone = drone


func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)


## Controls
## ---------------------------------------
func die_particles() -> void:
	lightning_particles.emitting = true
	lightning_particles.amount_ratio = 1.0
	var lightning_tween: Tween = get_tree().create_tween()
	lightning_tween.tween_property(lightning_particles, "amount_ratio", 0.2, 10.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	
	smoke_particles.emitting = true
	smoke_particles.amount_ratio = 1.0
	var smoke_tween: Tween = get_tree().create_tween()
	smoke_tween.tween_property(smoke_particles, "amount_ratio", 0.2, 8.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	await smoke_tween.finished
	smoke_particles.emitting = false
