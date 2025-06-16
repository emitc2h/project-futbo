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

signal jump_left_animation_ended
signal jump_right_animation_ended
signal turn_left_animation_ended
signal turn_right_animation_ended
signal kick_left_animation_ended
signal kick_right_animation_ended

## ===================================== ##
## CAMERA SIGNALS                        ##
## ------------------------------------- ##

signal camera_changed(rotation: Vector3, position_delta: Vector3, fov: float)
