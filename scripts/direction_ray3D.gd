class_name DirectionRay3D
extends Sprite3D

# Internal references
@onready var state: StateChart = $State
@onready var clamped_aim: ClampedAim3D = $ClampedAim

# Dynamic properties
var aim: Vector2
var direction_faced: Enums.Direction = Enums.Direction.RIGHT


func _ready() -> void:
	self.visible = false


# Listen to the aim vector at all times
func _physics_process(delta: float) -> void:
	aim = Converters.vec2_from(
		Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down"))


#=======================================================
# STATES
#=======================================================

# idle state
#----------------------------------------
func _on_idle_state_physics_processing(delta: float) -> void:
	if not aim.is_zero_approx():
		state.send_event("idle to pointing")


# pointing state
#----------------------------------------
func _on_pointing_state_entered() -> void:
	self.visible = true


func _on_pointing_state_processing(delta: float) -> void:
	self.global_rotation.z = clamped_aim.get_angle(aim, direction_faced) - PI/2
	if aim.is_zero_approx():
		state.send_event("pointing to idle")


func _on_pointing_state_exited() -> void:
	self.visible = false
