class_name DebugTool
extends CanvasLayer

@onready var tab_container: TabContainer = $PanelContainer/MarginContainer/TabContainer
@onready var pause_label: Label = $"PanelContainer/MarginContainer/TabContainer/Pause Logs/VBoxContainer/ScrollContainer/Label"
@onready var pause_header: Label = $"PanelContainer/MarginContainer/TabContainer/Pause Logs/VBoxContainer/Label"
@onready var running_label: Label = $"PanelContainer/MarginContainer/TabContainer/Running Logs/VBoxContainer/ScrollContainer/Label"

var paused: bool = false
var advance_one_tick: bool = false
var process_one_tick: bool = false

var pause_log_array: PackedStringArray = []
var pause_log_array_idx: int = 0

@export var max_running_logs: int = 100
var running_log_array: PackedStringArray = []


func _ready() -> void:
	Signals.debug_log.connect(_on_debug_log)
	Signals.debug_advance.connect(_on_debug_advance)
	Signals.debug_running_log.connect(_on_debug_running_log)
	_update_pause_label()
	_update_pause_header()
	_update_running_label()


func _on_debug_log(text: String) -> void:
	pause_log_array.append(text)
	_update_pause_label()
	_update_pause_header()


func _on_debug_running_log(text: String) -> void:
	running_log_array.append(text)
	if running_log_array.size() > max_running_logs:
		running_log_array.remove_at(0)
	_update_running_label()


func _on_debug_advance() -> void:
	if paused:
		get_tree().paused = false
		advance_one_tick = true
		process_one_tick = false


func _physics_process(delta: float) -> void:
	if paused:
		if process_one_tick:
			get_tree().paused = true
			advance_one_tick = false
	
		if advance_one_tick:
			process_one_tick = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_pause"):
		paused = !paused
		get_tree().paused = !get_tree().paused
		if paused:
			tab_container.current_tab = 1
		else:
			tab_container.current_tab = 0
	
	if event.is_action_pressed("debug_right"):
		if paused:
			_reset_pause_log_array()
			Signals.debug_advance.emit()
	
	if event.is_action_pressed("debug_up"):
		pause_log_array_idx += 1
		if (pause_log_array_idx + 1) > pause_log_array.size():
			pause_log_array_idx = pause_log_array.size() - 1
		
	if event.is_action_pressed("debug_down"):
		pause_log_array_idx -= 1
		if pause_log_array_idx < 0:
			pause_log_array_idx = 0
	
	_update_pause_header()
	_update_pause_label()


func _update_pause_header() -> void:
	var text: String = ""
	if pause_log_array.size() > 0:
		text = str(pause_log_array_idx + 1) + "/" + str(pause_log_array.size()) + " logs"
	else:
		text = "0/0 logs"
	if paused:
		text += " (paused)"
	else:
		text += " (running)"
	pause_header.text = text


func _update_pause_label() -> void:
	if pause_log_array.size() > 0:
		pause_label.text = pause_log_array[pause_log_array_idx]
	else:
		pause_label.text = "Awaiting logs..."


func _update_running_label() -> void:
	running_label.text = "\n".join(running_log_array)


func _reset_pause_log_array() -> void:
	pause_log_array = []
