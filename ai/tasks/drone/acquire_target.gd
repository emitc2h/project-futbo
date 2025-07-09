extends BTAction

@export var time_limit: float = 0.0

var drone: Drone

var distance: float
var time_elapsed: float

func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	distance = abs(drone.face_target())
	time_elapsed = 0.0


func _tick(delta: float) -> Status:
	time_elapsed += delta
	if time_limit != 0.0 and time_elapsed > time_limit:
		return FAILURE
	
	if drone.sees_player:
		Signals.update_zoom.emit(Enums.Zoom.FAR)
		return SUCCESS
	
	if distance > 5.0:
		drone.move_toward_target(delta)
	else:
		drone.stop_moving(delta)
		
	return RUNNING
