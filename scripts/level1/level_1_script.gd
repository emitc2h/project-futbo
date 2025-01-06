class_name Level1Script
extends Node

@export var cut_scene_controller: CutSceneController
@export var cut_scene_player: AnimationPlayer

@onready var state: StateChart = $StateChart


func _ready() -> void:
	cut_scene_player.animation_finished.connect(_on_animation_finished)


#=======================================================
# INTRO CUTSCENE STATE
#=======================================================
func _on_intro_cutscene_state_entered() -> void:
	cut_scene_controller.enabled = false
	cut_scene_player.play("intro")


#=======================================================
# GAMEPLAY STATE
#=======================================================
func _on_gameplay_state_entered() -> void:
	cut_scene_controller.enabled = true


#=======================================================
# UTILITIES
#=======================================================

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"intro":
			state.send_event("intro cutscene to gameplay")
