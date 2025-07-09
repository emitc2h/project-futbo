@tool
extends BTAction

var drone: Drone
var player_nearby: bool

func _setup() -> void:
	drone = agent as Drone
	drone.player_proximity_triggered.connect(_on_player_detected)


func _enter() -> void:
	player_nearby = false


func _tick(delta: float) -> Status:
	if agent.sees_player or player_nearby:
		Signals.update_zoom.emit(Enums.Zoom.FAR)
		return SUCCESS
	return RUNNING


func _on_player_detected() -> void:
	player_nearby = true
