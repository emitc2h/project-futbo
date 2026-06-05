extends Node

func log(input: String, include_physics_frame: bool = true, print_dbg: bool = false) -> void:
	var output: String = input
	if include_physics_frame:
		output = "[" + str(Engine.get_physics_frames()) + "]	" + input
	if print_dbg:
		print_debug(output)
	else:
		print(output)
