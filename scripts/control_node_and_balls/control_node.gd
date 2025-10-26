class_name ControlNode
extends Ball

## Overrides
var control_node_control_states: ControlNodeControlStates
var control_node_physics_states: ControlNodePhysicsStates

@export_group("Control Node State Machines")
@export var power_states: ControlNodePowerStates
@export var charge_states: ControlNodeChargeStates
@export var shield_states: ControlNodeShieldStates

@export_group("Assets")
@export var asset: ControlNodeAsset


func _ready() -> void:
	control_node_control_states = control_states as ControlNodeControlStates
	control_node_physics_states = physics_states as ControlNodePhysicsStates
	Signals.player_long_kick_ready.connect(_on_player_long_kick_ready)
	Signals.player_requests_warp.connect(_on_player_requesting_warp)


func _physics_process(_delta: float) -> void:
	## Controls here do not need to go through the player
	if Input.is_action_just_pressed("shield up"):
		shield_states.turn_on_shield()
	
	if Input.is_action_just_released("shield up"):
		shield_states.turn_off_shield()


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func long_kick(force_vector: Vector3) -> void:
	if charge_states.state == charge_states.State.LEVEL3:
		control_node_control_states.shot_vector = force_vector
		sc.send_event(control_node_control_states.TRANS_FREE_TO_SHOT)
	else:
		super.long_kick(force_vector)


func blow() -> void:
	sc.send_event(power_states.TRANS_TO_BLOW)


# Signal handling
# ===========================================
func _on_player_long_kick_ready() -> void:
	if charge_states.state == charge_states.State.LEVEL3:
		asset.magenta_wisps()


func _on_player_requesting_warp() -> void:
	if (not control_node_physics_states.state == control_node_physics_states.State.WARPING) and \
		## Warping requires the control node to be ON
		power_states.state == power_states.State.ON:
		asset.warp_out()
		await asset.warp_effect.open_warp_portal_finished
		sc.send_event(charge_states.TRANS_DISCHARGE)
		sc.send_event(power_states.TRANS_TO_OFF)
		sc.send_event(control_node_physics_states.TRANS_TO_WARPING)
