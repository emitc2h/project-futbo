class_name Drone
extends Node3D

@onready var sc: StateChart = $State

## customization
@export_group("Customization")
@export var initial_behavior: DroneBehaviorStates.State

## state machines
@export_group("State Machines")
@export_subgroup("Function State Machines")
@export var physics_mode_states: DronePhysicsModeStates
@export var direction_faced_states: DroneDirectionFacedStates
@export var engagement_mode_states: DroneEngagementModeStates
@export var engines_states: DroneEnginesStates
@export var spinners_states: DroneSpinnersStates
@export var vulnerability_states: DroneVulnerabilityStates

@export_subgroup("Monitoring State Machines")
@export var targeting_states: DroneTargetingStates
@export var proximity_states: DroneProximityStates
@export var position_states: DronePositionStates

@export_group("Behavior State Machines")
@export var behavior_states: DroneBehaviorStates
@export var behavior_attack_states: DroneAttackStates

## Useful internal nodes to have a handle on
@onready var char_node: CharacterBody3D = $CharNode
@onready var rigid_node: InertNode = $RigidNode
@onready var repr: DroneInternalRepresentation = $InternalRepresentation
@onready var shield: DroneShield = $TrackPositionContainer/DroneShield
@onready var track_position_container: Node3D = $TrackPositionContainer

## Animation nodes
@onready var model: DroneModel = $TrackTransformContainer/DroneModel
@onready var model_anim_tree: AnimationTree = $"TrackTransformContainer/DroneModel/AnimationTree"
@onready var anim_state: AnimationNodeStateMachinePlayback


func _ready() -> void:
	## initialize the internal representation
	repr.initialize()
	anim_state = model_anim_tree.get("parameters/playback")
	behavior_states.set_initial_behavior(initial_behavior)
	Signals.debug_advance.connect(_on_debug_advance)


## Physics Controls
## ---------------------------------------
func become_rigid() -> void:
	sc.send_event(physics_mode_states.TRANS_TO_RIGID)


func become_char() -> void:
	sc.send_event(physics_mode_states.TRANS_TO_CHAR)


func become_ragdoll() -> void:
	sc.send_event(physics_mode_states.TRANS_TO_RAGDOLL)


func get_global_pos_x() -> float:
	return track_position_container.global_position.x


## Direction Controls
## ---------------------------------------
signal face_right_finished(id: int)

func face_right(id: int = 0) -> void:
	if not direction_faced_states.state == direction_faced_states.State.FACE_RIGHT:
		sc.send_event(direction_faced_states.TRANS_TO_TURN_RIGHT)
		await direction_faced_states.is_now_facing_right
	face_right_finished.emit(id)


signal face_left_finished(id: int)

func face_left(id: int = 0) -> void:
	if not direction_faced_states.state == direction_faced_states.State.FACE_LEFT:
		sc.send_event(direction_faced_states.TRANS_TO_TURN_LEFT)
		await direction_faced_states.is_now_facing_left
	face_left_finished.emit(id)


func face_toward(x: float, id: int = 0) -> void:
	## If x is to the right of the drone, drone should face right
	if x > char_node.global_position.x:
		face_right(id)
	else:
		face_left(id)


func face_away(x: float, id: int = 0) -> void:
	## If x is to the right of the drone, drone should face left
	if x > char_node.global_position.x:
		face_left(id)
	else:
		face_right(id)


## Movement Controls
## ---------------------------------------
func move_toward_x_pos(target_x: float, delta: float, away: bool = false) -> void:
	var direction: float = 1.0
	if away:
		direction = -1.0
	var target_value: float = direction * (target_x - char_node.global_position.x) / max(abs(target_x - char_node.global_position.x), 0.5)
	physics_mode_states.left_right_axis = lerp(physics_mode_states.left_right_axis, target_value, 20.0 * delta)


func stop_moving(delta: float) -> void:
	physics_mode_states.left_right_axis = lerp(physics_mode_states.left_right_axis, 0.0, 10.0 * delta)


func track_target(offset: float, delta: float) -> void:
	var target_x: float = targeting_states.target.global_position.x
	face_toward(target_x)
	var offset_sign: float = sign(char_node.global_position.x - target_x)
	move_toward_x_pos(target_x + offset_sign * offset, delta)


## Engagement Controls
## ---------------------------------------
signal open_finished(id: int)

func open(id: int = 0) -> void:
	anim_state.travel("open up")
	sc.send_event(engagement_mode_states.TRANS_TO_OPENING)
	await engagement_mode_states.opening_finished
	open_finished.emit(id)


signal close_finished(id: int)

func close(id: int = 0) -> void:
	anim_state.travel("close up")
	sc.send_event(engagement_mode_states.TRANS_TO_CLOSING)
	await engagement_mode_states.closing_finished
	close_finished.emit(id)


signal quick_close_finished(id: int)

func quick_close(id: int = 0) -> void:
	if anim_state.get_current_node() in ["start thrust", "idle thrust", "stop_thrust"]:
		anim_state.travel("thrust close")
	else:
		anim_state.travel("quick close")
	sc.send_event(engagement_mode_states.TRANS_TO_QUICK_CLOSE)
	await engagement_mode_states.closing_finished
	quick_close_finished.emit(id)


## Engine Controls
## ---------------------------------------
func thrust() -> void:
	if not anim_state.get_current_node() in ["start thrust", "idle thrust"]:
		anim_state.travel("start thrust")
	physics_mode_states.speed = engines_states.thrust_speed
	sc.send_event(engines_states.TRANS_TO_THRUST)


func burst() -> void:
	if not anim_state.get_current_node() in ["start thrust", "idle thrust"]:
		anim_state.travel("start thrust")
	physics_mode_states.speed = engines_states.burst_speed
	sc.send_event(engines_states.TRANS_TO_BURST)

signal stop_engines_finished

func stop_engines() -> void:
	if anim_state.get_current_node() in ["start thrust", "idle thrust"]:
		anim_state.travel("stop thrust")
	physics_mode_states.speed = engines_states.off_speed
	sc.send_event(engines_states.TRANS_TO_STOPPING)
	await engines_states.engines_are_off
	stop_engines_finished.emit()


func quick_stop_engines(keep_speed: bool = false) -> void:
	if not keep_speed and anim_state.get_current_node() in ["start thrust", "idle thrust"]:
		anim_state.travel("stop thrust")
		physics_mode_states.speed = engines_states.off_speed
	sc.send_event(engines_states.TRANS_TO_QUICK_OFF)


func reset_engines() -> void:
	sc.send_event(engines_states.TRANS_TO_OFF)


## Spinner Controls
## ---------------------------------------
signal fire_finished(id: int)

func fire(id: int = 0) -> void:
	if anim_state.get_current_node() in ["idle", "targeting"]:
		sc.send_event(spinners_states.TRANS_TO_CHARGING)
		await spinners_states.fire_finished
		fire_finished.emit(id)
	else:
		fire_finished.emit(id)


## Vulnerability Controls
## ---------------------------------------
func become_vulnerable() -> void:
	sc.send_event(vulnerability_states.TRANS_TO_VULNERABLE)



func become_defendable() -> void:
	sc.send_event(vulnerability_states.TRANS_TO_DEFENDABLE)



func become_invulnerable() -> void:
	sc.send_event(vulnerability_states.TRANS_TO_INVULNERABLE)



## Targeting Controls
## ---------------------------------------
func enable_targeting(to_acquiring: bool = false) -> void:
	if to_acquiring:
		sc.send_event(targeting_states.TRANS_TO_ACQUIRING)
	else:
		sc.send_event(targeting_states.TRANS_TO_NONE)


func disable_targeting() -> void:
	sc.send_event(targeting_states.TRANS_TO_DISABLED)


## Proximity Controls
## ---------------------------------------
func enable_proximity_detector() -> void:
	sc.send_event(proximity_states.TRANS_TO_ENABLED)


func disable_proximity_detector() -> void:
	sc.send_event(proximity_states.TRANS_TO_DISABLED)


## Hitbox
## ---------------------------------------
func die(force: Vector3) -> void:
	if vulnerability_states.state == vulnerability_states.State.VULNERABLE:
		model.die()
		sc.send_event(physics_mode_states.TRANS_TO_RAGDOLL)
		sc.send_event(behavior_states.TRANS_TO_DEAD)
		model.body_bone.apply_central_impulse(force * 5.0)


func get_hit(strength: float) -> bool:
	return false


## Internal Representation
## ---------------------------------------
func force_update_player_pos_x() -> bool:
	if targeting_states.target:
		repr.playerRepresentation.last_known_player_pos_x = targeting_states.target.global_position.x
		return true
	return false


## Debugging
## ---------------------------------------
func generate_state_report() -> String:
	var output: String = ""
	output += "Physics Mode : " + physics_mode_states.State.keys()[physics_mode_states.state] + "\n"
	output += "Direction Faced : " + direction_faced_states.State.keys()[direction_faced_states.state] + "\n"
	output += "Engagement Mode : " + engagement_mode_states.State.keys()[engagement_mode_states.state] + "\n"
	output += "Engines : " + engines_states.State.keys()[engines_states.state] + "\n"
	output += "Spinners : " + spinners_states.State.keys()[spinners_states.state] + "\n"
	output += "Vulnerability : " + vulnerability_states.State.keys()[vulnerability_states.state] + "\n"
	output += "Targeting : " + targeting_states.State.keys()[targeting_states.state] + "\n"
	output += "Behavior : " + behavior_states.State.keys()[behavior_states.state] + "\n"
	if behavior_states.state == behavior_states.State.ATTACK:
		output += "---> Attack : " + behavior_attack_states.State.keys()[behavior_attack_states.state] + "\n"
	output += "===================================\n"
	output += "Animation tree node: " + anim_state.get_current_node()\
			 + " (fading : " + anim_state.get_fading_from_node() + ")"
	return output


func _on_debug_advance() -> void:
	Signals.debug_log.emit(generate_state_report())


func _on_rigid_node_body_entered(body: Node) -> void:
	if body.is_in_group("PlayerGroup"):
		Signals.player_knocked.emit(rigid_node.velocity_from_previous_frame, rigid_node.global_position)
