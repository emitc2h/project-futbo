extends BTAction

var drone: Drone

func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	blackboard.set_var("drone_x_position", drone.get_mode_position().x)
	blackboard.set_var("target_x_position", drone.target.global_position.x)


func _tick(delta: float) -> Status:
	drone.disable_targeting()
	return SUCCESS
