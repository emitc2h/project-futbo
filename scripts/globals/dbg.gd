extends Node

func log(str: String, include_physics_frame: bool = true, print_dbg: bool = false) -> void:
	var output: String = str
	if include_physics_frame:
		output = "[" + str(Engine.get_physics_frames()) + "]	" + str
	if print_dbg:
		print_debug(output)
	else:
		print(output)
