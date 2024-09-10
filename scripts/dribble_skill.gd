class_name DribbleSkill
extends AiSkill

var dribble_ability: PlayerDribbleAbility

func start_dribbling() -> bool:
	dribble_ability.start_dribble()
	return dribble_ability.is_dribbling


func end_dribbling() -> void:
	dribble_ability.end_dribble()
