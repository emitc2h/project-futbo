extends Level

@onready var dronev2: Drone = $Drone

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		dronev2.become_ragdoll()
