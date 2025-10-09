extends Level

@onready var character: CharacterBase = $Character1

func _on_walk_to_field_path_3d_in_path(path: CharacterPath) -> void:
	character.get_on_path(path)


func _on_walk_to_field_path_3d_leave_by_enter() -> void:
	character.get_off_path()


func _on_walk_to_field_path_3d_leave_by_exit() -> void:
	character.get_off_path()
