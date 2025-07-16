class_name DroneV2
extends Node3D

@onready var sc: StateChart = $State

@onready var physics_mode_states: DronePhysicsModeStates = $"State/Root/Physics Mode/Physics Mode States"
@onready var direction_faced_states: DroneDirectionFacedStates = $"State/Root/Physics Mode/char/Direction Faced/Direction Faced States"
@onready var engagement_mode_states: DroneEngagementModeStates = $"State/Root/Physics Mode/char/Engagement Mode/Engagement Mode States"
@onready var engines_states: DroneEnginesStates = $"State/Root/Physics Mode/char/Engagement Mode/open - Engines/Engines States"

func become_rigid() -> void:
	sc.send_event(physics_mode_states.TRANS_CHAR_TO_RIGID)

func become_char() -> void:
	sc.send_event(physics_mode_states.TRANS_RIGID_TO_CHAR)

func become_ragdoll() -> void:
	sc.send_event(physics_mode_states.TRANS_CHAR_TO_RAGDOLL)
