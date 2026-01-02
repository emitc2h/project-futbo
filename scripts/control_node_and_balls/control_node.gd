class_name ControlNode
extends Ball

## Overrides
var control_node_control_states: ControlNodeControlStates
var control_node_physics_states: ControlNodePhysicsStates

@export_group("Control Node State Machines")
@export var power_states: ControlNodePowerStates
@export var charge_states: ControlNodeChargeStates
@export var shield_states: ControlNodeShieldStates
@export var attractor_states: ControlNodeAttractorStates

@export_group("Assets")
@export var asset: ControlNodeAsset

@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

@onready var target_marker: Marker3D = $TrackPositionContainer/TargetMarker

func _ready() -> void:
	control_node_control_states = control_states as ControlNodeControlStates
	control_node_physics_states = physics_states as ControlNodePhysicsStates
	Signals.player_long_kick_ready.connect(_on_player_long_kick_ready)
	Signals.player_requests_warp.connect(_on_player_requesting_warp)
	Signals.control_node_shield_hit.connect(_on_control_node_shield_hit)
	Signals.control_node_impulse.connect(_on_control_node_impulse)
	Representations.control_node_target_marker = target_marker


func _physics_process(_delta: float) -> void:
	## Controls here do not need to go through the player
	if Input.is_action_just_pressed("shield up"):
		shield_states.turn_on_shield()
	
	if Input.is_action_just_released("shield up"):
		shield_states.turn_off_shield()
		
	Representations.control_node_representation.global_position = get_ball_position()
	Representations.control_node_representation.velocity = get_ball_velocity()


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick(force_vector: Vector3) -> void:
	attractor_states.disable()
	super.kick(force_vector)


func long_kick(force_vector: Vector3) -> void:
	attractor_states.disable()
	if charge_states.state == charge_states.State.LEVEL3:
		control_node_control_states.shot_vector = force_vector
		sc.send_event(control_node_control_states.TRANS_FREE_TO_SHOT)
	else:
		super.long_kick(force_vector)


func blow() -> void:
	sc.send_event(power_states.TRANS_TO_BLOW)


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_player_long_kick_ready() -> void:
	if charge_states.state == charge_states.State.LEVEL3:
		asset.magenta_wisps()


func _on_player_requesting_warp() -> void:
	if (not control_node_physics_states.state == control_node_physics_states.State.WARPING) and \
		## Warping requires the control node to be ON
		power_states.state == power_states.State.ON:
		sc.send_event(charge_states.TRANS_DISCHARGE)
		sc.send_event(power_states.TRANS_TO_DISCHARGING)
		physics_states.warp()


func _on_control_node_shield_hit(one_hit: bool) -> void:
	## Check state before discharging, otherwise the state is always NONE
	if charge_states.state == charge_states.State.NONE or one_hit:
		sc.send_event(power_states.TRANS_TO_BLOW)
	else:
		charge_states.lose_charge_by_hit_anim()


func _on_control_node_impulse(impulse_vector: Vector3) -> void:
	if not shield_states.state == shield_states.State.ON:
		impulse(impulse_vector)


func _on_rigid_node_body_entered(body: Node) -> void:
	if body.is_in_group("DroneGroup"):
		attractor_states.enable()
