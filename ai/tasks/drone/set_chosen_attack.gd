@tool
class_name SetChosenAttack
extends BTAction

var drone: Drone

@export_enum(
	drone.behavior_attack2_states.ACTION_TRACK,
	drone.behavior_attack2_states.ACTION_RAM_ATTACK,
	drone.behavior_attack2_states.ACTION_BEAM_ATTACK,
	drone.behavior_attack2_states.ACTION_DIVE_ATTACK) var chosen_action: String


func _generate_name() -> String:
	return "Set chosen action to " + chosen_action


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	drone.behavior_attack2_states.chosen_attack = chosen_action


func _tick(_delta: float) -> Status:
	return SUCCESS
