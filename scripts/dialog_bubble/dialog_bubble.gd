class_name DialogBubble
extends CanvasLayer

@onready var label: Label = $PanelContainer/HBoxContainer/Label
@onready var textureRect: TextureRect = $PanelContainer/HBoxContainer/MarginContainer/TextureRect
@onready var panel: PanelContainer = $PanelContainer
@onready var path: Path2D = $PanelContainer/Path2D


@export_group("Camera Controller")
@export var camera_controller: CameraController
var camera: Camera3D


@export_group("Player properties")
# The avatar of the player
@export var texture: Texture2D
# The player emitting dialog bubbles
@export var player: Player


@export_group("Path properties")
@export var x_path_offset: float = 12.0
@export var y_path_offset: float = 10.0


@export_group("Bubble positioning properties")
@export var lerp_factor_x: float = 1.0
@export var lerp_factor_y: float = 1.0

@export var offset_x: float = 0.0
@export var offset_y: float = 0.0


func _ready() -> void:
	textureRect.texture = texture
	camera = camera_controller.camera


#=======================================================
# POPS UP STATE
#=======================================================
func _on_pops_up_state_entered() -> void:
	set_to_player_position()


func _on_pops_up_state_processing(delta: float) -> void:
	track_player_position(delta)
	sync_path_to_panel()


#=======================================================
# LINGERS STATE
#=======================================================
func _on_lingers_state_processing(delta: float) -> void:
	track_player_position(delta)


#=======================================================
# POPS OUT STATE
#=======================================================
func _on_pops_out_state_processing(delta: float) -> void:
	track_player_position(delta)
	sync_path_to_panel()



#=======================================================
# INACTIVE STATE
#=======================================================
func _on_inactive_state_entered() -> void:
	self.hide()


func _on_inactive_state_exited() -> void:
	self.show()


#=======================================================
# UTILITIES
#=======================================================
func sync_path_to_panel() -> void:
	path.curve.set_point_position(0, Vector2(panel.size.x + x_path_offset, 0))
	
	path.curve.set_point_position(1, Vector2(panel.size.x + x_path_offset, panel.size.y))
	path.curve.set_point_out(1, Vector2(0, y_path_offset))
	
	path.curve.set_point_position(2, Vector2(panel.size.x, panel.size.y + y_path_offset))
	
	path.curve.set_point_position(3, Vector2(0, panel.size.y + y_path_offset))
	
	path.curve.set_point_position(4, Vector2(-x_path_offset, panel.size.y))
	path.curve.set_point_in(4, Vector2(0, y_path_offset))
	
	path.curve.set_point_position(5, Vector2(-x_path_offset, 0))


func track_player_position(delta: float) -> void:
	var target_pos_vec: Vector2 = target_bubble_position()
	
	panel.position.x = lerp(panel.position.x, target_pos_vec.x, lerp_factor_x * delta)
	panel.position.y = lerp(panel.position.y, target_pos_vec.y, lerp_factor_y * delta)


func target_bubble_position() -> Vector2:
	# Unpack the player position in the viewport
	var unprojected_vec2: Vector2 = camera.unproject_position(player.position)
	var unp_x: float = unprojected_vec2.x + offset_x
	var unp_y: float = unprojected_vec2.y + offset_y

	# Unpack the viewport size
	var viewport_size_vec2: Vector2 = get_viewport().size
	var vp_x: float = viewport_size_vec2.x
	var vp_y: float = viewport_size_vec2.y
	
	var target_position_x: float = unp_x
	var target_position_y: float = unp_y 

	# restrict the dialog box within the viewport along the x-axis
	if unp_x < 2*x_path_offset:
		target_position_x = 2*x_path_offset
	if unp_x > (vp_x - 2*x_path_offset - panel.size.x):
		target_position_x = vp_x - 2*x_path_offset - panel.size.x
	
	# restrict the dialog box within the viewport along the y-axis
	if unp_y < 2*y_path_offset:
		target_position_y = 2*y_path_offset
	if unp_y > (vp_y - 2*y_path_offset - panel.size.y):
		target_position_y = vp_y - 2*y_path_offset - panel.size.y
		
	return Vector2(target_position_x, target_position_y)


func set_to_player_position() -> void:
	panel.position = target_bubble_position() + Vector2(offset_x, offset_y)
