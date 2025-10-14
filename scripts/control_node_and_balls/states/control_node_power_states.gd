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
enum State {OFF = 0, CHARGING = 1, ON = 2, EXPANDED = 3}
var state: State = State.OFF

## State transition constants
const TRANS_OFF_TO_CHARGING: String = "Power: off to charging"
const TRANS_CHARGING_TO_ON: String = "Power: charging to on"
const TRANS_ON_TO_OFF: String = "Power: to off"
const TRANS_ON_TO_EXPANDED: String = "Power: to expanded"
const TRANS_BOUNCE: String = "Power: bounce"
const TRANS_HIT: String = "Power: hit"
const TRANS_BLOW: String = "Power: blow"
const TRANS_EXPANDED_TO_ON: String = "Power: expanded to on"

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


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	asset.power_up_shield()
	direction_ray.turn_on()


func _on_charging_finished() -> void:
	sc.send_event(TRANS_CHARGING_TO_ON)

# on state
#----------------------------------------
func _on_on_state_entered() -> void:
	state = State.ON
	in_on_state = true
	physics_material.bounce = 0.8
	physics_material.friction = 0.6


func _on_on_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("shield up"):
		sc.send_event(TRANS_ON_TO_EXPANDED)


func _on_on_state_exited() -> void:
	in_on_state = false
	physics_material.bounce = 0.2
	physics_material.friction = 0.5


func _on_on_to_off_taken() -> void:
	asset.power_down_shield()
	direction_ray.turn_off()


func _on_on_to_expanded_taken() -> void:
	sc.send_event(control_node.charge_states.TRANS_DISCHARGE)
	asset.expand_shield()


func _on_on_to_bounce_taken() -> void:
	asset.bounce(bounce_strength)


func _on_on_to_hit_taken() -> void:
	asset.bounce(bounce_strength)


func _on_on_to_blow_taken() -> void:
	sc.send_event(control_node.charge_states.TRANS_DISCHARGE)
	asset.blow_shield()
	direction_ray.turn_off()


# expanded state
#----------------------------------------
func _on_expanded_state_entered() -> void:
	state = State.EXPANDED


func _on_expanded_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_released("shield up"):
		sc.send_event(TRANS_EXPANDED_TO_ON)


func _on_expanded_state_exited() -> void:
	asset.shrink_shield()



# signal handling
#========================================
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
			sc.send_event(TRANS_BLOW)
		else:
			sc.send_event(TRANS_HIT)
	else:
		sc.send_event(TRANS_BOUNCE)


func _on_control_states_dribbled_state_entered() -> void:
	sc.send_event(TRANS_OFF_TO_CHARGING)


func _on_kicked() -> void:
	direction_ray.was_just_kicked = true
