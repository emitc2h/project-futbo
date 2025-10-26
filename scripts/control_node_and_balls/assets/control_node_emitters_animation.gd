class_name ControlNodeEmittersAnimation
extends Node

@export_group("Dependency Injection")
@export var asset: ControlNodeAsset
@export var model: Node3D

enum Power {OFF = 0, ON = 1}
var power: Power = Power.OFF

## A property can only be in one group of props
@export_group("Emitters Props")
@export var emission_color: Dictionary[Power, Color]
@export var emission_energy: Dictionary[Power, float]

const POWER_ON_ANIMATION: String = "power on"
const POWER_OFF_ANIMATION: String = "power off"

var pa_emission_color: PropertyAnimator
var pa_emission_energy: PropertyAnimator

signal power_on_finished
signal power_on_interrupted
signal power_off_finished
signal power_off_interrupted


func _ready() -> void:
	var control_node_mesh: MeshInstance3D = model.get_node("ControlNodeMesh")
	var emitters_material: ShaderMaterial = control_node_mesh.get_surface_override_material(0).next_pass
	
	pa_emission_color = PropertyAnimator.new(self, emitters_material, "shader_parameter/emission_color")
	pa_emission_energy = PropertyAnimator.new(self, emitters_material, "shader_parameter/emission_energy")
	
	## Configure PropertyAnimators
	pa_emission_color.default_ease = Tween.EASE_IN
	pa_emission_color.default_trans = Tween.TRANS_LINEAR
	pa_emission_color.interrupted_behavior = pa_emission_color.InterruptedBehavior.INITIAL_VALUE
	pa_emission_color.interrupted.connect(_on_pa_emission_color_interrupted)
	pa_emission_color.finished.connect(_on_pa_emission_color_finished)
	
	pa_emission_energy.default_ease = Tween.EASE_IN
	pa_emission_energy.default_trans = Tween.TRANS_EXPO
	pa_emission_energy.interrupted_behavior = pa_emission_energy.InterruptedBehavior.INITIAL_VALUE
	
	pa_emission_color.register_dependent(pa_emission_energy)
	
	pa_emission_color.set_to(emission_color[Power.OFF])
	pa_emission_energy.set_to(emission_energy[Power.OFF])


##========================================##
## ANIMATIONS                             ##
##========================================##
func power_on() -> void:
	pa_emission_color.animate_from_to(POWER_ON_ANIMATION, emission_color[Power.OFF], emission_color[Power.ON], 0.7)
	pa_emission_energy.animate_from_to(POWER_ON_ANIMATION, emission_energy[Power.OFF], emission_energy[Power.ON], 0.7)


func power_off(duration: float = 0.3) -> void:
	pa_emission_color.animate_from_to(POWER_OFF_ANIMATION, emission_color[Power.OFF], emission_color[Power.ON], duration)
	pa_emission_energy.animate_from_to(POWER_OFF_ANIMATION, emission_energy[Power.OFF], emission_energy[Power.ON], duration)


##========================================##
## SIGNALS                                ##
##========================================##
@warning_ignore("shadowed_variable_base_class")
func _on_pa_emission_color_interrupted(name: String) -> void:
	match(name):
		POWER_ON_ANIMATION:
			power = Power.OFF
			power_on_interrupted.emit()
		POWER_OFF_ANIMATION:
			power = Power.ON
			power_off_interrupted.emit()


@warning_ignore("shadowed_variable_base_class")
func _on_pa_emission_color_finished(name: String) -> void:
	match(name):
		POWER_ON_ANIMATION:
			power = Power.ON
			power_on_finished.emit()
		POWER_OFF_ANIMATION:
			power = Power.OFF
			power_off_finished.emit()
