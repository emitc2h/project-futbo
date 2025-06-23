extends Level

var toggle: bool = false

func _ready() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(3)
	await timer.timeout
	$Drone.open()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		if toggle:
			$Drone.close()
			$Drone.become_inert()
			toggle = false
		else:
			$Drone.open()
			$Drone.start_floating()
			toggle = true
