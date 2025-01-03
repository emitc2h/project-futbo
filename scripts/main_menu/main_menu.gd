class_name MainMenu
extends Node3D

signal new_game


func _on_new_game_pressed() -> void:
	new_game.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()
