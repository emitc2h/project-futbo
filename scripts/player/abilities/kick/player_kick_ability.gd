class_name PlayerKickAbility
extends Node3D

# Nodes controlled by this node
@export var player: Player
@export var enabled: bool = true

# Nodes controlled by this node
var asset: CharacterAsset

# Internal references
@onready var state: StateChart = $State
@onready var kickzone: Area3D = $KickZone
@onready var long_kickzone: Area3D = $LongKickZone
@onready var long_kick_raycast: RayCast3D = $LongKickRayCast
@onready var sprint_raycast: RayCast3D = $SprintRayCast

# Configurables
@export var kick_force: float = 7.0
@export var long_kick_force: float = 14.0

# Static/Internal properties
var kickzone_position_x: float
var long_kickzone_position_x: float
var long_kick_raycast_target_x: float
var sprint_raycast_target_x: float
var player_id: int

# Dynamic properties
var ball: Ball
var direction: Enums.Direction = Enums.Direction.RIGHT
var previous_sprite_animation: String
var is_sprinting: bool = false
var kick_button_is_pressed: bool = false

# State tracking
var is_in_ready_state: bool = false


func _enter_tree() -> void:
	Signals.facing_left.connect(_on_facing_left)
	Signals.facing_right.connect(_on_facing_right)


func _exit_tree() -> void:
	Signals.facing_left.disconnect(_on_facing_left)
	Signals.facing_right.disconnect(_on_facing_right)


# Record kickzone offset to flip the zone when the player faces left
func _ready() -> void:
	kickzone_position_x = kickzone.position.x
	long_kickzone_position_x = long_kickzone.position.x
	long_kick_raycast_target_x = long_kick_raycast.target_position.x
	sprint_raycast_target_x = sprint_raycast.target_position.x
	asset = player.asset
	player_id = player.get_instance_id()


#=======================================================
# STATES
#=======================================================

# not ready state
#----------------------------------------
func _on_not_ready_state_entered() -> void:
	ball = null


func _on_not_ready_state_physics_processing(_delta: float) -> void:
	if kick_button_is_pressed and\
	 (not long_kick_raycast.is_colliding()) and\
	 (not sprint_raycast.is_colliding()):
		state.send_event("not ready to standby")


# standby state
#----------------------------------------
func _on_standby_state_entered() -> void:
	Signals.player_long_kick_ready.emit()


func _on_standby_state_physics_processing(_delta: float) -> void:
	if not kick_button_is_pressed:
		state.send_event("standby to not ready")
	
	if long_kick_raycast.is_colliding():
		state.send_event("standby to winding up")

	if (not is_sprinting) and sprint_raycast.is_colliding():
		asset.to_sprint()
		is_sprinting = true
	
	if is_sprinting and (not sprint_raycast.is_colliding()):
		asset.reset_speed()
		is_sprinting = false


func _on_standby_state_exited() -> void:
	asset.reset_speed()


func _on_standby_to_not_ready_taken() -> void:
	asset.to_move()


# winding up state
#----------------------------------------
func _on_winding_up_state_entered() -> void:
	asset.to_long_kick()


func _on_winding_up_state_physics_processing(_delta: float) -> void:
	if not long_kick_raycast.is_colliding():
		state.send_event("winding up to standby")


func _on_winding_up_to_standby_taken() -> void:
	asset.to_move()



# ready state
#----------------------------------------
func _on_ready_state_entered() -> void:
	# Sometimes the ball leaves the kickzone before the transition to not ready can be effected
	if kickzone.get_overlapping_bodies().is_empty():
		state.send_event("ready to not ready")
	is_in_ready_state = true


func _on_ready_state_exited() -> void:
	is_in_ready_state = false


# kick state
#----------------------------------------
func _on_kick_state_entered() -> void:
	ball.kick(Aim.vector * kick_force)
	# if the kick doesn't work for some reason, stay in ready state
	# ready state will be dropped once the ball has exited the kick zone
	state.send_event("kick to ready")
	asset.to_kick()


func _on_kick_state_exited() -> void:
	pass


# long kick state
#----------------------------------------
func _on_long_kick_state_entered() -> void:
	ball.long_kick(Aim.vector * long_kick_force)
	state.send_event("long kick to standby")


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from KickZone
#----------------------------------------
func _on_kick_zone_body_entered(body: Node3D) -> void: 
	ball = body.get_parent() as Ball
	state.send_event("not ready to ready")


func _on_kick_zone_body_exited(body: Node3D) -> void:
	ball = body.get_parent() as Ball
	# prevents ball from being unkickable while dribbling, even if it falls out of the kick zone
	if player_id != ball.dribbler_id:
		state.send_event("ready to not ready")


# from LongKickZone
#----------------------------------------
func _on_long_kick_zone_body_entered(body: Node3D) -> void:
	ball = body.get_parent() as Ball
	state.send_event("winding up to long kick")

# from PlayerBasicMovement
#----------------------------------------
func _on_facing_left() -> void:
	direction = Enums.Direction.LEFT
	kickzone.position.x = -kickzone_position_x
	long_kickzone.position.x = -long_kickzone_position_x
	long_kick_raycast.target_position.x = -long_kick_raycast_target_x
	sprint_raycast.target_position.x = -sprint_raycast_target_x


func _on_facing_right() -> void:
	direction = Enums.Direction.RIGHT
	kickzone.position.x = kickzone_position_x
	long_kickzone.position.x = long_kickzone_position_x
	long_kick_raycast.target_position.x = long_kick_raycast_target_x
	sprint_raycast.target_position.x = sprint_raycast_target_x


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick() -> void:
	if not enabled:
		return
	# If the ball is already in the kick zone, kick it
	state.send_event("ready to kick")
	Signals.kicked.emit()


func kick_button_pressed() -> void:
	kick_button_is_pressed = true


func kick_button_released() -> void:
	kick_button_is_pressed = false
