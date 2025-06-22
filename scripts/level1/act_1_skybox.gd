extends Node3D

@export var camera_controller: CameraController
@export_range(0, 1) var parallax_factor: float = 0.01
@onready var skybox_camera: SkyBoxCamera = $BackgroundCanvas/SubViewportContainer/SubViewport/SkyBoxContainer/SkyBoxCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.camera_changed.connect(skybox_camera._on_camera_changed)
	skybox_camera.parallax_factor = parallax_factor
