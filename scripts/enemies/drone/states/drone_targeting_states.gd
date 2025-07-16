class_name DroneTargetingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
@export var sc: StateChart

## Parameters

## States Enum
enum State {DISABLED = 0, NONE = 1, ACQUIRING = 2, ACQUIRED = 3}

## Drone nodes controlled by this state
@onready var field_of_view: FieldOfView = drone.get_node("TrackTransformContainer/FieldOfView")
