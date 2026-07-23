extends Node

func visibility_changed(new_value := 0) -> void:
	Settings.file.osc.visibility = new_value

func haptic_feedback_changed(new_value := 0) -> void:
	Settings.file.osc.haptic_feedback = new_value

func transition_visibility_changed(new_value := 0) -> void:
	Settings.file.osc.transition_visibility = new_value
