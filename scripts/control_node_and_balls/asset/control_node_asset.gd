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

## Warp effect
@export var warp_effect: ControlNodeWarpEffect

signal power_up_finished
signal power_down_finished
signal warp_out_finished
signal warp_in_finished

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
	emitters_anim.power_on()
	await emitters_anim.power_on_finished
	await shield_anim.power_on()
	self.blue_wisps()
	power_up_finished.emit()
	return


func power_down(duration: float = 0.8) -> void:
	turn_off_ready_sphere()
	await shield_anim.power_off(duration * (5.0/8.0))
	emitters_anim.power_off(duration * (3.0/8.0))
	await emitters_anim.power_off_finished
	power_down_finished.emit()
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


func warp_out() -> void:
	power_down(0.4)
	await power_down_finished
	warp_effect.open_warp_portal(1.2)
	await warp_effect.open_warp_portal_finished
	warp_effect.dematerialize(0.8)
	await get_tree().create_timer(0.4).timeout
	self.visible = false
	warp_effect.close_warp_portal(0.5)
	await warp_effect.close_warp_portal_finished
	warp_out_finished.emit()


func warp_in() -> void:
	warp_effect.open_warp_portal(0.7)
	await warp_effect.open_warp_portal_finished
	warp_effect.materialize(0.5)
	await get_tree().create_timer(0.25).timeout
	self.visible = true
	warp_effect.close_warp_portal(0.3)
	await warp_effect.close_warp_portal_finished
	warp_in_finished.emit()
