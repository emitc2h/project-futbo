class_name CharacterAsset
extends CharacterBody3D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $CharacterModel/AnimationPlayer

@export var speed_scale: float = 1.4
@export var turn_scale: float = 1.8

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
	state.travel("turn left")


func to_turn_right() -> void:
	state.travel("turn right")


func to_jump() -> void:
	if direction_faced == Enums.Direction.LEFT:
		anim_tree.set("parameters/jump left/blend/blend_amount", abs(speed))
		state.travel("jump left")
	if direction_faced == Enums.Direction.RIGHT:
		anim_tree.set("parameters/jump right/blend/blend_amount", abs(speed))
		state.travel("jump right")


func to_kick() -> void:
	if direction_faced == Enums.Direction.LEFT:
		anim_tree.set("parameters/kick left/blend/blend_amount", abs(speed))
		state.travel("kick left")
	if direction_faced == Enums.Direction.RIGHT:
		anim_tree.set("parameters/kick right/blend/blend_amount", abs(speed))
		state.travel("kick right")
