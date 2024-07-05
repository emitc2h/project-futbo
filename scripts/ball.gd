class_name Ball
extends RigidBody2D

@onready var player: Player = $"../Player"

var direction_visible: bool = false
var direction: Vector2 = Vector2.ONE.normalized()
var kick_force: float = 40000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.kick.connect(_on_kick)


func _on_kick() -> void:
	var force: Vector2 = kick_force * direction.normalized()
	apply_force(force)
	
	
func _physics_process(_delta: float) -> void:
	direction = (get_global_mouse_position() - global_position)
	#direction = Input.get_vector("direction_left", "direction_right", "direction_up", "direction_down")
	$DirectionRay.visible = true
	
	var angle: float = direction.angle()
	var clamped_angle: float = 0.0
	if player.direction_faced > 0.0:
		if abs(angle) > PI/2:
			if angle > 0.0:
				clamped_angle = PI/2
			else:
				clamped_angle = -PI/2
		else:
			clamped_angle = angle
	else:
		if abs(angle) < PI/2:
			if angle > 0.0:
				clamped_angle = PI/2
			else:
				clamped_angle = -PI/2
		else:
			clamped_angle = angle
			
	direction = Vector2.from_angle(clamped_angle)
	
	if direction.is_zero_approx():
		direction = Vector2.RIGHT.normalized()
		$DirectionRay.visible = false
	$DirectionRay.global_rotation = direction.angle() + PI/2
