extends Level

@onready var drone: Drone = $Drone
@export var drone_scene_path: String = "res://scenes/enemies/drone/drone.tscn"
var drone_scene: Resource

@onready var target_left: TargetMesh = $TargetMeshLeft
@onready var target_right: TargetMesh = $TargetMeshRight
@onready var block: Node3D = $Block

var initial_drone_transform: Transform3D


func _ready() -> void:
	initial_drone_transform = drone.transform
	drone_scene = load(drone_scene_path)


func _physics_process(_delta: float) -> void:
	if drone:
		drone.physics_mode_states.left_right_axis = Input.get_axis("move_left", "move_right")


## PHYSICS
## ==================================
func _on_character_mode_button_pressed() -> void:
	drone.become_char()


func _on_rigid_mode_button_pressed() -> void:
	drone.become_rigid()


func _on_ragdoll_mode_button_pressed() -> void:
	drone.become_ragdoll()


func _on_reset_button_pressed() -> void:
	if drone:
		drone.queue_free()
	drone = drone_scene.instantiate() as Drone
	drone.initial_behavior = drone.behavior_states.State.PUPPET
	drone.transform = initial_drone_transform
	add_child(drone)
	

## DIRECTION FACED
## ==================================
func _on_left_button_pressed() -> void:
	drone.face_left()


func _on_right_button_pressed() -> void:
	drone.face_right()


## ENGAGEMENT
## ==================================
func _on_open_button_pressed() -> void:
	drone.open()


func _on_close_button_pressed() -> void:
	drone.close()


func _on_quick_close_button_pressed() -> void:
	drone.quick_close()


## ENGINES
## ==================================
func _on_thrust_button_pressed() -> void:
	drone.thrust()


func _on_burst_button_pressed() -> void:
	drone.burst()


func _on_stop_button_pressed() -> void:
	drone.stop_engines()


func _on_quick_stop_button_pressed() -> void:
	drone.quick_stop_engines()


## SPINNERS
## ==================================
func _on_fire_button_pressed() -> void:
	drone.fire()


## VULNERABILITY
## ==================================
func _on_invulnerable_button_pressed() -> void:
	drone.become_invulnerable()


func _on_defendable_button_pressed() -> void:
	drone.become_defendable()


func _on_vulnerable_button_pressed() -> void:
	drone.become_vulnerable()


func _on_die_button_pressed() -> void:
	drone.die(Vector3.RIGHT * 6.0)


## TARGETING
## ==================================
func _on_enable_button_pressed() -> void:
	drone.enable_targeting(true)


func _on_disable_button_pressed() -> void:
	drone.disable_targeting()


## BLOCK
## ==================================
func _on_check_button_toggled(_toggled_on: bool) -> void:
	block.visible = !block.visible
	var collision_shape: CollisionShape3D = block.get_node("CollisionShape3D")
	collision_shape.disabled = !collision_shape.disabled


## TARGET
## ==================================
func _on_target_bob_button_toggled(_toggled_on: bool) -> void:
	target_left.bob = !target_left.bob
	target_right.bob = !target_right.bob
