class_name SeekSkill
extends Node

var player: Player2
var player_basic_movement: PlayerBasicMovement

# Constants
const STOP_SEEKING_DISTANCE: float = 15.0


func distance_to_target(target_position: Vector2) -> float:
	return abs(target_position.x - player.global_position.x)
	

# Uses global positions
func seek_target(target_position: Vector2) -> void:
	var direction_to_target: float = sign(target_position.x - player.global_position.x)
	if distance_to_target(target_position) > STOP_SEEKING_DISTANCE:
		player_basic_movement.run(direction_to_target)
	else:
		player_basic_movement.run(0.0)
