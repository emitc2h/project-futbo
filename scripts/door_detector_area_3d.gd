extends Area3D

@export var door_animation_player: AnimationPlayer
var door_opening_timer: Timer
var state: StateChart


func _ready() -> void:
	door_opening_timer = $DoorOpeningTimer
	state = $StateChart
	door_animation_player.stop()
	door_animation_player.animation_finished.connect(_on_animation_finished)


#=======================================================
# STATES
#=======================================================

# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	door_animation_player.stop()


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	door_animation_player.play("DoorAction")
	door_opening_timer.start()


# opened state
#----------------------------------------
func _on_opened_state_entered() -> void:
	door_animation_player.pause()


# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	door_opening_timer.stop()
	door_animation_player.play("DoorAction")


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from Door Area3D
#----------------------------------------
func _on_body_entered(body: Node3D) -> void:
	# The player is near the door, open them
	state.send_event("closed to opening")


func _on_body_exited(body: Node3D) -> void:
	# start the action of closing the door:
	#   1. if the player was in the door, resume the animation and let it finish
	#   2. if the player blasted through the door and exited before the door was fully opened,
	#      don't pause the animation and let it finish
	state.send_event("opened to closing")
	state.send_event("opening to closing")


# from Animation Player
#----------------------------------------
func _on_animation_finished(_name: String) -> void:
	# When the animation is finished, the doors are closed, enter the closed state
	state.send_event("closing to closed")


# from Door Opening Timer
#----------------------------------------
func _on_door_opening_timer_timeout() -> void:
	# The door is fully opened at 0.9s. If the player is still in the door, pause.
	state.send_event("opening to opened")
