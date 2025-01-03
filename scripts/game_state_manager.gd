class_name GameStateManager
extends Node3D

@onready var state: StateChart = $GameState
@onready var level_state_manager: LevelStateManager = $LevelStateManager

var active_scene: Node
var level_path: String
var loading_status_array: Array = []
var interpolated_loading_status: float = 0


func _ready() -> void:
	Signals.quit_game.connect(_on_quit_game)
	Signals.exit_to_main_menu.connect(_on_exit_to_main_menu)


#=======================================================
# MAIN MENU STATE
#=======================================================
func _on_main_menu_state_entered() -> void:
	var main_menu_scene: MainMenu = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	active_scene = main_menu_scene
	main_menu_scene.new_game.connect(_on_new_game_pressed)
	self.add_child(main_menu_scene)


func _on_new_game_pressed() -> void:
	level_path = "res://scenes/level1/act_1.tscn"
	state.send_event("main menu to loading screen")


func _on_main_menu_state_exited() -> void:
	active_scene.queue_free()


#=======================================================
# MAIN MENU STATE
#=======================================================
func _on_loading_screen_state_entered() -> void:
	var loading_screen_scene: LoadingScreen = load("res://scenes/loading_screen/loading_screen.tscn").instantiate()
	active_scene = loading_screen_scene
	self.add_child(loading_screen_scene)
	loading_status_array = []
	interpolated_loading_status = 0.0
	ResourceLoader.load_threaded_request(level_path, "PackedScene")
	

func _on_loading_screen_state_processing(delta: float) -> void:
	var loading_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(level_path, loading_status_array)
	interpolated_loading_status = lerp(interpolated_loading_status, loading_status_array[0], delta)
	active_scene.set_progress_bar_value(interpolated_loading_status)
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			state.send_event("loading screen to game")
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Loading " + level_path + " failed, exiting game.")
			get_tree().quit()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Invalid resource at path: " + level_path + ", exiting game.")
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass


func _on_loading_screen_state_exited() -> void:
	active_scene.queue_free()


#=======================================================
# GAME STATE
#=======================================================
func _on_game_state_entered() -> void:
	var level: Level = ResourceLoader.load_threaded_get("res://scenes/level1/act_1.tscn").instantiate()
	level_state_manager.open_level(level)
	active_scene = level


#=======================================================
# SIGNALS
#=======================================================
func _on_quit_game() -> void:
	get_tree().quit()


func _on_exit_to_main_menu() -> void:
	level_state_manager.close_level()
	state.send_event("game to main menu")
