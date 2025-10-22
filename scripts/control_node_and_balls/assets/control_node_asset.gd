extends Node3D
class_name ControlNodeAsset

@export var shield_anim: ControlNodeShieldAnimation
@export var emitters_anim: ControlNodeEmittersAnimation

## Wisps (needs to be placed in the TrackPositionContainer, so inject dependency)
@export var wisps_particles: GPUParticles3D
@export var lightning_particles: GPUParticles3D

## Aura
@onready var aura_mesh: MeshInstance3D = $Aura
var aura_material: StandardMaterial3D

## Ready Sphere (needs to be placed in the TrackPositionContainer, so inject dependency)
@export var ready_sphere: ControlNodeReadySphere

signal power_up_finished

const blue: Color = Color.STEEL_BLUE
const black: Color = Color.BLACK
const magenta: Color = Color.LIGHT_PINK


func _ready() -> void:
	ready_sphere.visible = false
	power_down()


################################
##        ANIMATIONS         ##
###############################
func power_up() -> void:
	await emitters_anim.power_on()
	await shield_anim.power_on()
	self.blue_wisps()
	power_up_finished.emit()
	return


func power_down() -> void:
	turn_off_ready_sphere()
	await shield_anim.power_off()
	await emitters_anim.power_off()
	return


func blow() -> void:
	shield_anim.blow()
	emitters_anim.power_off()
	turn_off_ready_sphere()


func turn_on_ready_sphere() -> void:
	ready_sphere.visible = true
	aura_mesh.visible = false


func turn_off_ready_sphere() -> void:
	ready_sphere.visible = false
	aura_mesh.visible = true


func blue_wisps() -> void:
	wisps_particles.process_material.color = blue
	wisps_particles.emitting = true


func magenta_wisps() -> void:
	wisps_particles.process_material.color = magenta
	wisps_particles.emitting = true
