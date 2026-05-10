class_name ScoutHivemindRepresentation
extends Resource

@export var num_scouts: int
@export var scout_is_in_left_nest: bool
@export var scout_is_in_right_nest: bool
@export var num_scouts_in_gameplay_plane: int
@export var num_incapacitated_scouts: int

func _init(
	p_num_scouts: int = 0,
	p_scout_is_in_left_nest: bool = false,
	p_scout_is_in_right_nest: bool = false,
	p_num_scouts_in_gameplay_plane: int = 0,
	p_num_incapacitated_scouts: int = 0,
) -> void:
	num_scouts = p_num_scouts
	scout_is_in_left_nest = p_scout_is_in_left_nest
	scout_is_in_right_nest = p_scout_is_in_right_nest
	num_scouts_in_gameplay_plane = p_num_scouts_in_gameplay_plane
	num_incapacitated_scouts = p_num_incapacitated_scouts
	
