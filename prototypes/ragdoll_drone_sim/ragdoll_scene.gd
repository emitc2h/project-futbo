extends Level

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		print("press W")
		$Drone.become_inert()
		
	if Input.is_action_just_pressed("dribble"):
		print("press Q")
		$Drone.start_floating()
		
	if Input.is_action_just_pressed("kick"):
		print("press E")
		$Drone.become_ragdoll()
		
	if Input.is_action_just_pressed("move_down"):
		print("press S")
		$Drone.close()
		
	if Input.is_action_just_pressed("move_left"):
		print("press A")
		$Drone.open()
		
	if Input.is_action_just_pressed("move_right"):
		print("press D")
		$Drone.reset_position()

	var drone_pos: Vector3 = $Drone.get_mode_position()

	$Camera3D.look_at(Vector3(drone_pos.x, 0.5, drone_pos.z))
