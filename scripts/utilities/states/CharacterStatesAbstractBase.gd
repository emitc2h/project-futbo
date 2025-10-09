@abstract
class_name CharacterStatesAbstractBase
extends Node

@export_group("Base Dependencies")
## The Character controlled by the Compound State machine implemented here
@export var character: CharacterBase

## The StateChart in which the Compound State resides
@export var sc: StateChart

## A direct link to the Compound State
@export var cs: CompoundState

## When more things can be made abstract (enums, vars, consts) I can flesh out this abstract class more
