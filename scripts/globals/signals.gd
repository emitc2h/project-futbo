extends Node

## ===================================== ##
## GAME STATE SIGNALS                    ##
## ------------------------------------- ##
# Tell the game to quit.
@warning_ignore("unused_signal")
signal quit_game

# Tell the GameStateManager to go back to the main menu.
@warning_ignore("unused_signal")
signal exit_to_main_menu

# Tell the GameStateManager when the game is over.
@warning_ignore("unused_signal")
signal game_over

# Tell the LevelStateManager to pause the game.
@warning_ignore("unused_signal")
signal pause

# Tell the LevelStateManager to un-pause the game.
@warning_ignore("unused_signal")
signal unpause


## ===================================== ##
## PLAYER SIGNALS                        ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal facing_left
@warning_ignore("unused_signal")
signal facing_right

@warning_ignore("unused_signal")
signal display_stamina(color: Color)
@warning_ignore("unused_signal")
signal hide_stamina
@warning_ignore("unused_signal")
signal update_stamina_value(value: float)

@warning_ignore("unused_signal")
signal started_sprinting
@warning_ignore("unused_signal")
signal ended_sprinting

@warning_ignore("unused_signal")
signal kicked

@warning_ignore("unused_signal")
signal aim_vector_updated(vec: Vector3)

@warning_ignore("unused_signal")
signal active_dribble_marker_position_updated(pos: Vector3)
@warning_ignore("unused_signal")
signal player_velocity_updated(vel: Vector3)

@warning_ignore("unused_signal")
signal jump_left_animation_ended
@warning_ignore("unused_signal")
signal jump_right_animation_ended
@warning_ignore("unused_signal")
signal turn_left_animation_ended
@warning_ignore("unused_signal")
signal turn_right_animation_ended
@warning_ignore("unused_signal")
signal kick_left_animation_ended
@warning_ignore("unused_signal")
signal kick_right_animation_ended

@warning_ignore("unused_signal")
signal player_knocked(obj_velocity: Vector3, obj_position: Vector3)

@warning_ignore("unused_signal")
signal player_long_kick_ready


## ===================================== ##
## CONTROL NODE SIGNALS                  ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal updated_control_node_charge_level(level: ControlNodeChargeStates.State)
@warning_ignore("unused_signal")
signal control_node_is_charged
@warning_ignore("unused_signal")
signal control_node_is_discharged


## ===================================== ##
## CAMERA SIGNALS                        ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal camera_changed(rotation: Vector3, position_delta: Vector3, fov: float)
@warning_ignore("unused_signal")
signal update_zoom(zoom_target: Enums.Zoom)


## ===================================== ##
## DEBUG SIGNALS                         ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal debug_log(text: String)
@warning_ignore("unused_signal")
signal debug_running_log(text: String)
@warning_ignore("unused_signal")
signal debug_advance
@warning_ignore("unused_signal")
signal debug_on
@warning_ignore("unused_signal")
signal debug_off
