class_name DroneAttack2States
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart

## States Enum
enum State {DECIDE = 0, PREPARE = 1, ACTION = 2}
var state: State = State.DECIDE

## State transition constants
const TRANS_TO_PREPARE: String = "Attack2: to prepare"
const TRANS_TO_ACTION: String = "Attack2: to action"
const TRANS_TO_DECIDE: String = "Attack2: to decide"

## Labels for available actions
const ACTION_TRACK: String = "track"
const ACTION_RAM_ATTACK: String = "ram attack"
const ACTION_BEAM_ATTACK: String = "beam attack"
const ACTION_DIVE_ATTACK: String = "dive attack"

## Available action resources
var action_behavior_trees: Dictionary[String, ActionBehaviorTreeResource] = {
	ACTION_TRACK: ResourceLoader.load("res://resources/custom/enemies/drone/actions/track.tres"),
	ACTION_RAM_ATTACK: ResourceLoader.load("res://resources/custom/enemies/drone/actions/ram_attack.tres"),
	ACTION_BEAM_ATTACK: ResourceLoader.load("res://resources/custom/enemies/drone/actions/beam_attack.tres"),
	ACTION_DIVE_ATTACK: ResourceLoader.load("res://resources/custom/enemies/drone/actions/dive_attack.tres")
}

## Behavior Tree Players
@onready var decision_bt_player: BTPlayer = $DecisionBTPlayer
@onready var pre_bt_player: BTPlayer = $PreBTPlayer
@onready var action_bt_player: BTPlayer = $ActionBTPlayer

var previous_chosen_attack: String
var _chosen_attack: String = ACTION_TRACK
var chosen_attack: String:
	get:
		return _chosen_attack
	set(value):
		previous_chosen_attack = _chosen_attack
		_chosen_attack = value


func _ready() -> void:
	## Pass along the drone attack behavior tree parameter
	decision_bt_player.behavior_tree = drone.attack_behavior_tree
	decision_bt_player.updated.connect(_on_decision_bt_player_updated)
	pre_bt_player.updated.connect(_on_pre_bt_player_updated)
	action_bt_player.updated.connect(_on_action_bt_player_updated)
	
	## Make sure the bt players are all off in the beginning
	decision_bt_player.active = false
	pre_bt_player.active = false
	action_bt_player.active = false


# decide state
#----------------------------------------
func _on_decide_state_entered() -> void:
	state = State.DECIDE
	## Run the decision tree. The outcome of the decision should set the 'chosen_attack' var
	decision_bt_player.active = true
	decision_bt_player.restart()


func _on_decide_state_exited() -> void:
	decision_bt_player.active = false


# prepare state
#----------------------------------------
func _on_prepare_state_entered() -> void:
	state = State.PREPARE
	
	pre_bt_player.behavior_tree = action_behavior_trees[chosen_attack].pre_action_tree
	pre_bt_player.active = true
	pre_bt_player.restart()


func _on_prepare_state_exited() -> void:
	pre_bt_player.active = false


# action state
#----------------------------------------
func _on_action_state_entered() -> void:
	state = State.ACTION
	
	action_bt_player.behavior_tree = action_behavior_trees[chosen_attack].action_tree
	action_bt_player.active = true
	action_bt_player.restart()


func _on_action_state_exited() -> void:
	action_bt_player.active = false


#=======================================================
# SIGNAL HANDLING
#=======================================================
func _on_decision_bt_player_updated(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_TO_PREPARE)
		BT.FAILURE:
			## This is a bad idea, and can cause an infinite loop in the same frame
			## Instead, backout of the attack state when this is all wired up
			sc.send_event(TRANS_TO_DECIDE)


func _on_pre_bt_player_updated(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_TO_ACTION)
		BT.FAILURE:
			sc.send_event(TRANS_TO_DECIDE)


func _on_action_bt_player_updated(status: int) -> void:
	match(status):
		BT.SUCCESS, BT.FAILURE:
			sc.send_event(TRANS_TO_DECIDE)
