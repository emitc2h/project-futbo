class_name DialogBubble
extends CanvasLayer

@onready var state: StateChart = $StateChart
@onready var label: Label = $PanelContainer/HBoxContainer/Label
@onready var textureRect: TextureRect = $PanelContainer/HBoxContainer/MarginContainer/TextureRect
@onready var panel: PanelContainer = $PanelContainer
@onready var path: Path2D = $PanelContainer/Path2D
@onready var line: Line2D = $Line2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer


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
@export var line_fraction: float = 0.55
@export var line_point0_x_offset: float = -8.0

var text_buffer: String = ""
var text_buffer_length: int = 0
var text_write_time: float = 0.0
var text_write_interval: float = 0.006


func _ready() -> void:
	label.text = text_buffer
	camera = camera_controller.camera


#=======================================================
# POPS UP STATE
#=======================================================
func _on_pops_up_state_entered() -> void:
	_set_to_player_position()
	_sync_path_to_panel()
	_sync_line()
	animation_player.play("pop up")


func _on_pops_up_state_processing(delta: float) -> void:
	_track_player_position(delta)
	_sync_path_to_panel()
	_sync_line()


#=======================================================
# WRITE STATE
#=======================================================
func _on_write_state_entered() -> void:
	self.label.text = self.text_buffer
	self.label.visible_characters = 0
	self.text_write_time = 0.0


func _on_write_state_processing(delta: float) -> void:
	_track_player_position(delta)
	_sync_path_to_panel()
	_sync_line()
	if self.label.visible_characters < self.text_buffer_length:
		if self.text_write_time > self.text_write_interval:
			self._write_one_more_char()
			self.text_write_time = 0.0
		else:
			self.text_write_time += delta
	else:
		state.send_event("write to lingers")


#=======================================================
# LINGERS STATE
#=======================================================
func _on_lingers_state_entered() -> void:
	timer.start()


func _on_lingers_state_processing(delta: float) -> void:
	_track_player_position(delta)
	_sync_path_to_panel()
	_sync_line()


#=======================================================
# POPS OUT STATE
#=======================================================
func _on_pops_out_state_entered() -> void:
	animation_player.play("pop out")


func _on_pops_out_state_processing(delta: float) -> void:
	_track_player_position(delta)
	_sync_path_to_panel()
	_sync_line()


#=======================================================
# INACTIVE STATE
#=======================================================
func _on_inactive_state_entered() -> void:
	self.hide()


func _on_inactive_state_exited() -> void:
	self.show()


#=======================================================
# SIGNALS
#=======================================================
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"pop up":
			state.send_event("pops up to write")
		"pop out":
			state.send_event("pops out to inactive")


func _on_timer_timeout() -> void:
	state.send_event("lingers to pops out")


#=======================================================
# UTILITIES
#=======================================================
## Wrap the panel with the path that constrains the end of the speech line
func _sync_path_to_panel() -> void:
	path.curve.set_point_position(0, Vector2(panel.size.x + x_path_offset, 0))
	
	path.curve.set_point_position(1, Vector2(panel.size.x + x_path_offset, panel.size.y))
	path.curve.set_point_out(1, Vector2(0, y_path_offset))
	
	path.curve.set_point_position(2, Vector2(panel.size.x, panel.size.y + y_path_offset))
	
	path.curve.set_point_position(3, Vector2(0, panel.size.y + y_path_offset))
	
	path.curve.set_point_position(4, Vector2(-x_path_offset, panel.size.y))
	path.curve.set_point_in(4, Vector2(0, y_path_offset))
	
	path.curve.set_point_position(5, Vector2(-x_path_offset, 0))


## Moves the bubble with the player, but with a smooth delay
func _track_player_position(delta: float) -> void:
	var target_pos_vec: Vector2 = _target_bubble_position()
	
	panel.position.x = lerp(panel.position.x, target_pos_vec.x, lerp_factor_x * delta)
	panel.position.y = lerp(panel.position.y, target_pos_vec.y, lerp_factor_y * delta)


## Computes where the bubble is aiming to be, before smoothing is applied
func _target_bubble_position() -> Vector2:
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


## Initializes the bubble position to the player
func _set_to_player_position() -> void:
	panel.position = _target_bubble_position()


## Moves the speech line where it should be
func _sync_line() -> void:
	# Compute where the line should try to point to
	var unp_player_pos: Vector2 = camera.unproject_position(player.global_position) \
		+ Vector2(0.0, line_fraction*offset_y)
	
	line.set_point_position(0, unp_player_pos)
	# Computes the position of the line on the path around the dialog panel
	# takes into account that the unprojected position is in global coords while the
	# get_closest_point methods works in local coords
	# Bake in a little x offset to make the line diagonal
	line.set_point_position(1, path.curve.get_closest_point(unp_player_pos - Vector2(line_point0_x_offset, 0.0) - panel.position) + panel.position)


## Avatar control
func _populate_avatar() -> void:
	self.textureRect.texture = texture


func _vacate_avatar() -> void:
	self.textureRect.texture = null


func _write_one_more_char() -> void:
	self.label.visible_characters += 1


func _remove_one_more_char() -> void:
	if self.label.visible_characters > 0:
		self.label.visible_characters -= 1

#=======================================================
# CONTROLS
#=======================================================
func pop_up(text: String, duration: float = 3.0, text_write_time_interval: float = 0.006) -> void:
	self.text_buffer = text
	self.text_buffer_length = self.text_buffer.length()
	self.timer.wait_time = duration
	self.text_write_interval = text_write_time_interval
	state.send_event("inactive to pops up")
