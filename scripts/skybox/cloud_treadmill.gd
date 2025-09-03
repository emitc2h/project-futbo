extends Node3D

@export_group("Treadmill Properties")
# List of parameters:
# - Layers are child nodes
# - Treadmill axis
# - Treadmill length
@export var length: float = 2.0
# - Treadmill speed
@export var speed: float = 1.0
# - Treadmill angle
@export_range(0.0, 90.0, 1.0, "radians_as_degrees") var angle: float = 0.0
# - Fade-in end length fraction (taken from the beginning of the treadmill)
@export_range(0.0, 1.0) var fade_in_end_fraction: float = 0.2
# - Fade-out begin length fraction (taken from the beginning of the treadmill)
@export_range(0.0, 1.0) var fade_out_end_fraction: float = 0.8

@export var x_drift_speed: float = 0.0

var initial_transform: Transform3D
var appear_position: float
var disappear_position: float
var increment: float # distance between two layers on the z-axis


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Distribute the layers around the treadmill's position on the z-axis
	appear_position = -0.5 * length
	disappear_position = 0.5 * length
	increment = length / get_child_count()
	
	for i in get_child_count():
		# Assign initial positions
		var layer: MeshInstance3D = get_child(i) as MeshInstance3D
		layer.position.z = appear_position + i * increment
		
		# Inform shader about x drift
		layer.get_surface_override_material(0).set_shader_parameter("uvx_drift_speed", x_drift_speed)
		
		# Rotate the layer against the treadmill so it still faces the camera
		layer.rotate_x(angle)
	
	# rotate the treadmill itself, but keep the layers facing the camera
	rotate_x(-angle)


func relative_layer_position(layer: MeshInstance3D) -> float:
	return (layer.position.z - appear_position) / length


func cosine_fade(x: float) -> float:
	if x < 0.0: return 1.0
	elif x > 1.0: return 0.0
	else: return (cos(x*PI) / 2.0) + 0.5


func fade_in(rel_pos: float) -> float:
	if rel_pos < 0.0: return 0.0
	elif rel_pos > fade_in_end_fraction: return 1.0
	else: return 1.0 - cosine_fade(rel_pos / fade_in_end_fraction)


func fade_out(rel_pos: float) -> float:
	if rel_pos < fade_out_end_fraction: return 1.0
	elif rel_pos > 1.0: return 0.0
	else: return cosine_fade(1.0 - (1.0 - rel_pos) / (1.0 - fade_out_end_fraction))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for node in get_children():
		var layer: MeshInstance3D = node as MeshInstance3D
		layer.position.z += delta * speed
		
		# compute transparency based on fade in/out parameters
		var rel_pos: float = relative_layer_position(layer)
		layer.transparency = 1.0 - (fade_in(rel_pos) * fade_out(rel_pos))
		
		# send back to beginning of treadmill when reaching the end
		if layer.position.z > disappear_position:
			layer.position.z = appear_position
