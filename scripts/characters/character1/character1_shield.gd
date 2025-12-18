class_name CharacterShield
extends Node

@export var asset: Character1Asset
@export var character: CharacterBase

enum State {OFF = 0, LEVEL_1 = 1 , LEVEL_2 = 2 , LEVEL_3 = 3}
var _state: State = State.OFF
var state: State:
	get:
		return _state
	set(value):
		_state = value
		if character and character.is_player:
			Representations.player_representation.personal_shield_charges = state


func _ready() -> void:
	Signals.control_node_shield_dissipating.connect(_on_control_node_shield_dissipating)


func increment() -> void:
	match(state):
		State.OFF:
			state = State.LEVEL_1
			asset.shield_anim_player.play("state - on - charge level 0")
		State.LEVEL_1:
			state = State.LEVEL_2
			asset.shield_anim_player.play("state - on - charge level 1")
		State.LEVEL_2:
			state = State.LEVEL_3
			asset.shield_anim_player.play("state - on - charge level 2")
		State.LEVEL_3:
			pass


func decrement() -> void:
	match(state):
		State.OFF:
			pass
		State.LEVEL_1:
			asset.shield_anim_player.play("transition - hit - charge level 0")
			state = State.OFF
		State.LEVEL_2:
			asset.shield_anim_player.play("transition - hit - charge level 1")
			state = State.LEVEL_1
		State.LEVEL_3:
			asset.shield_anim_player.play("transition - hit - charge level 2")
			state = State.LEVEL_2


## Returns a boolean indicating whether the shield itself took the hit or not
func take_single_hit() -> bool:
	if state > 0:
		decrement()
		return true
	return false


func _on_control_node_shield_dissipating(available_charges: int) -> void:
	var num_charges_taken: int = available_charges - (state as int)
	if num_charges_taken > 0:
		for i in num_charges_taken:
			increment()
		Signals.player_shield_taking_charges.emit(num_charges_taken)
