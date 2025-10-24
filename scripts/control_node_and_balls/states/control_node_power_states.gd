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
enum State {OFF = 0, CHARGING = 1, ON = 2}
var state: State = State.OFF

## State transition constants
const TRANS_TO_CHARGING: String = "Power: to charging"
const TRANS_TO_ON: String = "Power: to on"
const TRANS_TO_OFF: String = "Power: to off"
const TRANS_TO_BLOW: String = "Power: to blow"

## Internal variables
var bounce_strength: float = 0.0
var in_on_state: bool = false

func _ready() -> void:
	physics_material = rigid_node.physics_material_override
	asset.power_up_finished.connect(_on_charging_finished)
	rigid_node.body_entered.connect(_on_rigid_node_body_entered)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	
	## When the control node turns off while being dribbled, it should turn back on immediately
	if control_node.control_states.state == control_node.control_states.State.DRIBBLED:
		sc.send_event(TRANS_TO_CHARGING)


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	asset.power_up()
	direction_ray.turn_on()


func _on_charging_finished() -> void:
	sc.send_event(TRANS_TO_ON)

# on state
#----------------------------------------
func _on_on_state_entered() -> void:
	state = State.ON
	in_on_state = true
	physics_material.bounce = 0.8
	physics_material.friction = 0.6


func _on_on_state_exited() -> void:
	in_on_state = false
	physics_material.bounce = 0.2
	physics_material.friction = 0.5


func _on_on_to_off_taken() -> void:
	asset.power_down()
	direction_ray.turn_off()


func _on_on_to_blow_taken() -> void:
	sc.send_event(control_node.charge_states.TRANS_DISCHARGE)
	asset.blow()
	direction_ray.turn_off()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_rigid_node_body_entered(body: Node) -> void:
	var hit_strength: float = control_node.get_ball_velocity().length()
	bounce_strength = hit_strength / 5.0
	
	if body is DroneShield and in_on_state:
		var drone_shield: DroneShield = body as DroneShield
		drone_shield.look_at(control_node.get_ball_position(), Vector3.UP)
		drone_shield.hit()
	
	if body.get_parent() is Drone and in_on_state:
		var drone: Drone = body.get_parent()
		if drone.get_hit(hit_strength):
			sc.send_event(TRANS_TO_BLOW)
		else:
			asset.shield_anim.bounce(bounce_strength)
	else:
		asset.shield_anim.bounce(bounce_strength)


func _on_control_states_dribbled_state_entered() -> void:
	sc.send_event(TRANS_TO_CHARGING)


func _on_kicked() -> void:
	direction_ray.was_just_kicked = true
