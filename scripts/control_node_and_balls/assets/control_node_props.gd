class_name ControlNodeProps
extends Node

const blue: Color = Color.STEEL_BLUE
const black: Color = Color.BLACK
const magenta: Color = Color.MAGENTA

@export_group("Shield Emitters")
@export var emitter_emission_color: Color = black
@export var emitter_emission_energy: float = 0.0

@export_group("Light")
@export var light_color: Color = blue
@export var light_energy: float = 0.0

@export_group("Shield Shader")
@export var shield_alpha: float = 1.0
@export var shield_dissolve_value: float = 0.0
@export var shield_emission_energy: float = 20.0
@export var shield_ripple_strength: float = 0.02
@export var shield_modulate_color: Color = magenta
@export var shield_modulate_factor: float = 0.0
	
@export_group("Shield Mesh")
@export var shield_scale: float = 1.0

@export_group("Lightning")
@export var lightning_window_size: float = 0.05
@export var lightning_amount_ratio: float = 0.0
@export var lightning_emission_factor: float = 50.0
@export var lightning_reverse: bool = false

@export_group("Aura")
@export var aura_color: Color = Color.TRANSPARENT
@export var aura_scale: float = 0.7
