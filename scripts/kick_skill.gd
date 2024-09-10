class_name KickSkill
extends AiSkill

var kick_ability: PlayerKickAbility
var basic_movement: PlayerBasicMovement

func kick(aim: Vector2) -> void:
	kick_ability.aim = aim.normalized()
	kick_ability.kick()


func kick_where_faced(upward: float) -> void:
	kick_ability.aim = Vector2(basic_movement.direction_faced, -upward)
	kick_ability.kick()
