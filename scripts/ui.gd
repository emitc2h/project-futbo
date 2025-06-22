class_name Ui
extends CanvasLayer


@export var camera_controller: CameraController
@export var player: Player3D
@export var stamina_offset: Vector2

@onready var score_left: Label = $ScoreLeft
@onready var score_right: Label = $ScoreRight
@onready var stamina_bar: TextureProgressBar = $StaminaProgressBar

var camera: Camera3D

func _ready() -> void:
	camera = camera_controller.camera
	stamina_bar.visible = false
	Signals.display_stamina.connect(_on_display_stamina)
	Signals.hide_stamina.connect(_on_hide_stamina)
	Signals.update_stamina_value.connect(_on_update_stamina_value)


func set_score_left(score: int) -> void:
	$ScoreLeft.text = str(score)
	

func set_score_right(score: int) -> void:
	$ScoreRight.text = str(score)


func _process(delta: float) -> void:
	stamina_bar.position = camera.unproject_position(player.position) + stamina_offset


func _on_display_stamina(color: Color) -> void:
	stamina_bar.visible = true
	stamina_bar.tint_progress = color


func _on_hide_stamina() -> void:
	stamina_bar.visible = false


func _on_update_stamina_value(value: float) -> void:
	stamina_bar.value = value * 100
