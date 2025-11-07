class_name ControlNodePowerStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var control_node: ControlNode
@export var asset: ControlNodeAsset
@export var sc: StateChart
@export var direction_ray: DirectionRay
@export var rigid_node: InertNode
var physics_material: PhysicsMaterial

## States Enum
enum State {OFF = 0, CHARGING = 1, ON = 2, DISCHARGING = 3, BLOW = 4}
var state: State = State.OFF

## State transition constants
const TRANS_TO_CHARGING: String = "Power: to charging"
const TRANS_TO_ON: String = "Power: to on"
const TRANS_TO_DISCHARGING: String = "Power: to discharging"
const TRANS_TO_OFF: String = "Power: to off"
const TRANS_TO_BLOW: String = "Power: to blow"

## Animation constants
const OFF_STATE_ANIM: String = "state - power off - emitters off"

const CHARGING_TRANS_ANIM: String = "transition - power off to on"

const ON_STATE_ANIM: String = "state - power on - charge level 0"

const DISCHARGING_TRANS_ANIM: String = "transition - power on to off"

const BLOW_LEVEL_0_TRANS_ANIM: String = "transition - blow - charge level 0"
const BLOW_LEVEL_1_TRANS_ANIM: String = "transition - blow - charge level 1"
const BLOW_LEVEL_2_TRANS_ANIM: String = "transition - blow - charge level 2"
const BLOW_LEVEL_3_TRANS_ANIM: String = "transition - blow - charge level 3"

const BLOW_LEVEL_0_EXPANDED_TRANS_ANIM: String = "transition - blow - charge level 0 - expanded"
const BLOW_LEVEL_1_EXPANDED_TRANS_ANIM: String = "transition - blow - charge level 1 - expanded"
const BLOW_LEVEL_2_EXPANDED_TRANS_ANIM: String = "transition - blow - charge level 2 - expanded"
const BLOW_LEVEL_3_EXPANDED_TRANS_ANIM: String = "transition - blow - charge level 3 - expanded"

const WARP_IN_TRANS_ANIM: String = "transition - warp in"

## Internal variables
var bounce_strength: float = 0.0

func _ready() -> void:
	physics_material = rigid_node.physics_material_override
	rigid_node.body_entered.connect(_on_rigid_node_body_entered)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	control_node.anim_state.travel(OFF_STATE_ANIM)
	
	## When the control node turns off while being dribbled, it should turn back on immediately
	if control_node.control_states.state == control_node.control_states.State.DRIBBLED:
		sc.send_event(TRANS_TO_CHARGING)


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	control_node.anim_state.travel(CHARGING_TRANS_ANIM)
	direction_ray.turn_on()



func _on_charging_state_physics_processing(_delta: float) -> void:
	## Make sure the transition animation is actually happening to avoid state lock
	match(control_node.anim_state.get_current_node()):
		CHARGING_TRANS_ANIM:
			return
		## This is the end state, but leaving the charging state is handled via _on_animation_state_finished
		ON_STATE_ANIM:
			return
		## Cancel the transition animation otherwise
		_:
			sc.send_event(TRANS_TO_OFF)
		
		


# on state
#----------------------------------------
func _on_on_state_entered() -> void:
	state = State.ON
	physics_material.bounce = 0.8
	physics_material.friction = 0.6
	control_node.anim_state.travel(ON_STATE_ANIM)


func _on_on_state_exited() -> void:
	physics_material.bounce = 0.2
	physics_material.friction = 0.5
	direction_ray.turn_off()


# discharging state
#----------------------------------------
func _on_discharging_state_entered() -> void:
	state = State.DISCHARGING
	control_node.anim_state.travel(DISCHARGING_TRANS_ANIM)


# blow state
#----------------------------------------
func _on_blow_state_entered() -> void:
	state = State.BLOW
	sc.send_event(control_node.charge_states.TRANS_DISCHARGE)
	blow_animation()


func blow_animation() -> void:
	if control_node.shield_states.state == control_node.shield_states.State.ON:
		match(control_node.charge_states.state):
			control_node.charge_states.State.NONE:
				control_node.anim_state.travel(BLOW_LEVEL_0_EXPANDED_TRANS_ANIM)
			control_node.charge_states.State.LEVEL1:
				control_node.anim_state.travel(BLOW_LEVEL_1_EXPANDED_TRANS_ANIM)
			control_node.charge_states.State.LEVEL2:
				control_node.anim_state.travel(BLOW_LEVEL_2_EXPANDED_TRANS_ANIM)
			control_node.charge_states.State.LEVEL3:
				control_node.anim_state.travel(BLOW_LEVEL_3_EXPANDED_TRANS_ANIM)
	else:
		match(control_node.charge_states.state):
			control_node.charge_states.State.NONE:
				control_node.anim_state.travel(BLOW_LEVEL_0_TRANS_ANIM)
			control_node.charge_states.State.LEVEL1:
				control_node.anim_state.travel(BLOW_LEVEL_1_TRANS_ANIM)
			control_node.charge_states.State.LEVEL2:
				control_node.anim_state.travel(BLOW_LEVEL_2_TRANS_ANIM)
			control_node.charge_states.State.LEVEL3:
				control_node.anim_state.travel(BLOW_LEVEL_3_TRANS_ANIM)

#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_rigid_node_body_entered(body: Node) -> void:
	var hit_strength: float = control_node.get_ball_velocity().length()
	bounce_strength = hit_strength / 5.0
	
	if body is DroneShield and state == State.ON:
		var drone_shield: DroneShield = body as DroneShield
		drone_shield.look_at(control_node.get_ball_position(), Vector3.UP)
		drone_shield.hit()
	
	if body.get_parent() is Drone and state == State.ON:
		var drone: Drone = body.get_parent()
		if drone.get_hit(hit_strength):
			sc.send_event(TRANS_TO_BLOW)
		else:
			asset.bounce(bounce_strength)
	else:
		asset.bounce(bounce_strength)


func _on_control_states_dribbled_state_entered() -> void:
	sc.send_event(TRANS_TO_CHARGING)


func _on_kicked() -> void:
	direction_ray.was_just_kicked = true


func _on_animation_state_finished(anim_name: String) -> void:
	match(anim_name):
		CHARGING_TRANS_ANIM:
			sc.send_event(TRANS_TO_ON)
		DISCHARGING_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
		BLOW_LEVEL_0_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
			control_node.control_node_control_states.spins_during_dribble = true
		BLOW_LEVEL_1_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
			control_node.control_node_control_states.spins_during_dribble = true
		BLOW_LEVEL_2_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
			control_node.control_node_control_states.spins_during_dribble = true
		BLOW_LEVEL_3_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
			control_node.control_node_control_states.spins_during_dribble = true
		BLOW_LEVEL_0_EXPANDED_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
		BLOW_LEVEL_1_EXPANDED_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
		BLOW_LEVEL_2_EXPANDED_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
		BLOW_LEVEL_3_EXPANDED_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
		WARP_IN_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)
