extends CharacterBody3D

@export var path: Path3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# This represents the player's inertia.
var push_force: float = 1.0
var correction_force: float = 100.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_axis := -Input.get_axis("ui_left", "ui_right")
	var offset: float = path.curve.get_closest_offset(self.position)
	var closest_point: Vector3 = path.curve.get_closest_point(self.position)
	var curve_transform: Transform3D = path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	self.rotation.y = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	
	if direction: # and (offset > path_begin_offset) and (offset < path_end_offset):
		var stay_on_path_correction: Vector3 = (closest_point - self.position)
		velocity.x = input_axis * direction.x * SPEED + correction_force * stay_on_path_correction.x
		velocity.z = input_axis * direction.z * SPEED + correction_force * stay_on_path_correction.z
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c: KinematicCollision3D = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
