class_name LoadingScreen
extends CanvasLayer

@onready var progress_bar: ProgressBar = $ColorRect/VBoxContainer/ProgressBar

func set_progress_bar_value(value: float) -> void:
	progress_bar.value = value * 100
