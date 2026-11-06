extends Control

@onready var scenario_dialog: Control = $ScenarioSelectDialog

func _ready() -> void:
	if scenario_dialog:
		scenario_dialog.is_modal = false
		if scenario_dialog.close_button:
			scenario_dialog.close_button.text = "🚪 Thoát Game"
			scenario_dialog.close_button.visible = true
			if scenario_dialog.close_button.pressed.is_connected(scenario_dialog.close_dialog):
				scenario_dialog.close_button.pressed.disconnect(scenario_dialog.close_dialog)
			scenario_dialog.close_button.pressed.connect(func(): get_tree().quit())
