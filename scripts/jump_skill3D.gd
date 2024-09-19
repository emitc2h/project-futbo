class_name JumpSkill3D
extends AiSkill3d

var basic_movement: PlayerBasicMovement3D

func jump() -> void:
	basic_movement.jump()


func celebration_jump() -> void:
	basic_movement.jump_with_custom_animation("celebrate")
