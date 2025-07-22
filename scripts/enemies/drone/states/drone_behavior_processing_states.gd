class_name BehaviorProcessingStates
extends Node

@export var drone: Drone
@export var sc: StateChart
@export var bt: BTPlayer
@export var timers: Array[Timer]

enum State {PROCESSING = 0, INTERRUPTED_BY_QUICK_CLOSE = 1}
var state: State

@onready var interrupted_by_quick_close_timer: Timer = $InterruptedByQuickCloseTimer


func _ready() -> void:
	drone.control_node_proximity_triggered.connect(_on_control_node_proximity_triggered)
	drone.opening_finished.connect(_on_opening_finished)


#=======================================================
# STATES
#=======================================================

# processing state
#----------------------------------------
func _on_processing_state_entered() -> void:
	print("processing state entered")
	state = State.PROCESSING
	bt.active = true
	for timer in timers:
		timer.paused = false


func _on_processing_state_exited() -> void:
	bt.active = false
	for timer in timers:
		timer.paused = true


# interrupted states
#----------------------------------------
func _on_interrupted_state_processing(delta: float) -> void:
	drone.stop_moving(delta)


# interrupted by quick close state
#----------------------------------------
func _on_interrupted_by_quick_close_state_entered() -> void:
	print("interrupted by quick close state entered")
	state = State.INTERRUPTED_BY_QUICK_CLOSE
	interrupted_by_quick_close_timer.start()


func _on_interrupted_by_quick_close_state_exited() -> void:
	print("interrupted by quick close state exited")
	interrupted_by_quick_close_timer.stop()


#=======================================================
# SIGNAL HANDLING
#=======================================================

# interrupted by quick close state
#----------------------------------------

# interruption event
func _on_control_node_proximity_triggered() -> void:
	print("control node proximity triggered")
	if state == State.PROCESSING:
		sc.send_event("processing to interrupted by quick close")
		drone.quick_close()

# interruption resolution
func _on_interrupted_by_quick_close_timer_timeout() -> void:
	print("interrupted by quick close timer timeout")
	interrupted_by_quick_close_timer.stop()
	drone.open()

# returning to processing condition
func _on_opening_finished() -> void:
	print("opening finished")
	sc.send_event("interrupted by quick close to processing")
