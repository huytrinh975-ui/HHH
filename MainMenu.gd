extends Control

@onready var btn_four_factions: Button = $CenterContainer/VBoxContainer/ModesBox/ModeFourFactionsButton
@onready var btn_63_warlords: Button = $CenterContainer/VBoxContainer/ModesBox/Mode63WarlordsButton
@onready var btn_quit: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	if btn_four_factions:
		btn_four_factions.pressed.connect(_on_four_factions_selected)
	if btn_63_warlords:
		btn_63_warlords.pressed.connect(_on_63_warlords_selected)
	if btn_quit:
		btn_quit.pressed.connect(func(): get_tree().quit())

func _on_four_factions_selected() -> void:
	GameManager.current_mode = GameManager.MODE_FOUR_FACTIONS
	get_tree().change_scene_to_file("res://FactionSelect.tscn")

func _on_63_warlords_selected() -> void:
	GameManager.current_mode = GameManager.MODE_63_WARLORDS
	get_tree().change_scene_to_file("res://FactionSelect.tscn")
