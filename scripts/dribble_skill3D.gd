class_name DribbleSkill3D
extends AiSkill3d

var dribble_ability: PlayerDribbleAbility3D

func start_dribbling() -> void:
	dribble_ability.start_dribble()


func end_dribbling() -> void:
	dribble_ability.end_dribble()
