extends Level

@onready var scout: Scout = $Scout
@export var scout_scene_path: String = "res://scenes/enemies/scout/scout.tscn"
var scout_scene: Resource

@onready var target_left: TargetMesh = $TargetMeshLeft
@onready var target_right: TargetMesh = $TargetMeshRight
@onready var block: Node3D = $Block


func _ready() -> void:
	scout_scene = load(scout_scene_path)


func _physics_process(_delta: float) -> void:
	if scout:
		scout.in_plane_movement_states.control_axis = Input.get_vector("move_left", "move_right", "move_down", "move_up")
		
		if Input.is_action_just_pressed("dribble"):
			if scout.lock_target():
				scout.quick_open()
		
		if scout.in_plane_movement_states.state == ScoutInPlaneMovementStates.State.TARGET:
			if Input.is_action_just_pressed("kick"):
				scout.fire()
		
		if Input.is_action_just_released("dribble"):
			if scout.asset.anim_state.get_current_node() == "quick open":
				await scout.quick_open_finished
			scout.quick_close()
			scout.release_target()
