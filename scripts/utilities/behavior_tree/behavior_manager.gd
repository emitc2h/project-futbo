@tool
class_name BehaviorManager
extends Node

@export var reset_tree_on_enter: bool = true

@onready var btplayer: BTPlayer = $BTPlayer
@onready var pre_btplayer: BTPlayer = $PreBTPlayer

signal finished(status: int)


## Check whether the Behavior Manager has a BTPlayer node
func _get_configuration_warnings() -> PackedStringArray:
	
	## Check that the BehaviorManager has a BTPlayer node
	var has_bt_player: bool = false
	var has_pre_bt_player: bool = false
	var warnings: PackedStringArray = []
	for child in get_children():
		if child is BTPlayer and child.name == "BTPlayer":
			has_bt_player = true
		if child is BTPlayer and child.name == "PreBTPlayer":
			has_pre_bt_player = true
	
	if not has_bt_player:
		warnings.append("BehaviorManager needs a BTPlayer child named BTPlayer.")
	
	if not has_pre_bt_player:
		warnings.append("BehaviorManager needs a BTPlayer child named PreBTPlayer.")
	
	## Check that the parent node is an Atomic State
	if not get_parent() is AtomicState:
		warnings.append("BehaviorManager should be a child of an AtomicState.")
	
	return warnings


func _ready() -> void:
	btplayer.active = false
	pre_btplayer.active = false
	
	btplayer.behavior_tree_finished.connect(_on_bt_finished)
	pre_btplayer.behavior_tree_finished.connect(_on_pre_bt_player_finished)
	
	var state: AtomicState = get_parent() as AtomicState
	state.state_entered.connect(_on_behavior_entered)
	state.state_exited.connect(_on_behavior_exited)


func _on_behavior_entered() -> void:
	pre_btplayer.active = true
	pre_btplayer.restart()


func _on_behavior_exited() -> void:
	btplayer.active = false
	

func _on_bt_finished(status: int) -> void:
	finished.emit(status)


func _on_pre_bt_player_finished(_status: int) -> void:
	pre_btplayer.active = false
	btplayer.active = true
	if reset_tree_on_enter:
		btplayer.restart()
