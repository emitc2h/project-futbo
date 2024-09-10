class_name DribbleSkill
extends AiSkill

var dribble_ability: PlayerDribbleAbility

func start_dribbling() -> void:
	dribble_ability.start_dribble()


func end_dribbling() -> void:
	dribble_ability.end_dribble()
