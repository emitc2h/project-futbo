class_name KickSkill
extends AiSkill

var kick_ability: PlayerKickAbility

func kick(aim: Vector2) -> void:
	kick_ability.aim = aim.normalized()
	kick_ability.kick()
