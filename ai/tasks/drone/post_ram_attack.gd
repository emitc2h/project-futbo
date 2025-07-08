extends BTAction

var drone: Drone

func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	drone.start_floating()
	drone.open()
	return SUCCESS
