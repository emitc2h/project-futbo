class_name Main
extends Node3D

@onready var state: StateChart = $GameState
var active_scene: Node


func _on_main_menu_state_entered() -> void:
	var main_menu_scene: MainMenu = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	active_scene = main_menu_scene
	main_menu_scene.new_game.connect(_on_new_game_pressed)
	self.add_child(main_menu_scene)


func _on_new_game_pressed() -> void:
	state.send_event("main menu to new game")


func _on_main_menu_state_exited() -> void:
	active_scene.queue_free()


func _on_game_state_entered() -> void:
	var act1_scene: Node3D = load("res://scenes/act1/act_1.tscn").instantiate()
	self.add_child(act1_scene)
	active_scene = act1_scene
