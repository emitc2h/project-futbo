extends BTAction

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	Signals.update_zoom.emit(Enums.Zoom.DEFAULT)


func _tick(delta: float) -> Status:
	return SUCCESS
