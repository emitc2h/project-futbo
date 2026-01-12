class_name DroneModel
extends Node3D

## Inject drone dependency to pass it to the physical bones
@export var drone: Drone

## Animation Managers
@onready var em_spinners_animation: DroneEMSpinnersAnimation = $EMSpinnersAnimation
@onready var engines_animation: DroneEnginesAnimation = $EnginesAnimation

## Main Drone Model Mesh
@onready var drone_mesh: MeshInstance3D = $Armature/Skeleton3D/drone

## Animation Tree
@onready var anim_tree: AnimationTree = $AnimationTree
var anim_state: AnimationNodeStateMachinePlayback

## Bones
@onready var physical_bones: PhysicalBoneSimulator3D = $Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var body_bone: PhysicalBone3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY"

## Particle Systems
@onready var lightning_particles: GPUParticles3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY/LightningParticles3D"
@onready var smoke_particles: GPUParticles3D = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone BODY/SmokeParticles3D"

## Look-at Modifiers
@onready var lookat_modifier_left: LookAtModifier3D = $Armature/Skeleton3D/LookAtModifierLeft
@onready var lookat_modifier_right: LookAtModifier3D = $Armature/Skeleton3D/LookAtModifierRight

## Plasma bolts
@onready var plasma_bolt_left: DronePlasmaBolt = $Armature/Skeleton3D/DronePlasmaBoltLeft
@onready var plasma_bolt_right: DronePlasmaBolt = $Armature/Skeleton3D/DronePlasmaBoltRight

## Animation Tree Gates
# Decide which state to aim for after opening up
var trans_openup_to_idle_opened: bool = true
var trans_openup_to_targeting_opened: bool = false

# Decide which state to aim for after stopping thrust
var trans_stopthrust_to_idle_opened: bool = true
var trans_stopthrust_to_targeting_opened: bool = false

# Decide which state to aim for after firing
var trans_fire_to_idle_opened: bool = true
var trans_fire_to_targeting_opened: bool = false

var accumulated_damage: float = 0.0

## Signals
signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)


func _ready() -> void:
	## Initialize lightning particles
	lightning_particles.emitting = false
	lightning_particles.amount_ratio = 0.0
	lightning_particles.visible = false
	
	## Initialize smoke particles
	smoke_particles.emitting = false
	smoke_particles.amount_ratio = 0.0
	smoke_particles.visible = false
	
	## Initialize state machine
	anim_state = anim_tree.get("parameters/playback")
	
	## Initialize modifiers
	lookat_modifier_left.influence = 0.0
	lookat_modifier_right.influence = 0.0

	## Connect signals
	$AnimationTree/AnimationStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	$AnimationTree/AnimationStateChangeTracker.anim_state_started.connect(_on_anim_state_started)

	for bone in physical_bones.get_children():
		bone.drone = drone
	
	plasma_bolt_left.did_hit.connect(_on_did_hit)
	plasma_bolt_right.did_hit.connect(_on_did_hit)


func _physics_process(_delta: float) -> void:
	## Those should just track the position of the body bone
	lightning_particles.global_rotation = Vector3.ZERO
	smoke_particles.global_rotation = Vector3.ZERO


## Animation Tree Path Controls
## ---------------------------------------
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


## Signals
## ---------------------------------------
func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)
	
	
func _on_did_hit() -> void:
	spinners_disengage_target()


## Animations
## ---------------------------------------
func die() -> void:
	em_spinners_animation.turn_off()
	
	lightning_particles.visible = true
	lightning_particles.explosiveness = 0.0
	lightning_particles.one_shot = false
	lightning_particles.amount = 10
	lightning_particles.amount_ratio = 1.0
	lightning_particles.preprocess = 2.0
	lightning_particles.emitting = true
	
	var lightning_tween: Tween = get_tree().create_tween()
	lightning_tween.tween_property(lightning_particles, "amount_ratio", 0.2, 10.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	
	smoke_particles.visible = true
	smoke_particles.amount = 35
	smoke_particles.explosiveness = 0.0
	smoke_particles.one_shot = false
	smoke_particles.amount_ratio = 1.0
	smoke_particles.preprocess = 3.0
	smoke_particles.emitting = true
	
	var smoke_tween: Tween = get_tree().create_tween()
	smoke_tween.tween_property(smoke_particles, "amount_ratio", 0.2, 8.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	await smoke_tween.finished
	smoke_particles.emitting = false


func damage_hit(strength: float = 1.0) -> void:
	accumulated_damage += strength / 100.0
	lightning_particles.visible = true
	lightning_particles.amount = int(strength / 3.0)
	lightning_particles.amount_ratio = 1.0
	lightning_particles.explosiveness = 0.9
	lightning_particles.one_shot = true
	lightning_particles.preprocess = 0.0
	lightning_particles.emitting = true
	
	smoke_particles.visible = true
	smoke_particles.amount = int(2 * strength)
	smoke_particles.amount_ratio = 1.0
	smoke_particles.explosiveness = 0.65
	smoke_particles.one_shot = true
	smoke_particles.preprocess = 0.0
	smoke_particles.emitting = true
	
	await smoke_particles.finished
	permanent_damage()


func permanent_damage() -> void:
	var amount_ratio: float = accumulated_damage / (1.0 + accumulated_damage)
	
	lightning_particles.amount = 5
	lightning_particles.amount_ratio = amount_ratio
	lightning_particles.explosiveness = 0.0
	lightning_particles.one_shot = false
	lightning_particles.emitting = true
	
	smoke_particles.amount = 20
	smoke_particles.amount_ratio = amount_ratio
	smoke_particles.explosiveness = 0.0
	smoke_particles.one_shot = false
	smoke_particles.emitting = true


func charge_spinners(duration: float) -> void:
	em_spinners_animation.charge(duration)


func fire_spinners(duration: float) -> void:
	em_spinners_animation.fire(duration)
	plasma_bolt_left.fire()
	plasma_bolt_right.fire()


## Spinners Targeting
## ----------------------------------------
func spinners_acquire_target(target: Node3D) -> void:
	lookat_modifier_left.target_node = target.get_path()
	lookat_modifier_right.target_node = target.get_path()


func spinners_engage_target() -> void:
	lookat_modifier_left.influence = 1.0
	lookat_modifier_right.influence = 1.0


func spinners_disengage_target() -> void:
	lookat_modifier_left.influence = 0.0
	lookat_modifier_right.influence = 0.0
