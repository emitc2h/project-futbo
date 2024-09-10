class_name SeekSkill
extends AiSkill

var basic_movement: PlayerBasicMovement

# Constants
const STOP_SEEKING_DISTANCE: float = 15.0

# Uses global positions
func seek_target(target_position: Vector2) -> void:
	var direction_to_target: float = sign(target_position.x - player.global_position.x)
	if distance_to_target(target_position) > STOP_SEEKING_DISTANCE:
		basic_movement.run(direction_to_target)
	else:
		stop_seeking()


func stop_seeking() -> void:
	basic_movement.run(0.0)
