extends Level

@onready var character: CharacterBase = $Character1

func _on_walk_to_field_path_3d_in_path(path: CharacterPath) -> void:
	print("Get on path")
	character.get_on_path(path)


func _on_walk_to_field_path_3d_leave_by_enter() -> void:
	print("Get off path")
	character.get_off_path()


func _on_walk_to_field_path_3d_leave_by_exit() -> void:
	print("Get off path")
	character.get_off_path()
