extends Node3D

var faces_right: bool = true
var initial_vector: Vector3
var ivx: float
var ivz: float


func _ready() -> void:
	initial_vector = self.rotation
	ivx = initial_vector.x
	ivz = initial_vector.z


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var tween: Tween = get_tree().create_tween()
		if faces_right:
			tween.tween_property(self, "rotation", Vector3(ivx, PI, ivz), 1.0).from(initial_vector)
			faces_right = false
		else:
			tween.tween_property(self, "rotation", initial_vector, 1.0).from(Vector3(ivx, PI, ivz))
			faces_right = true
		
