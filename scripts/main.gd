class_name Main
extends Node3D

@onready var state: StateChart = $GameState
var active_scene: Node
var scene_to_load_path: String
var loading_status_array: Array = []
var interpolated_loading_status: float = 0


func _on_main_menu_state_entered() -> void:
	var main_menu_scene: MainMenu = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	active_scene = main_menu_scene
	main_menu_scene.new_game.connect(_on_new_game_pressed)
	self.add_child(main_menu_scene)


func _on_new_game_pressed() -> void:
	scene_to_load_path = "res://scenes/act1/act_1.tscn"
	state.send_event("main menu to loading screen")


func _on_main_menu_state_exited() -> void:
	active_scene.queue_free()


func _on_loading_screen_state_entered() -> void:
	var loading_screen_scene: LoadingScreen = load("res://scenes/loading_screen/loading_screen.tscn").instantiate()
	active_scene = loading_screen_scene
	self.add_child(loading_screen_scene)
	loading_status_array = []
	interpolated_loading_status = 0.0
	ResourceLoader.load_threaded_request(scene_to_load_path, "PackedScene")
	

func _on_loading_screen_state_processing(delta: float) -> void:
	var loading_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_to_load_path, loading_status_array)
	interpolated_loading_status = lerp(interpolated_loading_status, loading_status_array[0], delta)
	active_scene.set_progress_bar_value(interpolated_loading_status)
	match loading_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			state.send_event("loading screen to game")


func _on_loading_screen_state_exited() -> void:
	active_scene.queue_free()


func _on_game_state_entered() -> void:
	var act1_scene: Node3D = load("res://scenes/act1/act_1.tscn").instantiate()
	self.add_child(act1_scene)
	active_scene = act1_scene
