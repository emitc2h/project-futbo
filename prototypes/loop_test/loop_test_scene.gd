extends Level

@onready var drone: Drone = $Drone

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		pass
