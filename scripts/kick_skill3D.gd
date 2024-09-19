class_name KickSkill3D
extends AiSkill3d

var kick_ability: PlayerKickAbility3D
var basic_movement: PlayerBasicMovement3D

func kick(aim: Vector2) -> void:
	kick_ability.aim = aim.normalized()
	kick_ability.kick()


func kick_where_faced(upward: float) -> void:
	kick_ability.aim = Vector2(basic_movement.direction_faced, -upward)
	kick_ability.kick()
