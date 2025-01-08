class_name GameOverScreen
extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal game_over_animation_finished

func play_game_over() -> void:
	animation_player.play("game over")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	game_over_animation_finished.emit()
