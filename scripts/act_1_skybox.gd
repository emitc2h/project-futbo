extends Node3D

@export var camera_controller: CameraController
@onready var skybox_camera: SkyBoxCamera = $BackgroundCanvas/SubViewportContainer/SubViewport/SkyBoxCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_controller.camera_rotated.connect(skybox_camera._on_camera_rotated)
