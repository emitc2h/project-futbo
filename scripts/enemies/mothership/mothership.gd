class_name Mothership
extends Node3D

@export var wait_till_open: float = 0.0
@export var time_scale: float = 1.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")


func _ready() -> void:
	set_time_scale(time_scale)
	await get_tree().create_timer(wait_till_open).timeout
	open()


func open() -> void:
	anim_state.travel("open")


func close() -> void:
	anim_state.travel("idle")


func set_time_scale(p_scale: float) -> void:
	anim_tree.set("parameters/close/scale/scale", p_scale)
	anim_tree.set("parameters/idle/scale/scale", p_scale)
	anim_tree.set("parameters/open/scale/scale", p_scale)
	
