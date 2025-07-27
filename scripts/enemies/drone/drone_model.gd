class_name DroneModel
extends Node3D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback

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

var current_node: String = ""
var current_fading_node: String = ""

func _ready() -> void:
	anim_state = anim_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	var new_current_node: String = anim_state.get_current_node()
	var new_current_fading_node: String = anim_state.get_fading_from_node()
	
	if new_current_node != current_node:
		## When the outgoing animation doesn't have a crossfade
		if new_current_fading_node == "":
			anim_state_finished.emit(current_node)
		
		anim_state_started.emit(new_current_node)
		
	current_node = new_current_node
	
	## When the outgoing animation has a crossfade
	if current_fading_node != "" and new_current_fading_node == "":
		anim_state_finished.emit(current_fading_node)
	current_fading_node = new_current_fading_node
