@tool
class_name BehaviorManager
extends Node

@export var reset_tree_on_enter: bool = true

@onready var btplayer: BTPlayer = $BTPlayer

signal finished(status: int)


## Check whether the Behavior Manager has a BTPlayer node
func _get_configuration_warnings() -> PackedStringArray:
	
	## Check that the BehaviorManager has a BTPlayer node
	var has_bt_player: bool = false
	var warnings: PackedStringArray = []
	for child in get_children():
		if child is BTPlayer and child.name == "BTPlayer":
			has_bt_player = true
	
	if not has_bt_player:
		warnings.append("BehaviorManager needs a BTPlayer child named BTPlayer.")
	
	## Check that the parent node is an Atomic State
	if not get_parent() is AtomicState:
		warnings.append("BehaviorManager should be a child of an AtomicState.")
	
	return warnings


func _ready() -> void:
	btplayer.active = false
	btplayer.updated.connect(_on_bt_updated)
	
	var state: AtomicState = get_parent() as AtomicState
	state.state_entered.connect(_on_behavior_entered)
	state.state_exited.connect(_on_behavior_exited)


func _on_behavior_entered() -> void:
	if not btplayer.behavior_tree:
		finished.emit(BT.SUCCESS)
		return
	btplayer.active = true
	btplayer.restart()


func _on_behavior_exited() -> void:
	btplayer.active = false
	

func _on_bt_updated(status: int) -> void:
	match(status):
		BT.FAILURE, BT.SUCCESS:
			finished.emit(status)
