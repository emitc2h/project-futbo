@tool
class_name AnimationStateChangeTracker
extends Node

var animation_tree: AnimationTree
var sm: AnimationNodeStateMachinePlayback

var current_node: String = ""
var current_fading_node: String = ""

@export var state_machine_path: String

signal anim_state_finished(anim_name: String)
signal anim_state_started(anim_name: String)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not self.get_parent() is AnimationTree:
		warnings.append("This node expects its parent to be an AnimationTree node.")
	else:
		var anim_tree: AnimationTree = self.get_parent() as AnimationTree
		if anim_tree.get(state_machine_path) == null:
			warnings.append("\"" + state_machine_path + "\" points to null.")
		else:
			if not anim_tree.get(state_machine_path) is AnimationNodeStateMachinePlayback:
				warnings.append("\"" + state_machine_path + "\" doesn't point to a AnimationNodeStateMachinePlayback.")
	return warnings


func _ready() -> void:
	animation_tree = self.get_parent() as AnimationTree
	sm = animation_tree.get(state_machine_path)


func _physics_process(delta: float) -> void:
	## Load the new current state machine nodes
	var new_current_node: String = sm.get_current_node()
	var new_current_fading_node: String = sm.get_fading_from_node()
	
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
