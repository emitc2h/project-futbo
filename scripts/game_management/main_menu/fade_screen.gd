class_name FadeScreen
extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal fade_finished

var _stay_visible: bool = false

func _ready() -> void:
	self.hide()


func fade_in(stay_visible: bool = false) -> void:
	_stay_visible = stay_visible
	self.show()
	animation_player.play("fade in")


func fade_out(stay_visible: bool = false) -> void:
	_stay_visible = stay_visible
	self.show()
	animation_player.play("fade out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	fade_finished.emit()
	if not (_stay_visible || animation_player.is_playing()):
		self.hide()
