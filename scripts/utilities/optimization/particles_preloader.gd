class_name ParticlesPreloader
extends Node3D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

var processed: bool = false

func _process(_delta: float) -> void:
	if not processed:
		processed = true
		return
		
	self.queue_free()
