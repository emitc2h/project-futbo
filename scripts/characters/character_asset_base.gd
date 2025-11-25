class_name CharacterAssetBase
extends Node3D

## Nodes controlled by this node
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var root_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
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
		# Set the speed of kicking
		anim_tree.set("parameters/kick/kick/blend_position", abs(value))

## The vertical dimension of the knock animation blending
var vertical_knock_blend: float:
	set(value):
		var current_blend: Vector2 = anim_tree.get("parameters/knocked/knocked/knocked/blend_position")
		anim_tree.set("parameters/knocked/knocked/knocked/blend_position", Vector2(current_blend.x, value))

## The horizontal dimension of the knock animation blending
var horizontal_knock_blend: float:
	set(value):
		var current_blend: Vector2 = anim_tree.get("parameters/knocked/knocked/knocked/blend_position")
		anim_tree.set("parameters/knocked/knocked/knocked/blend_position", Vector2(value, current_blend.y))
		anim_tree.set("parameters/knocked/die/die/blend_position", value)
		anim_tree.set("parameters/knocked/hit/hit/blend_position", value)

## The blending variable for the recovery animation
var recover_blend: float:
	set(value):
		anim_tree.set("parameters/knocked/recover/recover/blend_position", value)

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
signal kick_finished
signal long_kick_finished
signal knocked_finished
signal recover_finished
signal hit_finished

## Animation Tree Path Gates
var jump_to_fall_path: bool = false
var auto_recover_from_knocked: bool = false
var to_knock_path: bool = true
var to_die_path: bool = false
var to_hit_path: bool = false


func _ready() -> void:
	$AnimationTree/MovementStateChangeTracker.anim_state_started.connect(_on_movement_anim_state_started)
	$AnimationTree/MovementStateChangeTracker.anim_state_finished.connect(_on_movement_anim_state_finished)
	
	$AnimationTree/KnockedStateChangeTracker.anim_state_started.connect(_on_knocked_anim_state_started)
	$AnimationTree/KnockedStateChangeTracker.anim_state_finished.connect(_on_knocked_anim_state_finished)


######################################
##          PATH FUNCTIONS          ##
######################################
func open_jump_to_fall_path() -> void:
	
	print("opening jump_to_fall_path")
	jump_to_fall_path = true


func close_jump_to_fall_path() -> void:
	jump_to_fall_path = false


func open_knock_path() -> void:
	to_knock_path = true
	to_die_path = false
	to_hit_path = false


func open_hit_path() -> void:
	to_knock_path = false
	to_die_path = false
	to_hit_path = true


func open_die_path() -> void:
	to_knock_path = false
	to_die_path = true
	to_hit_path = false


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


func kick() -> void:
	root_state.travel("kick")
	#anim_tree.set("parameters/kick shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await kick_finished


func long_kick() -> void:
	root_state.travel("long kick")
	#anim_tree.set("parameters/long kick shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await long_kick_finished


func knock() -> void:
	root_state.travel("knocked")
	#anim_tree.set("parameters/knocked shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func recover_from_knock() -> void:
	knocked_state.travel("recover")


#=======================================================
# SIGNALS
#=======================================================
func _on_movement_anim_state_started(anim_name: String) -> void:
	if anim_name == "fall": fall_started.emit()


func _on_movement_anim_state_finished(anim_name: String) -> void:
	if anim_name == "turn": turn_finished.emit()
	if anim_name == "long kick": long_kick_finished.emit()
	if anim_name == "kick": kick_finished.emit()


func _on_knocked_anim_state_started(_anim_name: String) -> void:
	pass


func _on_knocked_anim_state_finished(anim_name: String) -> void:
	match(anim_name):
		"knocked":
			knocked_finished.emit()
		"recover":
			recover_finished.emit()
		"hit":
			print("hit finished")
			hit_finished.emit()
