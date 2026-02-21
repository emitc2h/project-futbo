class_name ScoutEngagementStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var asset: ScoutAsset

## States Enum
enum State {CLOSED = 0, OPENING = 1, QUICK_OPEN = 2, OPEN = 3, CLOSING = 4, QUICK_CLOSE = 5}
var state: State = State.CLOSED

## State transition constants
const TRANS_TO_CLOSED: String = "Engagement: to closed"
const TRANS_TO_OPENING: String = "Engagement: to opening"
const TRANS_TO_QUICK_OPEN: String = "Engagement: to quick open"
const TRANS_TO_OPEN: String = "Engagement: to open"
const TRANS_TO_CLOSING: String = "Engagement: to closing"
const TRANS_TO_QUICK_CLOSE: String = "Engagement: to quick close"

## Signals
signal open_finished
signal quick_open_finished
signal close_finished
signal quick_close_finished


func _ready() -> void:
	asset.anim_state_started.connect(_on_anim_state_started)


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	state = State.CLOSED


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	state = State.OPENING
	asset.anim_state.travel("open")


func _on_opening_state_exited() -> void:
	open_finished.emit()


# quick open state
#----------------------------------------
func _on_quick_open_state_entered() -> void:
	state = State.QUICK_OPEN
	asset.anim_state.travel("quick open")


func _on_quick_open_state_exited() -> void:
	quick_open_finished.emit()


# open state
#--------------------------------------
func _on_open_state_entered() -> void:
	state = State.OPEN


# closing state
#--------------------------------------
func _on_closing_state_entered() -> void:
	state = State.CLOSING
	asset.anim_state.travel("close")


func _on_closing_state_exited() -> void:
	close_finished.emit()


# quick close state
#--------------------------------------
func _on_quick_close_state_entered() -> void:
	state = State.QUICK_CLOSE
	asset.anim_state.travel("quick close")


func _on_quick_close_state_exited() -> void:
	quick_close_finished.emit()


# signal handling
#========================================
func _on_anim_state_started(anim_name: String) -> void:
	if anim_name == "idle":
		sc.send_event(TRANS_TO_OPEN)
	
	if anim_name == "closed":
		sc.send_event(TRANS_TO_CLOSED)
