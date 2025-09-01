class_name TargetMesh
extends StaticBody3D

var bob: bool = false
var initial_pos: Vector3
var time_passed: float = 0.0

func _ready() -> void:
	initial_pos = position
	time_passed = 0.0

func _physics_process(delta: float) -> void:
	if bob:
		time_passed += delta
		position = initial_pos + Vector3.UP * 0.8 * sin(time_passed)
