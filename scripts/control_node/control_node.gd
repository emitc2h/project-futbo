extends RigidBody3D
class_name ControlNode

@onready var control_node_mesh: MeshInstance3D = $ControlNodeModel/ControlNodeMesh
@onready var shield_mesh: MeshInstance3D = $ControlNodeModel/ShieldMesh

@onready var shield_material: Material = $ControlNodeModel/ShieldMesh.get_surface_override_material(0)
@onready var emitters_material: Material = $ControlNodeModel/ControlNodeMesh.get_surface_override_material(0).next_pass

var power_on: bool = false
var blue: Color = Color.STEEL_BLUE
var black: Color = Color.BLACK

func power_up_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	
	tween1.tween_property(emitters_material, "shader_parameter/emission_color", blue, 0.8)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)\
		.from(black)
	tween2.tween_property(emitters_material, "shader_parameter/emission_energy", 1000.0, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(0.0)
	tween2.tween_property(shield_material, "shader_parameter/dissolve_value", 1.0, 1.2)\
		.from(0.0)
		
	power_on = true

func power_down_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/dissolve_value", 0.0, 0.5)\
		.from(1.0)
	tween1.tween_property(emitters_material, "shader_parameter/emission_energy", 0.0, 0.4)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)\
		.from(1000.0)
	tween2.tween_property(emitters_material, "shader_parameter/emission_color", black, 1.8)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(blue)
	power_on = false


func bounce(bounce_strength: float) -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/emission_energy", 20.0, 0.4)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(500.0 * bounce_strength)
		
	tween2.tween_property(shield_material, "shader_parameter/ripple_strength", 0.02, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(0.2 * bounce_strength)

func expand_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", 2.0, 2.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(0.02)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", 3000.0, 2.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(20.0)
		
	tween3.tween_property(shield_mesh, "scale", Vector3(1.0, 1.0, 1.0), 2.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3(1.0, 1.0, 1.0))
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", 0.01, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", 20.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)\
		.from(3000.0)
	
	tween3.tween_property(shield_mesh, "scale", Vector3(8.0, 8.0, 8.0), 1.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3(1.0, 1.0, 1.0))


func shrink_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_mesh, "scale", Vector3(1.0, 1.0, 1.0), 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)\
		.from(Vector3(8.0, 8.0, 8.0))
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 0.05, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 1.0, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(0.05)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", 1.0, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.from(0.01)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", 0.02, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(1.0)

func _on_body_entered(body: Node) -> void:
	bounce(linear_velocity.length())
