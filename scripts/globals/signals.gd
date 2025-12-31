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
signal player_moved

@warning_ignore("unused_signal")
signal display_stamina(color: Color)
@warning_ignore("unused_signal")
signal hide_stamina
@warning_ignore("unused_signal")
signal update_stamina_value(value: float)

@warning_ignore("unused_signal")
signal aim_vector_updated(vec: Vector3)

@warning_ignore("unused_signal")
signal active_dribble_marker_position_updated(pos: Vector3)
@warning_ignore("unused_signal")
signal player_velocity_updated(vel: Vector3)

@warning_ignore("unused_signal")
signal dribbling_entered
@warning_ignore("unused_signal")
signal dribbling_exited
@warning_ignore("unused_signal")
signal idle_entered
@warning_ignore("unused_signal")
signal idle_exited

@warning_ignore("unused_signal")
signal player_takes_damage(obj_velocity: Vector3, obj_position: Vector3, physical: bool)

@warning_ignore("unused_signal")
signal player_long_kick_ready

@warning_ignore("unused_signal")
signal player_requests_warp
@warning_ignore("unused_signal")
signal player_update_destination(pos: Vector3)

@warning_ignore("unused_signal")
signal player_shield_taking_charges(num_charges_taken: int)

@warning_ignore("unused_signal")
signal player_dead


## ===================================== ##
## CONTROL NODE SIGNALS                  ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal updated_control_node_charge_level(level: ControlNodeChargeStates.State)
@warning_ignore("unused_signal")
signal control_node_is_charged
@warning_ignore("unused_signal")
signal control_node_is_discharged
@warning_ignore("unused_signal")
signal control_node_shield_hit(one_hit: bool)
@warning_ignore("unused_signal")
signal control_node_requests_destination
@warning_ignore("unused_signal")
signal control_node_shield_dissipating(available_charges: int)
@warning_ignore("unused_signal")
signal control_node_impulse(vector: Vector3)
@warning_ignore("unused_signal")
signal control_node_attractor(destination: Vector3, delta: float)


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
signal debug_pause
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


## ===================================== ##
## ENEMIES SIGNALS                       ##
## ------------------------------------- ##
@warning_ignore("unused_signal")
signal drone_died
