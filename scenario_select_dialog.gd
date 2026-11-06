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

# Cấu hình 8 phe phái trong kịch bản Đại Việt 1611
const FACTIONS_1611 = [
	{
		"id": "LE_TRINH",
		"name": "Lê - Trịnh",
		"icon": "🔴",
		"full_name": "Đàng Ngoài (Lê - Trịnh)",
		"color": Color("#B71C1C"),
		"capital": "VNHN"
	},
	{
		"id": "NGUYEN",
		"name": "Chúa Nguyễn",
		"icon": "🔵",
		"full_name": "Đàng Trong (Chúa Nguyễn)",
		"color": Color("#0277BD"),
		"capital": "VNDN"
	},
	{
		"id": "MAC",
		"name": "Nhà Mạc",
		"icon": "🟣",
		"full_name": "Nhà Mạc (Cao Bằng)",
		"color": Color("#4A148C"),
		"capital": "VN04"
	},
	{
		"id": "CHUA_BAU",
		"name": "Chúa Bầu",
		"icon": "🟤",
		"full_name": "Chúa Bầu (Tuyên Quang)",
		"color": Color("#5D4037"),
		"capital": "VN07"
	},
	{
		"id": "HOA_ANH",
		"name": "Hoa Anh",
		"icon": "🟢",
		"full_name": "Tiểu Quốc Hoa Anh (Phú Yên)",
		"color": Color("#00695C"),
		"capital": "VN32"
	},
	{
		"id": "NAM_BAN",
		"name": "Nam Bàn",
		"icon": "🌸",
		"full_name": "Tiểu Quốc Nam Bàn (Tây Nguyên)",
		"color": Color("#AD1457"),
		"capital": "VN33"
	},
	{
		"id": "CHAMPA",
		"name": "Champa",
		"icon": "🟡",
		"full_name": "Champa (Panduranga)",
		"color": Color("#F9A825"),
		"capital": "VN34"
	},
	{
		"id": "CHAN_LAP",
		"name": "Chân Lạp",
		"icon": "🌿",
		"full_name": "Thủy Chân Lạp (Gia Định)",
		"color": Color("#558B2F"),
		"capital": "VNSG"
	}
]

var selected_scenario_id: String = "dai_viet_1611"
var selected_1611_faction: String = "LE_TRINH"
var faction_buttons: Dictionary = {}
var faction_selection_box: VBoxContainer = null

func _ready() -> void:
	# Chặn toàn bộ sự kiện chuột lọt xuyên xuống bản đồ hoặc các node phía dưới
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var gm = _get_game_manager()
	if gm and gm.selected_player_faction != "":
		selected_1611_faction = gm.selected_player_faction
	
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
	
	# Xây dựng giao diện chọn 8 phe phái kịch bản 1611
	_build_faction_selection_ui()
	
	select_scenario(selected_scenario_id)

func _build_faction_selection_ui() -> void:
	var vbox_parent = $CenterContainer/MainPanel/MarginContainer/VBoxContainer
	var action_bar = vbox_parent.get_node_or_null("ActionBar")
	if not vbox_parent or not action_bar:
		return
	
	faction_selection_box = VBoxContainer.new()
	faction_selection_box.name = "FactionSelectionBox"
	faction_selection_box.mouse_filter = Control.MOUSE_FILTER_STOP
	faction_selection_box.add_theme_constant_override("separation", 6)
	
	var title_lbl = Label.new()
	title_lbl.name = "FactionTitleLabel"
	title_lbl.text = "🚩 CHỌN PHE BẠN MUỐN ĐIỀU KHIỂN (8 PHE CÁT CỨ):"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 1.0))
	faction_selection_box.add_child(title_lbl)
	
	var grid = GridContainer.new()
	grid.name = "FactionGrid"
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.mouse_filter = Control.MOUSE_FILTER_STOP
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 6)
	faction_selection_box.add_child(grid)
	
	for fac in FACTIONS_1611:
		var fac_id = fac["id"]
		var btn = Button.new()
		btn.name = "BtnFac_" + fac_id
		btn.custom_minimum_size = Vector2(215, 30)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(func(): select_faction_1611(fac_id))
		grid.add_child(btn)
		faction_buttons[fac_id] = btn
		
	# Chèn ngay phía trên ActionBar
	vbox_parent.add_child(faction_selection_box)
	vbox_parent.move_child(faction_selection_box, action_bar.get_index())
	
	_update_faction_buttons_ui()

func select_faction_1611(fac_id: String) -> void:
	selected_1611_faction = fac_id
	var gm = _get_game_manager()
	if gm:
		gm.selected_player_faction = fac_id
		gm.player_faction = fac_id
	_update_faction_buttons_ui()
	_update_ui_state()

func _update_faction_buttons_ui() -> void:
	for fac in FACTIONS_1611:
		var fac_id = fac["id"]
		var btn = faction_buttons.get(fac_id) as Button
		if not btn:
			continue
		var is_sel = (fac_id == selected_1611_faction)
		var fac_color: Color = fac["color"]
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(5)
		style.set_content_margin_all(5)
		
		if is_sel:
			# Nổi bật viền vàng, nền đậm màu phe
			style.bg_color = Color(fac_color.r * 0.45 + 0.1, fac_color.g * 0.45 + 0.1, fac_color.b * 0.45 + 0.1, 0.98)
			style.border_color = Color(1.0, 0.88, 0.2, 1.0)
			style.set_border_width_all(2)
			btn.text = "👑 " + fac["name"]
			btn.add_theme_color_override("font_color", Color(1.0, 0.96, 0.8, 1.0))
			btn.add_theme_font_size_override("font_size", 12)
		else:
			style.bg_color = Color(0.10, 0.12, 0.16, 0.9)
			style.border_color = Color(fac_color.r, fac_color.g, fac_color.b, 0.6)
			style.set_border_width_all(1)
			btn.text = fac["icon"] + " " + fac["name"]
			btn.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92, 0.9))
			btn.add_theme_font_size_override("font_size", 11)
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

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
	
	if faction_selection_box:
		faction_selection_box.visible = (selected_scenario_id == "dai_viet_1611")
	
	if start_button:
		match selected_scenario_id:
			"dai_viet_1611":
				var fac_display = selected_1611_faction
				for fac in FACTIONS_1611:
					if fac["id"] == selected_1611_faction:
						fac_display = fac["name"]
						break
				start_button.text = "⚔️ BẮT ĐẦU: ĐẠI VIỆT 1611 (LÃNH ĐẠO: %s)" % fac_display
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
			var cap_prov = "VNHN"
			for fac in FACTIONS_1611:
				if fac["id"] == selected_1611_faction:
					cap_prov = fac.get("capital", "VNHN")
					break
			if gm:
				gm.current_mode = gm.MODE_SCENARIO_1611
				gm.selected_player_faction = selected_1611_faction
				gm.player_faction = selected_1611_faction
				gm.player_province_id = cap_prov
			if sm:
				var sc_path = "res://data/scenarios/scenario_1611.json"
				var sc_data = sm.load_scenario(sc_path)
				var cur_scene = get_tree().current_scene if get_tree() else null
				sm.apply_scenario(sc_data, cur_scene)
			print("ScenarioSelect: Đã kích hoạt kịch bản Đại Việt 1611 với phe: ", selected_1611_faction)
			emit_signal("scenario_started", "dai_viet_1611")
			close_dialog()
			_switch_to_campaign_map()
			
		"tu_quoc":
			if gm:
				gm.current_mode = gm.MODE_FOUR_FACTIONS
				gm.selected_player_faction = "Quân Đội Miền Bắc"
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
				gm.selected_player_faction = "Hà Nội"
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
	var gm = _get_game_manager()
	if gm and gm.selected_player_faction != "":
		selected_1611_faction = gm.selected_player_faction
	_update_faction_buttons_ui()
	select_scenario(selected_scenario_id)

func _switch_to_campaign_map() -> void:
	var tree = get_tree()
	if not tree:
		return
	if tree.current_scene and tree.current_scene.scene_file_path == "res://main.tscn":
		return
	tree.change_scene_to_file("res://main.tscn")
