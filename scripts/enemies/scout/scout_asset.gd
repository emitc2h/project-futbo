class_name ScoutAsset
extends Node3D

@export var anim_tree: AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

## Signals
signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)


func _ready() -> void:
	## Connect signals
	$AnimationTree/AnimationStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	$AnimationTree/AnimationStateChangeTracker.anim_state_started.connect(_on_anim_state_started)

## Signals
## ---------------------------------------
func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)
