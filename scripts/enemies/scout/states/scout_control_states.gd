class_name ScoutControlStates
extends BallControlStates

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout

var tw_rotation_x: Tween
var tw_rotation_y: Tween

# dribbled state
#----------------------------------------
func _on_dribbled_state_entered() -> void:
	tw_rotation_x = create_tween()
	tw_rotation_x.tween_property(char_node, "rotation:x", 0.0, 0.5)
	tw_rotation_y = create_tween()
	tw_rotation_y.tween_property(char_node, "rotation:y", 0.0, 0.5)
	
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, true)
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, true)
	super._on_dribbled_state_entered()


func _on_dribbled_state_exited() -> void:
	super._on_dribbled_state_exited()
	tw_rotation_x.kill()
	tw_rotation_y.kill()
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, false)
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, false)
