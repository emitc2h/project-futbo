extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("Closed")
	$AnimationPlayer2.play("IdleFloating")

func open_up() -> void:
	$AnimationPlayer.play("OpenUp")

func close_up() -> void:
	$AnimationPlayer.play_backwards("OpenUp")
