class_name ForceUpdatePlayerPosAction
extends BTAction

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.force_update_player_pos_x():
		return SUCCESS
	return FAILURE
