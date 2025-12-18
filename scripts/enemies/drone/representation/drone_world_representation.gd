class_name DroneWorldRepresentation
extends Resource

@export var patrol_marker_1_pos: float
@export var patrol_marker_2_pos: float

func _init(
	p_patrol_marker_1_pos: float = 0.0,
	p_patrol_marker_2_pos: float = 0.0,
	) -> void:
	patrol_marker_1_pos = p_patrol_marker_1_pos
	patrol_marker_2_pos = p_patrol_marker_2_pos
	

var _patrol_center_pos_x: float
var patrol_center_pos_x: float:
	get:
		if not _patrol_center_pos_x:
			_patrol_center_pos_x = (patrol_marker_1_pos + patrol_marker_2_pos) / 2.0
		return _patrol_center_pos_x
