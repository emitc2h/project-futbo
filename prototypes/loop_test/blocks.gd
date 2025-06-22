extends Node3D

var faces_right: bool = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var tween: Tween = get_tree().create_tween()
		if faces_right:
			tween.tween_property(self, "rotation", Vector3(0.0, PI, 0.0), 1.0).from(Vector3.ZERO)
			faces_right = false
		else:
			tween.tween_property(self, "rotation", Vector3.ZERO, 1.0).from(Vector3(0.0, PI, 0.0))
			faces_right = true
		
