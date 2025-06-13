class_name CharacterAsset
extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree

@export var speed_scale: float = 1.4
@export var sprint_speed_scale: float = 1.8
@export var recovering_speed_scale: float = 0.9

var direction_faced: Enums.Direction = Enums.Direction.RIGHT
var is_skidding: bool = false
var is_sprinting: bool = false
var is_recovering: bool = false
var state: AnimationNodeStateMachinePlayback
var move_left_state: AnimationNodeStateMachinePlayback
var move_right_state: AnimationNodeStateMachinePlayback


var speed: float:
	get:
		return speed
	set(value):
		speed = value
		var blend_value: float = abs(value)
		anim_tree.set("parameters/move left/move/move/blend_position", blend_value)
		anim_tree.set("parameters/jump left/jump/jump/blend_position", blend_value)
		anim_tree.set("parameters/kick left/kick/kick/blend_position", blend_value)
		anim_tree.set("parameters/move right/move/move/blend_position", blend_value)
		anim_tree.set("parameters/jump right/jump/jump/blend_position", blend_value)
		anim_tree.set("parameters/kick right/kick/kick/blend_position", blend_value)


var root_motion_position: Vector3:
	get:
		return anim_tree.get_root_motion_position()


var root_motion_rotation: Quaternion:
	get:
		return anim_tree.get_root_motion_rotation()


func _ready() -> void:
	state = anim_tree.get("parameters/playback")
	move_left_state = anim_tree.get("parameters/move left/playback")
	move_right_state = anim_tree.get("parameters/move right/playback")


func _physics_process(delta: float) -> void:
	#print("-----")
	#print(state.get_current_node())
	#print("PARAMETER -> turn left to fall right: ", anim_tree.get("parameters/conditions/turn left to fall right"))
	#print("PARAMETER -> turn right to fall left: ", anim_tree.get("parameters/conditions/turn right to fall left"))
	#print("PARAMETER -> turn left to move right: ", anim_tree.get("parameters/conditions/turn left to move right"))
	#print("PARAMETER -> turn right to move left: ", anim_tree.get("parameters/conditions/turn right to move left"))
	pass


func to_idle() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.travel("idle left")
	if direction_faced == Enums.Direction.RIGHT:
		state.travel("idle right")

func face_left() -> void:
	direction_faced = Enums.Direction.LEFT


func face_right() -> void:
	direction_faced = Enums.Direction.RIGHT


func to_move_left() -> void:
	move_left_state.start("move")
	state.travel("move left")


func to_move_right() -> void:
	move_right_state.start("move")
	state.travel("move right")


func to_turn_left() -> void:
	anim_tree.set("parameters/conditions/turn left to move right", true)
	state.start("turn left", true)


func to_turn_right() -> void:
	anim_tree.set("parameters/conditions/turn right to move left", true)
	state.start("turn right", true)


func to_move() -> void:
	if direction_faced == Enums.Direction.LEFT:
		move_left_state.start("move")
		state.travel("move left")
	if direction_faced == Enums.Direction.RIGHT:
		move_right_state.start("move")
		state.travel("move right")


func to_sprint() -> void:
	is_sprinting = true
	if direction_faced == Enums.Direction.LEFT:
		move_left_state.travel("sprint")
	if direction_faced == Enums.Direction.RIGHT:
		move_right_state.travel("sprint")



func reset_speed() -> void:
	is_recovering = false
	is_sprinting = false
	move_left_state.start("move")
	move_right_state.start("move")


func to_recovery() -> void:
	is_recovering = true
	if direction_faced == Enums.Direction.LEFT:
		move_left_state.travel("recover")
	if direction_faced == Enums.Direction.RIGHT:
		move_right_state.travel("recover")


func to_jump() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.start("jump left", true)
	if direction_faced == Enums.Direction.RIGHT:
		state.start("jump right", true)


func to_fall() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.travel("fall left")
	if direction_faced == Enums.Direction.RIGHT:
		state.travel("fall right")
	state.next()


func to_kick() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.start("kick left", true)
	if direction_faced == Enums.Direction.RIGHT:
		state.start("kick right", true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "idle jump right" or anim_name == "run jump right":
		Signals.jump_right_animation_ended.emit()
	if anim_name == "idle jump left" or anim_name == "run jump left":
		Signals.jump_left_animation_ended.emit()
	if anim_name == "idle kick right" or anim_name == "run kick right":
		Signals.kick_right_animation_ended.emit()
	if anim_name == "idle kick left" or anim_name == "run kick left":
		Signals.kick_left_animation_ended.emit()
	if anim_name == "turn left":
		Signals.turn_left_animation_ended.emit()
	if anim_name == "turn right":
		Signals.turn_right_animation_ended.emit()


func jump_to_move_path() -> void:
	anim_tree.set("parameters/conditions/jump left to move left", true)
	anim_tree.set("parameters/conditions/jump right to move right", true)
	anim_tree.set("parameters/conditions/jump left to fall left", false)
	anim_tree.set("parameters/conditions/jump right to fall right", false)


func jump_to_fall_path() -> void:
	anim_tree.set("parameters/conditions/jump left to move left", false)
	anim_tree.set("parameters/conditions/jump right to move right", false)
	anim_tree.set("parameters/conditions/jump left to fall left", true)
	anim_tree.set("parameters/conditions/jump right to fall right", true)


func reset_jump_paths() -> void:
	anim_tree.set("parameters/conditions/jump left to move left", false)
	anim_tree.set("parameters/conditions/jump right to move right", false)
	anim_tree.set("parameters/conditions/jump left to fall left", false)
	anim_tree.set("parameters/conditions/jump right to fall right", false)


func turn_to_fall_path() -> void:
	anim_tree.set("parameters/conditions/turn left to fall right", true)
	anim_tree.set("parameters/conditions/turn right to fall left", true)
	anim_tree.set("parameters/conditions/turn left to move right", false)
	anim_tree.set("parameters/conditions/turn right to move left", false)


func turn_to_move_path() -> void:
	anim_tree.set("parameters/conditions/turn left to fall right", false)
	anim_tree.set("parameters/conditions/turn right to fall left", false)
	anim_tree.set("parameters/conditions/turn left to move right", true)
	anim_tree.set("parameters/conditions/turn right to move left", true)


func reset_turn_paths() -> void:
	anim_tree.set("parameters/conditions/turn left to fall right", false)
	anim_tree.set("parameters/conditions/turn right to fall left", false)
	anim_tree.set("parameters/conditions/turn left to move right", false)
	anim_tree.set("parameters/conditions/turn right to move left", false)
