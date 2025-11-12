class_name Character1GroundedStates
extends CharacterGroundedStates


var character1_asset: Character1Asset

func _ready() -> void:
	super._ready()
	character1_asset = character.asset as Character1Asset


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	super._on_jump_state_entered()
	character1_asset.jump(0.7)
