class_name Level1Script
extends Node3D

@export_group("Cut Scenes")
@export var control_suppressor: ControlSuppressor
@export var cut_scene_player: AnimationPlayer
@export var cut_scene_context_player: AnimationPlayer

@export_group("Main Player")
@export var player: Player

@export_group("Opponent Player")
@export var opponent_ai: AI
@export var opponent_dialog_bubble: DialogBubble

@onready var state: StateChart = $StateChart

var _path: CharacterPath = null

func _ready() -> void:
	cut_scene_player.animation_finished.connect(_on_cut_scene_player_animation_finished)


#=======================================================
# INTRO CUTSCENE STATE
#=======================================================
func _on_intro_cutscene_state_entered() -> void:
	control_suppressor.enabled = true
	cut_scene_player.play("intro")


func _on_intro_cutscene_state_processing(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		state.send_event("intro cutscene to walk to field")


func _on_intro_cutscene_state_exited() -> void:
	cut_scene_player.seek(cut_scene_player.current_animation_length)


#=======================================================
# WALK TO FIELD STATE
#=======================================================
func _on_walk_to_field_state_entered() -> void:
	control_suppressor.enabled = false


#=======================================================
# GO AROUND GOAL STATE
#=======================================================
func _on_go_around_goal_state_exited() -> void:
	_path.enabled = false


#=======================================================
# GAMEPLAY STATE
#=======================================================
func _on_gameplay_state_entered() -> void:
	opponent_dialog_bubble.pop_up("Hey! There you are!\nLet me go get the ball!")
	await opponent_dialog_bubble.finished
	opponent_ai.behaviors.state.send_event("disabled to seek")


#=======================================================
# GAME OVER STATE
#=======================================================
func _on_game_over_state_entered() -> void:
	control_suppressor.enabled = true
	Signals.game_over.emit()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_trigger_game_over_area_3d_body_entered(body: Node3D) -> void:
	state.send_event("walk to field to game over")
	state.send_event("gameplay to game over")


func _on_walk_to_field_path_3d_in_path(path: CharacterPath) -> void:
	_path = path
	state.send_event("walk to field to go around goal")
	player.get_on_path(path)


func _on_walk_to_field_path_3d_leave_by_enter() -> void:
	player.get_off_path()


func _on_walk_to_field_path_3d_leave_by_exit() -> void:
	state.send_event("go around goal to gameplay")
	player.get_off_path()


#=======================================================
# UTILITIES
#=======================================================
func _on_cut_scene_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"intro":
			state.send_event("intro cutscene to walk to field")
