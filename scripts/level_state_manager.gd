class_name LevelStateManager
extends Node3D

var current_level: Level = null
@onready var state: StateChart = $StateChart
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_screen: GameOverScreen = $GameOverScreen

signal back_to_main_menu

func _ready() -> void:
	pause_menu.hide
	Signals.unpause.connect(_on_unpause)
	Signals.game_over.connect(_on_game_over)
	game_over_screen.game_over_animation_finished.connect(_on_game_over_animation_finished)


#=======================================================
# EMPTY STATE
#=======================================================
func _on_empty_state_entered() -> void:
	if current_level:
		current_level.queue_free()
	current_level = null


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
		state.send_event("paused to game play")


func _on_paused_state_exited() -> void:
	pause_menu.hide()
	get_tree().paused = false


#=======================================================
# GAME OVER STATE
#=======================================================
func _on_game_over_state_entered() -> void:
	game_over_screen.play_game_over()


#=======================================================
# SIGNALS
#=======================================================
func _on_unpause() -> void:
	state.send_event("paused to game play")


func _on_game_over() -> void:
	state.send_event("game play to game over")


func _on_game_over_animation_finished() -> void:
	back_to_main_menu.emit()
	state.send_event("game over to empty")


#=======================================================
# UTILITIES
#=======================================================
func open_level(level: Level) -> void:
	current_level = level
	state.send_event("empty to game play")


func close_level() -> void:
	state.send_event("paused to empty")


func hide_game_over_screen() -> void:
	game_over_screen.hide()
