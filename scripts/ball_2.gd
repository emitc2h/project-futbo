class_name Ball2
extends Node2D

enum Mode {INERT, DRIBBLED}
var mode: Mode = Mode.INERT

# Internal references
@onready var state: StateChart = $State

# physics nodes
@onready var inert_node: RigidBody2D = $InertNode
@onready var dribbled_node: CharacterBody2D = $DribbledNode

# controlled nodes
@onready var direction_ray: DirectionRay = $DirectionRay
@onready var sprite: Node2D = $SpriteContainer

#=======================================================
# STATES
#=======================================================

# inert state
#----------------------------------------
func _on_inert_state_entered() -> void:
	# inert node takes ownership of transform
	inert_node.transform = dribbled_node.transform
	inert_node.linear_velocity = dribbled_node.velocity
	dribbled_node.velocity = Vector2.ZERO
	
	# inert node collides, dribbled node does not
	inert_node.set_collision_layer_value(3, true)
	dribbled_node.set_collision_layer_value(3, false)
	
	# wake up the inert node
	inert_node.sleeping = false
	inert_node.set_freeze_enabled(false)
	
	# set mode
	mode = Mode.INERT


func _on_inert_state_physics_processing(delta: float) -> void:
	# transfer transform to other nodes
	direction_ray.position = inert_node.position
	sprite.transform = inert_node.transform


# dribbled state
#----------------------------------------
func _on_dribbled_state_entered() -> void:
	# dribbled node collides, inert node does not
	dribbled_node.set_collision_layer_value(3, true)
	inert_node.set_collision_layer_value(3, false)
	
	# freeze the inert node
	inert_node.set_freeze_enabled(true)
	inert_node.sleeping = true
	
	# dribbled node takes ownership of transform
	dribbled_node.transform = inert_node.transform
	
	# set mode
	mode = Mode.DRIBBLED


func _on_dribbled_state_physics_processing(delta: float) -> void:
	# transfer transform to other nodes
	direction_ray.position = dribbled_node.position
	sprite.transform = dribbled_node.transform


#=======================================================
# RECEIVED SIGNALS
#=======================================================
# Signals from player indicating which direction they're facing
func _on_facing_left() -> void:
	direction_ray.direction_faced = Enums.Direction.LEFT


func _on_facing_right() -> void:
	direction_ray.direction_faced = Enums.Direction.RIGHT


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick(force_vector: Vector2) -> void:
	state.send_event("dribbled to inert")
	inert_node.apply_central_impulse(force_vector)
