class_name ScoutAsset
extends Node3D

@export var anim_tree: AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
@export var mesh: MeshInstance3D
@export var engines_material_index: int
@export var plasma_bolt: DronePlasmaBolt

## Exhaust
@onready var exhaust_material: ShaderMaterial = mesh.get_surface_override_material(engines_material_index)

## Spinner
@onready var spinner_animation: SpinnersAnimation = $SpinnersAnimation 

## Plasma bolt

## Signals
signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)


func _ready() -> void:
	## Connect signals
	$AnimationTree/AnimationStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	$AnimationTree/AnimationStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	plasma_bolt.visible = true
	
	## initialize exhaust material
	exhaust_material.set_shader_parameter("noise_speed", 6.0)
	exhaust_material.set_shader_parameter("noise_intensity", 0.0)


func charge_spinners(duration: float) -> void:
	spinner_animation.charge(duration)


func fire_spinners(duration: float) -> void:
	spinner_animation.fire(duration)
	plasma_bolt.fire()


## Signals
## ---------------------------------------
func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)


func set_exhaust_intensity(intensity: float) -> void:
	exhaust_material.set_shader_parameter("noise_intensity", 60 * intensity)
