extends Node3D

@onready var label: Label = $CanvasLayer/Label
var time_elapsed: float = 0.0


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	$AnimationPlayer.play("test_animation")


func _process(delta: float) -> void:
	time_elapsed += delta
	label.text = str(snapped(time_elapsed, 0.01)) + "s"
