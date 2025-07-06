@tool
extends BTAction

@export var text: String

func _tick(delta: float) -> Status:
	print(text)
	return RUNNING
