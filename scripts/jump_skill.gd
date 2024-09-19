class_name JumpSkill
extends AiSkill

var basic_movement: PlayerBasicMovement

func jump() -> void:
	basic_movement.jump()


func celebration_jump() -> void:
	basic_movement.jump_with_custom_animation("celebrate")
