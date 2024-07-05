class_name Player
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kickzone_x: float = $KickZone/KickCollider.transform.origin.x

const SPEED = 500.0
const JUMP_VELOCITY = -600.0
const KICK_VELOCITY = Vector2(400.0, 0.0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_kick: bool = false
var direction_faced: float = 1.0

signal kick


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction > 0:
		animated_sprite.flip_h = false
		$KickZone/KickCollider.transform.origin.x = kickzone_x
		direction_faced = 1.0
		
	elif direction < 0:
		animated_sprite.flip_h = true
		$KickZone/KickCollider.transform.origin.x = -kickzone_x
		direction_faced = -1.0
		
	# PLay animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
		
	if Input.is_action_just_pressed("kick"):
		if can_kick:
			kick.emit()
			animated_sprite.play("kick")

	move_and_slide()


	


func _on_kick_zone_body_entered(_body: Node2D) -> void:
	can_kick = true


func _on_kick_zone_body_exited(_body: Node2D) -> void:
	can_kick = false
