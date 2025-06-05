class_name CharacterAsset
extends CharacterBody3D

@onready var anim_tree: AnimationTree = $AnimationTree

@export var speed_scale: float = 1.2

var direction_faced: Enums.Direction = Enums.Direction.RIGHT
var is_skidding: bool = false
var state: AnimationNodeStateMachinePlayback


var speed: float:
	get:
		return speed
	set(value):
		speed = value
		var blend_value: float = (abs(value) * 2) - 1.0
		if direction_faced == Enums.Direction.LEFT:
			anim_tree.set("parameters/move left/blend/blend_amount", blend_value)
		if direction_faced == Enums.Direction.RIGHT:
			anim_tree.set("parameters/move right/blend/blend_amount", blend_value)


var root_motion_position: Vector3:
	get:
		return anim_tree.get_root_motion_position()


var root_motion_rotation: Quaternion:
	get:
		return anim_tree.get_root_motion_rotation()


func _ready() -> void:
	anim_tree.set("parameters/move left/speed scale/scale", speed_scale)
	anim_tree.set("parameters/move right/speed scale/scale", speed_scale)
	anim_tree.set("parameters/jump left/speed scale/scale", speed_scale)
	anim_tree.set("parameters/jump right/speed scale/scale", speed_scale)
	anim_tree.set("parameters/turn left/speed scale/scale", speed_scale)
	anim_tree.set("parameters/turn right/speed scale/scale", speed_scale)
	anim_tree.set("parameters/kick left/speed scale/scale", speed_scale)
	anim_tree.set("parameters/kick right/speed scale/scale", speed_scale)
	state = anim_tree.get("parameters/playback")


func to_idle() -> void:
	state.travel("idle")


func face_left() -> void:
	direction_faced = Enums.Direction.LEFT


func face_right() -> void:
	direction_faced = Enums.Direction.RIGHT


func to_move_left() -> void:
	state.travel("move left")


func to_move_right() -> void:
	state.travel("move right")


func to_turn_left() -> void:
	state.start("turn left", true)


func to_turn_right() -> void:
	state.start("turn right", true)


func to_move() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.travel("move left")
	if direction_faced == Enums.Direction.RIGHT:
		state.travel("move right")


func to_jump() -> void:
	if direction_faced == Enums.Direction.LEFT:
		anim_tree.set("parameters/jump left/blend/blend_amount", abs(speed))
		state.start("jump left", true)
	if direction_faced == Enums.Direction.RIGHT:
		anim_tree.set("parameters/jump right/blend/blend_amount", abs(speed))
		state.start("jump right", true)


func to_fall() -> void:
	if direction_faced == Enums.Direction.LEFT:
		state.travel("fall left")
	if direction_faced == Enums.Direction.RIGHT:
		state.travel("fall right")


func to_kick() -> void:
	if direction_faced == Enums.Direction.LEFT:
		anim_tree.set("parameters/kick left/blend/blend_amount", abs(speed))
		state.start("kick left", true)
	if direction_faced == Enums.Direction.RIGHT:
		anim_tree.set("parameters/kick right/blend/blend_amount", abs(speed))
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
	anim_tree.set("parameters/conditions/jump to move left", true)
	anim_tree.set("parameters/conditions/jump to move right", true)
	anim_tree.set("parameters/conditions/jump to fall left", false)
	anim_tree.set("parameters/conditions/jump to fall right", false)


func jump_to_fall_path() -> void:
	anim_tree.set("parameters/conditions/jump to move left", false)
	anim_tree.set("parameters/conditions/jump to move right", false)
	anim_tree.set("parameters/conditions/jump to fall left", true)
	anim_tree.set("parameters/conditions/jump to fall right", true)
