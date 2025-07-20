class_name DroneModel
extends Node3D

## Decide which state to aim for after opening up
var trans_openup_to_idle_opened: bool = true
var trans_openup_to_targeting_opened: bool = false

## Decide which state to aim for after stopping thrust
var trans_stopthrust_to_idle_opened: bool = true
var trans_stopthrust_to_targeting_opened: bool = false

## Decide which state to aim for after firing
var trans_fire_to_idle_opened: bool = true
var trans_fire_to_targeting_opened: bool = false

func open_paths_to_targeting() -> void:
	trans_openup_to_idle_opened = false
	trans_stopthrust_to_idle_opened = false
	trans_fire_to_idle_opened = false
	
	trans_openup_to_targeting_opened = true
	trans_stopthrust_to_targeting_opened = true
	trans_fire_to_targeting_opened = true


func open_paths_to_idle() -> void:
	trans_openup_to_idle_opened = true
	trans_stopthrust_to_idle_opened = true
	trans_fire_to_idle_opened = true
	
	trans_openup_to_targeting_opened = false
	trans_stopthrust_to_targeting_opened = false
	trans_fire_to_targeting_opened = false
