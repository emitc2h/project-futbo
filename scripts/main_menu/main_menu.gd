class_name MainMenu
extends Node3D

signal new_game
signal load_prototype

func _ready() -> void:
	$AnimationPlayer.play("StartUp")


func _on_new_game_pressed() -> void:
	new_game.emit()


func _on_exit_pressed() -> void:
	Signals.quit_game.emit()


func _on_prototype_pressed() -> void:
	load_prototype.emit()
