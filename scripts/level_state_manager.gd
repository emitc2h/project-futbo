class_name LevelStateManager
extends Node3D

var current_level: Level = null
@onready var state: StateChart = $StateChart
@onready var pause_menu: PauseMenu = $PauseMenu

## State tracking variables
var in_cut_scene_state: bool = false


func _ready() -> void:
	pause_menu.hide
	Signals.unpause.connect(_on_unpause)


#=======================================================
# EMPTY STATE
#=======================================================
func _on_empty_state_entered() -> void:
	if current_level:
		current_level.queue_free()
	current_level = null


#=======================================================
# CUT SCENE STATE
#=======================================================
func _on_cut_scene_state_entered() -> void:
	in_cut_scene_state = true


func _on_cut_scene_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		state.send_event("cut scene to paused")


func _on_cut_scene_state_exited() -> void:
	in_cut_scene_state = false


#=======================================================
# GAME PLAY STATE
#=======================================================
func _on_game_play_state_entered() -> void:
	self.add_child(current_level)


func _on_game_play_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		state.send_event("game play to paused")


#=======================================================
# PAUSED STATE
#=======================================================
func _on_paused_state_entered() -> void:
	pause_menu.show()
	pause_menu.continue_button_grab_focus()
	get_tree().paused = true


func _on_paused_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if in_cut_scene_state:
			state.send_event("paused to cut scene")
		else:
			state.send_event("paused to game play")


func _on_paused_state_exited() -> void:
	pause_menu.hide()
	get_tree().paused = false


#=======================================================
# SIGNALS
#=======================================================
func _on_unpause() -> void:
	if in_cut_scene_state:
		state.send_event("paused to cut scene")
	else:
		state.send_event("paused to game play")



#=======================================================
# UTILITIES
#=======================================================
func open_level(level: Level) -> void:
	current_level = level
	if level.starts_with_cut_scene:
		state.send_event("empty to cut scene")
	else:
		state.send_event("empty to game play")


func close_level() -> void:
	state.send_event("paused to empty")
