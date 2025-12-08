extends Level

@onready var drone: Drone = $Drone
@onready var spawn_point: Marker3D = $DroneSpawnPoint

var drone_scene: PackedScene = preload("res://scenes/enemies/drone/drone.tscn")

func _ready() -> void:
	Signals.drone_died.connect(_spawn_new_drone)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		pass


func _spawn_new_drone() -> void:
	await get_tree().create_timer(1.5).timeout
	var new_drone: Drone = drone_scene.instantiate()
	new_drone.global_position = spawn_point.global_position
	add_child(new_drone)
	drone = new_drone
	drone.active = true
	
