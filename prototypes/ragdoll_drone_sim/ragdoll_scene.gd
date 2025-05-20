extends Level

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start()
	timer.timeout.connect(toggle_ball)

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
		
	if Input.is_action_just_pressed("jump"):
		print("Space bar")
		if $ControlNode.power_on:
			$ControlNode.power_down_shield()
		else:
			$ControlNode.power_up_shield()

	var drone_pos: Vector3 = $Drone.get_mode_position()

	$Camera3D.look_at(Vector3(drone_pos.x, 0.7, drone_pos.z))

func toggle_ball() -> void:
	if $ControlNode.power_on:
		$ControlNode.power_down_shield()
	else:
		$ControlNode.power_up_shield()
	timer.start()
	
