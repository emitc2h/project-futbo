class_name ControlNodeReadySphere
extends Node3D

## Parameters


## ReadySphere
@onready var ready_sphere_mesh: MeshInstance3D = $ReadySphere
var ready_sphere_material: ShaderMaterial


func _ready() -> void:
	ready_sphere_material = ready_sphere_mesh.get_surface_override_material(0)
