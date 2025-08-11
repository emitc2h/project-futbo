extends Node

## ===================================== ##
## GAME STATE SIGNALS                    ##
## ------------------------------------- ##
# Tell the game to quit.
signal quit_game

# Tell the GameStateManager to go back to the main menu.
signal exit_to_main_menu

# Tell the GameStateManager when the game is over.
signal game_over

# Tell the LevelStateManager to pause the game.
signal pause

# Tell the LevelStateManager to un-pause the game.
signal unpause


## ===================================== ##
## PLAYER SIGNALS                        ##
## ------------------------------------- ##
signal facing_left
signal facing_right

signal display_stamina(color: Color)
signal hide_stamina
signal update_stamina_value(value: float)

signal started_sprinting
signal ended_sprinting

signal kicked

signal aim_vector_updated(vec: Vector3)

signal active_dribble_marker_position_updated(pos: Vector3)
signal player_velocity_updated(vel: Vector3)

signal jump_left_animation_ended
signal jump_right_animation_ended
signal turn_left_animation_ended
signal turn_right_animation_ended
signal kick_left_animation_ended
signal kick_right_animation_ended

signal player_knocked(obj_velocity: Vector3, obj_position: Vector3)


## ===================================== ##
## CAMERA SIGNALS                        ##
## ------------------------------------- ##
signal camera_changed(rotation: Vector3, position_delta: Vector3, fov: float)
signal update_zoom(zoom_target: Enums.Zoom)


## ===================================== ##
## DEBUG SIGNALS                         ##
## ------------------------------------- ##
signal debug_log(text: String)
signal debug_running_log(text: String)
signal debug_advance
