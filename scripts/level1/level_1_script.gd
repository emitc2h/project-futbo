class_name Level1Script
extends Node3D

@export var control_suppressor: ControlSuppressor
@export var cut_scene_player: AnimationPlayer
@export var opponent_ai: AI

@onready var state: StateChart = $StateChart


func _ready() -> void:
	cut_scene_player.animation_finished.connect(_on_animation_finished)


#=======================================================
# INTRO CUTSCENE STATE
#=======================================================
func _on_intro_cutscene_state_entered() -> void:
	control_suppressor.enabled = true
	cut_scene_player.play("intro")


#=======================================================
# WALK TO FIELD STATE
#=======================================================
func _on_walk_to_field_state_entered() -> void:
	print("walk to field state entered")
	control_suppressor.enabled = false


func _on_trigger_gameplay_area_3d_body_entered(body: Node3D) -> void:
	state.send_event("walk to field to gameplay")


#=======================================================
# GAMEPLAY STATE
#=======================================================
func _on_gameplay_state_entered() -> void:
	opponent_ai.behaviors.state.send_event("disabled to idle")


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_trigger_game_over_area_3d_body_entered(body: Node3D) -> void:
	state.send_event("walk to field to game over")
	state.send_event("gameplay to game over")


#=======================================================
# UTILITIES
#=======================================================
func _on_animation_finished(anim_name: StringName) -> void:
	print("animation finished: ", anim_name)
	match anim_name:
		"intro":
			print("moving on to walk to field")
			state.send_event("intro cutscene to walk to field")
