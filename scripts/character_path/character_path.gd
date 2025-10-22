@tool
class_name CharacterPath
extends Path3D

signal in_path(path: CharacterPath)

signal leave_by_enter
signal leave_by_exit

@onready var enter_out_area3d: Area3D = $EnterOutArea3D
@onready var enter_in_area3d: Area3D = $EnterInArea3D
@onready var exit_in_area3d: Area3D = $ExitInArea3D
@onready var exit_out_area3d: Area3D = $ExitOutArea3D

var previous_area: Enums.PathArea = Enums.PathArea.NONE

var _enabled: bool = true
@export var enabled: bool = true:
	get:
		return _enabled
	set(value):
		_enabled = value
		if enter_out_area3d:
			enter_out_area3d.monitoring = value
			enter_out_area3d.monitorable = value
		if enter_in_area3d:
			enter_in_area3d.monitoring = value
			enter_in_area3d.monitorable = value
		if exit_in_area3d:
			exit_in_area3d.monitoring = value
			exit_in_area3d.monitorable = value
		if exit_out_area3d:
			exit_out_area3d.monitoring = value
			exit_out_area3d.monitorable = value


## Check for Area3D child
func _get_configuration_warnings() -> PackedStringArray:
	var area3d_node_count := 0
	for child_node in get_children():
		if child_node is Area3D:
			area3d_node_count += 1
	
	if area3d_node_count != 4:
		return ["CharacterPath node should have 4 Area3D child node."]
	else:
		return []


#=======================================================
# AREA SIGNALS
#=======================================================
func _on_enter_out_area_3d_body_entered(_body: Node3D) -> void:
	if previous_area == Enums.PathArea.ENTER_IN:
		leave_by_enter.emit()
		previous_area = Enums.PathArea.NONE
	else:
		previous_area = Enums.PathArea.ENTER_OUT


func _on_enter_in_area_3d_body_entered(_body: Node3D) -> void:
	if previous_area == Enums.PathArea.ENTER_OUT:
		in_path.emit(self)
		previous_area = Enums.PathArea.NONE
	else:
		previous_area = Enums.PathArea.ENTER_IN


func _on_exit_in_area_3d_body_entered(_body: Node3D) -> void:
	if previous_area == Enums.PathArea.EXIT_OUT:
		in_path.emit(self)
		previous_area = Enums.PathArea.NONE
	else:
		previous_area = Enums.PathArea.EXIT_IN


func _on_exit_out_area_3d_body_entered(_body: Node3D) -> void:
	if previous_area == Enums.PathArea.EXIT_IN:
		leave_by_exit.emit()
		previous_area = Enums.PathArea.NONE
	else:
		previous_area = Enums.PathArea.EXIT_OUT
