class_name CharacterAssetBase
extends Node3D

## Nodes controlled by this node
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var movement_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/movement/playback")
@onready var move_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/movement/move/playback")
@onready var knocked_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/knocked/playback")

## Speed parameter controls the movement speed of the character
var speed: float:
	set(value):
		## I'm assuming here that speed receives value automatically. I have to test this.
		var blend_value: float = abs(value)
		# Set the speed of walking/running
		anim_tree.set("parameters/movement/move/move/move/blend_position", blend_value)
		# Set the speed of jumping
		anim_tree.set("parameters/movement/jump/jump/blend_position", blend_value)

## Access the root motion
var root_motion_position: Vector3:
	get:
		return anim_tree.get_root_motion_position()

## Access the root rotation
var root_motion_rotation: Quaternion:
	get:
		return anim_tree.get_root_motion_rotation()

## Signals
signal turn_finished


func _ready() -> void:
	$AnimationTree/MovementStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)


######################################
##        CONTROL FUNCTIONS         ##
######################################
func idle() -> void:
	movement_state.travel("idle")


func move() -> void:
	movement_state.travel("move")


func turn() -> void:
	movement_state.travel("turn")
	await turn_finished


func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "turn":
		turn_finished.emit()
