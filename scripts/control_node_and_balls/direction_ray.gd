class_name DirectionRay
extends Node3D

# Internal references
@onready var state: StateChart = $State
@onready var particles: GPUParticles3D = $GPUParticles3D

var _was_just_kicked: bool = false
var was_just_kicked: bool:
	get:
		return _was_just_kicked
	set(value):
		_was_just_kicked = true
		await get_tree().create_timer(1.5).timeout
		_was_just_kicked = false


func _ready() -> void:
	particles.local_coords = true
	particles.emitting = false
	self.visible = false


#=======================================================
# POINTING STATES
#=======================================================

# idle state
#----------------------------------------
func _on_idle_state_physics_processing(delta: float) -> void:
	if not Aim.input_is_zero_approx:
		state.send_event("idle to pointing")


# pointing state
#----------------------------------------
func _on_pointing_state_entered() -> void:
	if _was_just_kicked:
		state.send_event("pointing to idle")
	else:
		self.visible = true


func _on_pointing_state_processing(delta: float) -> void:
	if Aim.input_is_zero_approx or _was_just_kicked:
		state.send_event("pointing to idle")
	else:
		var angle: float = Aim.angle - PI/2
		self.global_rotation.z = angle
		particles.process_material.set("angle", angle)


func _on_pointing_state_exited() -> void:
	self.visible = false


#=======================================================
# POWER STATES
#=======================================================

# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	particles.amount_ratio = 0.0
	particles.emitting = false
	particles.visible = false


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	particles.emitting = true
	particles.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(particles, "amount_ratio", 1.0, 2.7)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUART)\
		.from(0.0)
	
	await tween.finished
	state.send_event("turn on")


# on state
#----------------------------------------
func _on_on_state_exited() -> void:
	particles.restart()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(particles, "amount_ratio", 0.0, 0.2)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(1.0)


#=======================================================
# CONTROL FUNCTIONS
#=======================================================

func turn_on() -> void:
	state.send_event("charge")


func turn_off() -> void:
	state.send_event("turn off")
