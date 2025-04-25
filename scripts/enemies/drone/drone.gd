extends Node3D

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	$AnimationPlayer.play("Closed")
	$AnimationPlayer2.play("IdleFloating")

func open_up() -> void:
	$AnimationPlayer.play("OpenUp")

func close_up() -> void:
	$AnimationPlayer.play_backwards("OpenUp")
	
func collapse() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.active = false
	$AnimationPlayer2.stop()
	$AnimationPlayer2.active = false
	$Armature/Skeleton3D.collapse()

func _physics_process(delta: float) -> void:
	self.
