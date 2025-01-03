class_name PauseMenu
extends CanvasLayer

@onready var continue_button: Button = $GridContainer/ContinueButton

#=======================================================
# SIGNALS
#=======================================================
func _on_continue_button_pressed() -> void:
	Signals.unpause.emit()


func _on_exit_to_main_button_pressed() -> void:
	Signals.exit_to_main_menu.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


#=======================================================
# UTILITIES
#=======================================================
func continue_button_grab_focus() -> void:
	continue_button.grab_focus()
