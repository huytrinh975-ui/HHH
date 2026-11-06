extends Control

signal scenario_started(scenario_id: String)
signal scenario_selected(scenario_id: String)
signal dialog_closed()

@export var is_modal: bool = true

@onready var card_1611: PanelContainer = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/Card1611
@onready var card_tuquoc: PanelContainer = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuQuoc
@onready var card_tuchien: PanelContainer = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuChien

@onready var btn_select_1611: Button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/Card1611/MarginContainer/VBoxContainer/SelectButton
@onready var btn_select_tuquoc: Button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuQuoc/MarginContainer/VBoxContainer/SelectButton
@onready var btn_select_tuchien: Button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuChien/MarginContainer/VBoxContainer/SelectButton

@onready var status_1611: Label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/Card1611/MarginContainer/VBoxContainer/StatusLabel
@onready var status_tuquoc: Label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuQuoc/MarginContainer/VBoxContainer/StatusLabel
@onready var status_tuchien: Label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CardsContainer/CardTuChien/MarginContainer/VBoxContainer/StatusLabel

@onready var start_button: Button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/ActionBar/StartButton
@onready var close_button: Button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/ActionBar/CloseButton

var selected_scenario_id: String = "dai_viet_1611"

func _ready() -> void:
	# Chặn toàn bộ sự kiện chuột lọt xuyên xuống bản đồ hoặc các node phía dưới
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if btn_select_1611:
		btn_select_1611.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_select_1611.pressed.connect(func(): select_scenario("dai_viet_1611"))
	if btn_select_tuquoc:
		btn_select_tuquoc.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_select_tuquoc.pressed.connect(func(): select_scenario("tu_quoc"))
	if btn_select_tuchien:
		btn_select_tuchien.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_select_tuchien.pressed.connect(func(): select_scenario("tu_chien"))
	
	# Hỗ trợ click trực tiếp lên Card để chọn
	if card_1611:
		card_1611.mouse_filter = Control.MOUSE_FILTER_STOP
		card_1611.gui_input.connect(func(event): _on_card_gui_input(event, "dai_viet_1611"))
	if card_tuquoc:
		card_tuquoc.mouse_filter = Control.MOUSE_FILTER_STOP
		card_tuquoc.gui_input.connect(func(event): _on_card_gui_input(event, "tu_quoc"))
	if card_tuchien:
		card_tuchien.mouse_filter = Control.MOUSE_FILTER_STOP
		card_tuchien.gui_input.connect(func(event): _on_card_gui_input(event, "tu_chien"))
	
	if start_button:
		start_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not start_button.pressed.is_connected(_on_start_button_pressed):
			start_button.pressed.connect(_on_start_button_pressed)
	
	if close_button:
		close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not close_button.pressed.is_connected(close_dialog):
			close_button.pressed.connect(close_dialog)
		close_button.visible = is_modal
	
	select_scenario(selected_scenario_id)

func _on_card_gui_input(event: InputEvent, sc_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		select_scenario(sc_id)
		if event.double_click:
			_on_start_button_pressed()

func select_scenario(id: String) -> void:
	selected_scenario_id = id
	emit_signal("scenario_selected", id)
	_update_ui_state()

func _update_ui_state() -> void:
	_update_card_style(card_1611, btn_select_1611, status_1611, selected_scenario_id == "dai_viet_1611")
	_update_card_style(card_tuquoc, btn_select_tuquoc, status_tuquoc, selected_scenario_id == "tu_quoc")
	_update_card_style(card_tuchien, btn_select_tuchien, status_tuchien, selected_scenario_id == "tu_chien")
	
	if start_button:
		match selected_scenario_id:
			"dai_viet_1611":
				start_button.text = "⚔️ BẮT ĐẦU: ĐẠI VIỆT 1611"
			"tu_quoc":
				start_button.text = "⚔️ BẮT ĐẦU: TỨ QUỐC GIAO TRANH"
			"tu_chien":
				start_button.text = "⚔️ BẮT ĐẦU: TỬ CHIẾN"

func _update_card_style(card: PanelContainer, btn: Button, status: Label, is_selected: bool) -> void:
	if not card:
		return
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_content_margin_all(14)
	
	if is_selected:
		style.bg_color = Color(0.14, 0.17, 0.25, 0.98)
		style.border_color = Color(1.0, 0.84, 0.0, 1.0) # Vàng ánh kim nổi bật
		style.set_border_width_all(2)
		if btn:
			btn.text = "✔ ĐÃ CHỌN"
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0.85, 0.68, 0.12, 1.0)
			btn_style.border_color = Color(1.0, 0.92, 0.5, 1.0)
			btn_style.set_border_width_all(1)
			btn_style.set_corner_radius_all(4)
			btn_style.content_margin_top = 4
			btn_style.content_margin_bottom = 4
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.add_theme_stylebox_override("hover", btn_style)
			btn.add_theme_color_override("font_color", Color(0.1, 0.08, 0.02, 1.0))
		if status:
			status.text = "🟢 ĐANG CHỌN"
			status.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1.0))
	else:
		style.bg_color = Color(0.08, 0.09, 0.13, 0.95)
		style.border_color = Color(0.24, 0.27, 0.36, 0.8)
		style.set_border_width_all(1)
		if btn:
			btn.text = "Chọn"
			var btn_style = StyleBoxFlat.new()
			btn_style.bg_color = Color(0.18, 0.21, 0.28, 1.0)
			btn_style.border_color = Color(0.35, 0.40, 0.50, 0.8)
			btn_style.set_border_width_all(1)
			btn_style.set_corner_radius_all(4)
			btn_style.content_margin_top = 4
			btn_style.content_margin_bottom = 4
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95, 1.0))
		if status:
			status.text = ""
	
	card.add_theme_stylebox_override("panel", style)

func _get_game_manager() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("GameManager")
	return null

func _get_scenario_manager() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("ScenarioManager")
	return null

func _on_start_button_pressed() -> void:
	var gm = _get_game_manager()
	var sm = _get_scenario_manager()
	
	match selected_scenario_id:
		"dai_viet_1611":
			if gm:
				gm.current_mode = gm.MODE_SCENARIO_1611
				gm.player_faction = "LE_TRINH"
				gm.player_province_id = "VNHN"
			if sm:
				var sc_path = "res://data/scenarios/scenario_1611.json"
				var sc_data = sm.load_scenario(sc_path)
				sm.apply_scenario(sc_data)
			print("ScenarioSelect: Đã kích hoạt kịch bản Đại Việt 1611!")
			emit_signal("scenario_started", "dai_viet_1611")
			close_dialog()
			_switch_to_campaign_map()
			
		"tu_quoc":
			if gm:
				gm.current_mode = gm.MODE_FOUR_FACTIONS
				gm.player_faction = "Quân Đội Miền Bắc"
				gm.player_province_id = "VNHN"
			if sm:
				sm.clear_active_scenario()
			print("ScenarioSelect: Đã kích hoạt kịch bản Tứ Quốc Giao Tranh!")
			emit_signal("scenario_started", "tu_quoc")
			close_dialog()
			_switch_to_campaign_map()
			
		"tu_chien":
			if gm:
				gm.current_mode = gm.MODE_63_WARLORDS
				gm.player_faction = "Hà Nội"
				gm.player_province_id = "VNHN"
			if sm:
				sm.clear_active_scenario()
			print("ScenarioSelect: Đã kích hoạt kịch bản Tử Chiến!")
			emit_signal("scenario_started", "tu_chien")
			close_dialog()
			_switch_to_campaign_map()

func close_dialog() -> void:
	emit_signal("dialog_closed")
	if is_modal:
		visible = false

func open_dialog() -> void:
	visible = true
	select_scenario(selected_scenario_id)

func _switch_to_campaign_map() -> void:
	var tree = get_tree()
	if not tree:
		return
	if tree.current_scene and tree.current_scene.scene_file_path == "res://main.tscn":
		return
	tree.change_scene_to_file("res://main.tscn")
