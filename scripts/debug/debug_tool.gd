class_name DebugTool
extends CanvasLayer

@onready var tab_container: TabContainer = $PanelContainer/MarginContainer/TabContainer
@onready var pause_label: Label = $"PanelContainer/MarginContainer/TabContainer/Pause Logs/VBoxContainer/ScrollContainer/Label"
@onready var pause_header: Label = $"PanelContainer/MarginContainer/TabContainer/Pause Logs/VBoxContainer/Label"
@onready var running_label: Label = $"PanelContainer/MarginContainer/TabContainer/Running Logs/VBoxContainer/ScrollContainer/Label"

@onready var advance_timer: Timer = $AdvanceTimer
@onready var advance_allowed_timer: Timer = $AdvanceAllowedTimer

var paused: bool = false
var advance_one_tick: bool = false
var process_one_tick: bool = false
var waiting_for_next_advance: bool = false
var auto_advance_allowed: bool = false

var pause_log_array: PackedStringArray = []
var pause_log_array_idx: int = 0

@export var active: bool:
	get:
		return active
	set(value):
		self.visible = value
		active = value

@export var max_running_logs: int = 100
var running_log_array: PackedStringArray = []


func _ready() -> void:
	self.visible = active
	Signals.debug_pause.connect(_pause)
	Signals.debug_log.connect(_on_debug_log)
	Signals.debug_advance.connect(_on_debug_advance)
	Signals.debug_running_log.connect(_on_debug_running_log)
	_update_pause_label()
	_update_pause_header()
	_update_running_label()


func _on_debug_log(text: String) -> void:
	if not active:
		return
	pause_log_array.append(text)
	_update_pause_label()
	_update_pause_header()


func _on_debug_running_log(text: String) -> void:
	if not active:
		return
	running_log_array.append(text)
	if running_log_array.size() > max_running_logs:
		running_log_array.remove_at(0)
	_update_running_label()


func _on_debug_advance() -> void:
	if active and paused:
		get_tree().paused = false
		advance_one_tick = true
		process_one_tick = false


func _physics_process(_delta: float) -> void:
	if active and paused:
		if process_one_tick:
			get_tree().paused = true
			advance_one_tick = false
	
		if advance_one_tick:
			process_one_tick = true
		
		if Input.is_action_pressed("debug_right") and auto_advance_allowed:
			if not waiting_for_next_advance:
				advance_timer.start()
				waiting_for_next_advance = true


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("debug_pause"):
		_pause()
	
	if event.is_action_pressed("debug_right"):
		if paused:
			advance_allowed_timer.start()
			_reset_pause_log_array()
			Signals.debug_advance.emit()
	
	if event.is_action_released("debug_right"):
		auto_advance_allowed = false
		advance_allowed_timer.stop()
	
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


func _pause() -> void:
	paused = !paused
	get_tree().paused = !get_tree().paused
	if paused:
		Signals.debug_on.emit()
		pause_log_array_idx = 0
		tab_container.current_tab = 1
	else:
		Signals.debug_off.emit()
		tab_container.current_tab = 0


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
	pause_log_array_idx = 0
	pause_log_array = []


func _on_advance_timer_timeout() -> void:
	waiting_for_next_advance = false
	advance_timer.stop()
	Signals.debug_advance.emit()


func _on_advance_allowed_timer_timeout() -> void:
	auto_advance_allowed = true
