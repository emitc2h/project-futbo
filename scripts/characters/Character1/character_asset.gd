class_name CharacterAsset
extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree

## Parameters
@export var speed_scale: float = 1.4
@export var jump_speed_scale: float = 0.75
@export var sprint_speed_scale: float = 1.8
@export var recovering_speed_scale: float = 0.9

## animation state machine references
var main_anim_state: AnimationNodeStateMachinePlayback
var move_left_anim_state: AnimationNodeStateMachinePlayback
var move_right_anim_state: AnimationNodeStateMachinePlayback
var knocked_left_anim_state: AnimationNodeStateMachinePlayback
var knocked_right_anim_state: AnimationNodeStateMachinePlayback

var current_state_machine: AnimationNodeStateMachinePlayback

## More reliable animation signals
signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)

## Decide which state to aim for after jumping
var trans_fall_after_jump_opened: bool = false
var trans_move_after_jump_opened: bool = true

## Decide which state to aim for after turning
var trans_move_after_turn_opened: bool = true

## Decide which knocked down animations to play
var trans_knocked_head_front_opened: bool = false
var trans_knocked_middle_front_opened: bool = false
var trans_knocked_middle_back_opened: bool = false
var trans_knocked_head_back_opened: bool = false

## Internal variables
var direction_faced: Enums.Direction = Enums.Direction.RIGHT
var is_skidding: bool = false
var jump_blend_factor: float = 1.0


######################################
##   ANIMATION TREE PATH JUNCTIONS  ##
######################################
func open_paths_to_fall() -> void:
	trans_fall_after_jump_opened = true
	trans_move_after_jump_opened = false
	trans_move_after_turn_opened = false


func open_paths_to_move() -> void:
	trans_fall_after_jump_opened = false
	trans_move_after_jump_opened = true
	trans_move_after_turn_opened = true


func open_paths_to_knocked_head_front() -> void:
	trans_knocked_head_front_opened = true
	trans_knocked_middle_front_opened = false
	trans_knocked_middle_back_opened = false
	trans_knocked_head_back_opened = false


func open_paths_to_knocked_middle_front() -> void:
	trans_knocked_head_front_opened = false
	trans_knocked_middle_front_opened = true
	trans_knocked_middle_back_opened = false
	trans_knocked_head_back_opened = false


func open_paths_to_knocked_middle_back() -> void:
	trans_knocked_head_front_opened = false
	trans_knocked_middle_front_opened = false
	trans_knocked_middle_back_opened = true
	trans_knocked_head_back_opened = false


func open_paths_to_knocked_head_back() -> void:
	trans_knocked_head_front_opened = false
	trans_knocked_middle_front_opened = false
	trans_knocked_middle_back_opened = false
	trans_knocked_head_back_opened = true


######################################
##         GETTERS & SETTERS        ##
######################################
var sprint_mode: Enums.SprintMode:
	get:
		return sprint_mode
	set(value):
		sprint_mode = value
		if value == Enums.SprintMode.NORMAL:
			jump_blend_factor = 1.0
			anim_tree.set("parameters/jump left/jump/scale/scale", jump_speed_scale)
			anim_tree.set("parameters/jump right/jump/scale/scale", jump_speed_scale)
		if value == Enums.SprintMode.SPRINTING:
			jump_blend_factor = 1.0
			anim_tree.set("parameters/jump left/jump/scale/scale", jump_speed_scale * 0.75)
			anim_tree.set("parameters/jump right/jump/scale/scale", jump_speed_scale * 0.75)
		if value == Enums.SprintMode.RECOVERING:
			jump_blend_factor = 0.5
			anim_tree.set("parameters/jump left/jump/scale/scale", jump_speed_scale)
			anim_tree.set("parameters/jump right/jump/scale/scale", jump_speed_scale)

var move_initial_state: String:
	get:
		if sprint_mode == Enums.SprintMode.SPRINTING:
			return "sprint"
		if sprint_mode == Enums.SprintMode.RECOVERING:
			return "recover"
		return "move"

var jump_speed_factor: float:
	get:
		if sprint_mode == Enums.SprintMode.SPRINTING:
			return 1.2
		if sprint_mode == Enums.SprintMode.RECOVERING:
			return 1.0
		return 1.1


var speed: float:
	get:
		return speed
	set(value):
		speed = value
		var blend_value: float = abs(value)
		anim_tree.set("parameters/move left/move/move/blend_position", blend_value)
		anim_tree.set("parameters/jump left/jump/jump/blend_position", blend_value * jump_blend_factor)
		anim_tree.set("parameters/kick left/kick/kick/blend_position", blend_value)
		anim_tree.set("parameters/move right/move/move/blend_position", blend_value)
		anim_tree.set("parameters/jump right/jump/jump/blend_position", blend_value * jump_blend_factor)
		anim_tree.set("parameters/kick right/kick/kick/blend_position", blend_value)


var root_motion_position: Vector3:
	get:
		return anim_tree.get_root_motion_position()


var root_motion_rotation: Quaternion:
	get:
		return anim_tree.get_root_motion_rotation()


func _ready() -> void:
	main_anim_state = anim_tree.get("parameters/playback")
	$AnimationTree/MainAnimStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	$AnimationTree/MainAnimStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	
	move_left_anim_state = anim_tree.get("parameters/move left/playback")
	$AnimationTree/MoveLeftAnimStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	$AnimationTree/MoveLeftAnimStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	
	move_right_anim_state = anim_tree.get("parameters/move right/playback")
	$AnimationTree/MoveRightAnimStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	$AnimationTree/MoveRightAnimStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	
	knocked_left_anim_state = anim_tree.get("parameters/knocked left/playback")
	$AnimationTree/KnockedLeftAnimStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	$AnimationTree/KnockedLeftAnimStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	
	knocked_right_anim_state = anim_tree.get("parameters/knocked right/playback")
	$AnimationTree/KnockedRightAnimStateChangeTracker.anim_state_started.connect(_on_anim_state_started)
	$AnimationTree/KnockedRightAnimStateChangeTracker.anim_state_finished.connect(_on_anim_state_finished)
	
	


######################################
##        CONTROL FUNCTIONS         ##
######################################
func to_idle() -> void:
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("idle left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("idle right")

func face_left() -> void:
	direction_faced = Enums.Direction.LEFT


func face_right() -> void:
	direction_faced = Enums.Direction.RIGHT


func to_move_left() -> void:
	move_left_anim_state.start(move_initial_state)
	move_right_anim_state.start(move_initial_state)
	main_anim_state.travel("move left")


func to_move_right() -> void:
	move_left_anim_state.start(move_initial_state)
	move_right_anim_state.start(move_initial_state)
	main_anim_state.travel("move right")


func to_turn_left() -> void:
	anim_tree.set("parameters/conditions/turn left to move right", true)
	main_anim_state.start("turn left", true)


func to_turn_right() -> void:
	anim_tree.set("parameters/conditions/turn right to move left", true)
	main_anim_state.start("turn right", true)


func to_move() -> void:
	move_left_anim_state.start(move_initial_state)
	move_right_anim_state.start(move_initial_state)
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("move left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("move right")


func to_sprint() -> void:
	sprint_mode = Enums.SprintMode.SPRINTING
	move_left_anim_state.travel("sprint")
	move_right_anim_state.travel("sprint")


func reset_speed() -> void:
	sprint_mode = Enums.SprintMode.NORMAL
	move_left_anim_state.travel("move")
	move_right_anim_state.travel("move")


func to_recovery() -> void:
	sprint_mode = Enums.SprintMode.RECOVERING
	move_left_anim_state.travel("recover")
	move_right_anim_state.travel("recover")


func to_jump() -> void:
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.start("jump left", true)
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.start("jump right", true)


func to_fall() -> void:
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("fall left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("fall right")
	main_anim_state.next()


func to_kick() -> void:
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("kick left", true)
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("kick right", true)


func to_long_kick() -> void:
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("long kick left", true)
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("long kick right", true)


func to_knocked_head_front() -> void:
	open_paths_to_knocked_head_front()
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("knocked left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("knocked right")


func to_knocked_middle_front() -> void:
	open_paths_to_knocked_middle_front()
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("knocked left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("knocked right")


func to_knocked_head_back() -> void:
	open_paths_to_knocked_head_back()
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("knocked left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("knocked right")


func to_knocked_middle_back() -> void:
	open_paths_to_knocked_middle_back()
	if direction_faced == Enums.Direction.LEFT:
		main_anim_state.travel("knocked left")
	if direction_faced == Enums.Direction.RIGHT:
		main_anim_state.travel("knocked right")


######################################
##             SIGNALS             ##
######################################
func _on_anim_state_finished(anim_name: String) -> void:
	anim_state_finished.emit(anim_name)
	if anim_name == "turn left":
		Signals.turn_right_animation_ended.emit()
	if anim_name == "turn right":
		Signals.turn_left_animation_ended.emit()
	if anim_name == "jump right":
		Signals.jump_right_animation_ended.emit()
	if anim_name == "jump left":
		Signals.jump_left_animation_ended.emit()
	if anim_name == "kick right":
		Signals.kick_right_animation_ended.emit()
	if anim_name == "kick left":
		Signals.kick_left_animation_ended.emit()


func _on_anim_state_started(anim_name: String) -> void:
	anim_state_started.emit(anim_name)
