class_name ControlNodeControlStates
extends BallControlStates

## Configurables
@export var shot_speed: float = 50.0
@export var shot_range: float = 10.0

## Overrides
var control_node: ControlNode

## States Enum
# Additional states introduced by this extended class are added to the base class since enums can't
# be directly extended. Those states just aren't used in the base class.

## State transition constants
const TRANS_FREE_TO_SHOT: String = "Control: free to shot"
const TRANS_SHOT_TO_FREE: String = "Control: shot to free"

## internal variables
var shot_vector: Vector3
var initial_pos: Vector3

## Nodes controlled by these states
@export var streak: ControlNodeStreak

func _ready() -> void:
	super._ready()
	control_node = ball as ControlNode
	streak.duration = shot_range / shot_speed


# shot state
#----------------------------------------
func _on_shot_state_entered() -> void:
	state = State.SHOT
	initial_pos = char_node.global_position
	if control_node.physics_states.state != control_node.physics_states.State.CHAR:
		sc.send_event(control_node.physics_states.TRANS_TO_CHAR)
	
	## Initialize streak
	## Bones are in local coordinates, we need to offset the main control node's position
	streak.start_position = control_node.get_ball_position() - control_node.global_position
	streak.end_position = control_node.get_ball_position() - control_node.global_position
	streak.streak_in()


func _on_shot_state_physics_processing(delta: float) -> void:
	var collision: KinematicCollision3D = char_node.move_and_collide(
		shot_vector.normalized() * shot_speed * delta,
		false,
		0.01)
	
	## Update streak end position
	streak.end_position = control_node.get_ball_position() - control_node.global_position
	
	if char_node.global_position.distance_to(initial_pos) > shot_range:
		## Lose a charge when you don't hit anything
		sc.send_event(control_node.charge_states.TRANS_CHARGE_DOWN)
		end_shot()
	
	if collision:
		var node: Node3D = collision.get_collider(0)
		if node.is_in_group("DroneGroup"):
			streak.strike()
			sc.send_event(control_node.charge_states.TRANS_DISCHARGE)
			sc.send_event(control_node.power_states.TRANS_TO_BLOW)
			var drone: Drone
			if node is DroneShield or node is DroneBone:
				drone = node.drone
			else:
				drone = node.get_parent()
			drone.die(shot_vector)
		end_shot()


func _on_shot_state_exited() -> void:
	streak.streak_out()


# control functions
#----------------------------------------
func end_shot() -> void:
	char_node.velocity = Vector3.ZERO
	sc.send_event(TRANS_SHOT_TO_FREE)
