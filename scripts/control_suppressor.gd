class_name ControlSuppressor
extends Node

@export var controlled_nodes: Array[Node3D]

var _enabled: bool = false
@export var enabled: bool:
	get:
		return _enabled
	set(value):
		for node in controlled_nodes:
			if not "enabled" in node:
				push_error("ERROR: Node controlled by ControlSuppressor doesn't have an \"enabled\" flag." )
			else:
				node.enabled = !value
