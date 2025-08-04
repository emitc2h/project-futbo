class_name DroneModel
extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree
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
	anim_state = anim_tree.get("parameters/playback")
	$AnimationTree/AnimationStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	$AnimationTree/AnimationStateChangeTracker.anim_state_started.connect(_on_anim_state_started)


func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)
