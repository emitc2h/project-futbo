class_name DroneEMSpinnersProps
extends Node

const red: Color = Color.LIGHT_CORAL

@export_group("Auras")
@export var aura_color: Color = Color.TRANSPARENT

@export_group("Balls")
@export var balls_dissolve_in: float = 0.0

@export_group("Streaks")
@export var streaks_alpha: float = 0.5
@export var streaks_dissolve_in: float = 0.0
@export var streaks_dissolve_out: float = 1.0

@export_group("Beams")
@export var beams_dissolve_in: float = 0.0
@export var beams_dissolve_out: float = 1.0
