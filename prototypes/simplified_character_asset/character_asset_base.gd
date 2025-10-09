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
		# Set the speed of walking/running
		anim_tree.set("parameters/movement/move/move/move/blend_position", value)
		# Set the speed of jumping
		anim_tree.set("parameters/movement/jump/jump/blend_position", abs(value))

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
signal fall_started

## Animation Tree Path Gates
var jump_to_fall_path: bool = false

func _ready() -> void:
	$AnimationTree/MovementStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)


######################################
##          PATH FUNCTIONS          ##
######################################
func open_jump_to_fall_path() -> void:
	jump_to_fall_path = true


func close_jump_to_fall_path() -> void:
	jump_to_fall_path = false



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


func jump() -> void:
	movement_state.travel("jump")


func fall() -> void:
	movement_state.travel("fall")


func _on_anim_state_started(anim_name: String) -> void:
	if anim_name == "fall":
		fall_started.emit()


func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "turn":
		turn_finished.emit()
