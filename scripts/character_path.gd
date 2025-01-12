@tool
class_name CharacterPath
extends Path3D

signal enter_path(path: CharacterPath)
signal exit_path

@onready var area3d: Area3D = $Area3D

var _enabled: bool = true
@export var enabled: bool = true:
	get:
		return _enabled
	set(value):
		_enabled = value
		if area3d:
			area3d.monitoring = value
			area3d.monitorable = value


## Check for Area3D child
func _get_configuration_warnings() -> PackedStringArray:
	print("config warning running")
	var area3d_node_count := 0
	for child_node in get_children():
		if child_node is Area3D:
			area3d_node_count += 1
	
	if area3d_node_count != 1:
		return ["CharacterPath node should have one and only one Area3D child node."]
	else:
		return []


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_area_3d_body_entered(body: Node3D) -> void:
	if _enabled:
		enter_path.emit(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if _enabled:
		exit_path.emit()
