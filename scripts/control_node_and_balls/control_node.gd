class_name ControlNode
extends Ball

@onready var asset: ControlNodeAsset = $ModelContainer/ControlNodeAsset
@onready var physics_material: PhysicsMaterial = $InertNode.physics_material_override

@onready var charge_states: ControlNodeChargeStates = $"State/Root/Charge/Charge States"
@onready var direction_ray: DirectionRay = $DirectionRay

var bounce_strength: float = 0.0
var in_on_state: bool = false


func _ready() -> void:
	asset.power_up_finished.connect(_on_charging_finished)


func _on_inert_node_body_entered(body: Node) -> void:
	var hit_strength: float = get_ball_velocity().length()
	bounce_strength = hit_strength / 5.0
	
	Signals.debug_running_log.emit("control node is colliding with " + body.name)
	
	if body is DroneShield and in_on_state:
		var drone_shield: DroneShield = body as DroneShield
		drone_shield.look_at(self.get_ball_position(), Vector3.UP)
		drone_shield.hit()
	
	if body.get_parent() is Drone and in_on_state:
		var drone: Drone = body.get_parent()
		if drone.get_hit(hit_strength):
			sc.send_event("blow")
		else:
			sc.send_event("hit")
	else:
		sc.send_event("bounce")


#=======================================================
# STATES
#=======================================================

# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	asset.power_up_shield()
	direction_ray.turn_on()


func _on_charging_finished() -> void:
	sc.send_event("turn on")


# power on state
#----------------------------------------
func _on_on_state_entered() -> void:
	in_on_state = true
	physics_material.bounce = 0.8
	physics_material.friction = 0.6


func _on_on_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("shield up"):
		sc.send_event("expand shield")


func _on_turn_off_taken() -> void:
	asset.power_down_shield()
	direction_ray.turn_off()


func _on_expand_shield_taken() -> void:
	sc.send_event(charge_states.TRANS_DISCHARGE)
	asset.expand_shield()


func _on_bounce_taken() -> void:
	asset.bounce(bounce_strength)


func _on_hit_taken() -> void:
	asset.bounce(bounce_strength)


func _on_blow_taken() -> void:
	sc.send_event(charge_states.TRANS_DISCHARGE)
	asset.blow_shield()
	direction_ray.turn_off()


func _on_on_state_exited() -> void:
	in_on_state = false
	physics_material.bounce = 0.2
	physics_material.friction = 0.5


# shield up state
#----------------------------------------
func _on_shrink_shield_taken() -> void:
	asset.shrink_shield()


func _on_shield_up_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_released("shield up"):
		sc.send_event("shrink shield")


func _on_control_node_dribbled_state_entered() -> void:
	sc.send_event("charge")


func _on_kicked() -> void:
	direction_ray.was_just_kicked = true
