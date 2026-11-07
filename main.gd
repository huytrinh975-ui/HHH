extends Node2D

# Phe mà người chơi đang điều khiển
@export var player_faction: String = "Quân Đội Miền Bắc"

# Node tham chiếu
@onready var map_sprite: Sprite2D = $Test
@onready var province_panel: Panel = $UI/ProvincePanel
@onready var name_label: Label = $UI/ProvincePanel/VBoxContainer/NameLabel
@onready var nation_label: Label = $UI/ProvincePanel/VBoxContainer/NationLabel
@onready var faction_label: Label = $UI/ProvincePanel/VBoxContainer/FactionLabel
@onready var population_label: Label = $UI/ProvincePanel/VBoxContainer/PopulationLabel
@onready var demographics_label: Label = $UI/ProvincePanel/VBoxContainer/DemographicsLabel
@onready var manpower_label: Label = $UI/ProvincePanel/VBoxContainer/ManpowerLabel
@onready var income_label: Label = $UI/ProvincePanel/VBoxContainer/IncomeLabel
@onready var troops_label: Label = $UI/ProvincePanel/VBoxContainer/TroopsLabel
@onready var recruit_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitButton
@onready var recruit_container: VBoxContainer = $UI/ProvincePanel/VBoxContainer/RecruitContainer
@onready var recruit_cost_label: Label = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitHeader/RecruitCostLabel
@onready var recruit_slider: HSlider = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitSlider
@onready var recruit_preset_25_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitPresetHBox/RecruitPreset25Button
@onready var recruit_preset_50_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitPresetHBox/RecruitPreset50Button
@onready var recruit_preset_75_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitPresetHBox/RecruitPreset75Button
@onready var recruit_preset_max_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitContainer/RecruitPresetHBox/RecruitPresetMaxButton
@onready var confirm_recruit_button: Button = $UI/ProvincePanel/VBoxContainer/RecruitContainer/ConfirmRecruitButton
@onready var action_buttons_hbox: HBoxContainer = $UI/ProvincePanel/VBoxContainer/ActionButtonsHBox
@onready var move_button: Button = $UI/ProvincePanel/VBoxContainer/ActionButtonsHBox/MoveButton
@onready var sweep_button: Button = $UI/ProvincePanel/VBoxContainer/ActionButtonsHBox/SweepButton
var cancel_march_button: Button = null
@onready var dispatch_container: VBoxContainer = $UI/ProvincePanel/VBoxContainer/DispatchContainer
@onready var dispatch_count_label: Label = $UI/ProvincePanel/VBoxContainer/DispatchContainer/DispatchHeader/DispatchCountLabel
@onready var troop_slider: HSlider = $UI/ProvincePanel/VBoxContainer/DispatchContainer/TroopSlider
@onready var preset_25_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset25Button
@onready var preset_50_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset50Button
@onready var preset_75_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset75Button
@onready var preset_100_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset100Button
@onready var confirm_target_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/ConfirmTargetButton

# Node Giải tán quân (Disband UI)
@onready var disband_container: VBoxContainer = $UI/ProvincePanel/VBoxContainer/DisbandContainer
@onready var disband_title_label: Label = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandHeader/DisbandTitleLabel
@onready var disband_count_label: Label = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandHeader/DisbandCountLabel
@onready var disband_slider: HSlider = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandSlider
@onready var disband_preset_25_button: Button = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandPresetHBox/DisbandPreset25Button
@onready var disband_preset_50_button: Button = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandPresetHBox/DisbandPreset50Button
@onready var disband_preset_75_button: Button = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandPresetHBox/DisbandPreset75Button
@onready var disband_preset_100_button: Button = $UI/ProvincePanel/VBoxContainer/DisbandContainer/DisbandPresetHBox/DisbandPreset100Button
@onready var confirm_disband_button: Button = $UI/ProvincePanel/VBoxContainer/DisbandContainer/ConfirmDisbandButton

# Node Ngoại giao (Diplomacy UI)
@onready var diplomacy_container: VBoxContainer = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer
@onready var dip_faction_header: Label = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipFactionHeader
@onready var dip_relation_score_label: Label = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipRelationScoreLabel
@onready var dip_relation_bar: ProgressBar = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipRelationBar
@onready var dip_top_friends_label: Label = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipTopFriendsLabel
@onready var dip_top_enemies_label: Label = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipTopEnemiesLabel
@onready var dip_improve_button: Button = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipActionsGrid/DipImproveButton
@onready var dip_insult_button: Button = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipActionsGrid/DipInsultButton
@onready var dip_access_button: Button = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipActionsGrid/DipAccessButton
@onready var dip_alliance_button: Button = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipActionsGrid/DipAllianceButton
@onready var dip_war_button: Button = $UI/ProvincePanel/VBoxContainer/DiplomacyContainer/DipWarButton
@onready var menu_button: Button = $UI/MenuButton
@onready var notification_panel: PanelContainer = $UI/NotificationPanel
@onready var notification_label: Label = $UI/NotificationPanel/MarginContainer/NotificationLabel

# Node điều khiển thời gian và tài nguyên
@onready var gold_label: Label = $UI/TimePanel/VBoxContainer/TopRow/GoldLabel
@onready var date_label: Label = $UI/TimePanel/VBoxContainer/TopRow/DateLabel
@onready var pause_button: Button = $UI/TimePanel/VBoxContainer/BottomRow/PauseButton
@onready var speed_1_button: Button = $UI/TimePanel/VBoxContainer/BottomRow/Speed1Button
@onready var speed_2_button: Button = $UI/TimePanel/VBoxContainer/BottomRow/Speed2Button
@onready var speed_3_button: Button = $UI/TimePanel/VBoxContainer/BottomRow/Speed3Button

var provinces_data: Array = []
var provinces_by_id: Dictionary = {}        # Lưu [id_str -> prov] để tra cứu O(1)
var provinces_by_id_color: Dictionary = {}
var provinces_by_id_num: Dictionary = {}   # Lưu [id_int -> prov] để tra cứu O(1)
var map_image: Image           # Image hiển thị động (cập nhật đổi màu khi chiếm đóng)
var base_display_image: Image  # Image gốc bất biến lưu màu và đường viền của VN_display_map.png
var id_map_image: Image        # Image gốc lưu mã màu ID bất biến (dùng cho Color-picking và phân định ranh giới)
var province_pixel_cache: Dictionary = {} # Lưu tập điểm ảnh của từng tỉnh để repaint tức thì
var selected_province: Dictionary = {}

# Quản lý nhãn số quân trên bản đồ
var province_labels: Dictionary = {} # Lưu [prov_id -> Label]
var province_markers: Dictionary = {} # Lưu [prov_id -> Node2D marker root]
var markers_container: Node2D = null

# Quản lý hành quân thời gian thực
var armies_container: Node2D = null
var active_armies: Array = []

# Bảng màu đại diện cho các phe phái
var faction_colors: Dictionary = {
	"Quân Đội Miền Bắc": Color("#d32f2f"),       # Đỏ
	"Liên Minh Miền Trung": Color("#2e7d32"),     # Xanh lá
	"Quân Phiệt Cao Nguyên": Color("#f57f17"),    # Vàng cam
	"Lực Lượng Miền Nam": Color("#1565c0")       # Xanh dương
}

# ==============================================================================
# HỆ THỐNG THỜI GIAN VÀ KINH TẾ (REAL-TIME WITH PAUSE)
# ==============================================================================
var current_day: int = 1
var current_month: int = 1
var current_year: int = 1611

var is_paused: bool = false
var game_speed: int = 1 # 1, 2, 3
var day_timer: float = 0.0

const SPEED_DURATIONS = {
	1: 1.0,   # 1s = 1 ngày
	2: 0.5,   # 0.5s = 1 ngày
	3: 0.2    # 0.2s = 1 ngày
}

# Kinh tế: Tiền vàng
var player_gold: int = 100
const COST_PER_TROOP: int = 2          # Chi phí mỗi lính = 2 Vàng
const BASE_INCOME_PER_PROVINCE: int = 10 # Thuế cơ bản = 10 đồng/tỉnh/tháng
const UPKEEP_PER_TROOP: float = 0.1    # Chi phí duy trì quân đội = 0.1 đồng/lính/tháng
const RECRUIT_COST: int = 20           # Chi phí cũ (+10 lính)

# Trạng thái di chuyển quân & Double-click
var is_move_mode: bool = false
var move_source_province: Dictionary = {}
var selected_troop_count: int = 0
var notify_timer: SceneTreeTimer = null

# Cơ chế Double-click nhanh (trong vòng 0.35s)
var potential_double_click_source: Dictionary = {}
var last_click_prov_id: String = ""
var last_click_timestamp: float = 0.0

# Phân biệt chạm nhẹ (click chọn tỉnh) với vuốt bản đồ (pan camera)
var mouse_press_pos: Vector2 = Vector2.ZERO
var is_left_mouse_down: bool = false
var was_godot_double_click: bool = false

# ==============================================================================
# CHẾ ĐỘ SẢNH CHỌN QUỐC GIA (LOBBY SELECTION)
# ==============================================================================
var is_lobby_mode: bool = true
var lobby_selected_faction: String = ""
var lobby_selected_province: Dictionary = {}

var lobby_panel: PanelContainer = null
var lobby_faction_label: Label = null
var lobby_capital_label: Label = null
var lobby_confirm_button: Button = null

func _ready() -> void:
	# Cập nhật trạng thái Lobby và phe người chơi từ GameManager
	if GameManager:
		is_lobby_mode = GameManager.is_lobby_mode
		if not is_lobby_mode:
			if GameManager.selected_player_faction != "":
				player_faction = GameManager.selected_player_faction
			elif GameManager.player_faction != "":
				player_faction = GameManager.player_faction
	
	if is_lobby_mode:
		is_paused = true
		if pause_button:
			pause_button.text = "▶ Tiếp tục"
	
	load_provinces_json()
	
	if map_sprite and map_sprite.texture:
		map_image = map_sprite.texture.get_image()
		base_display_image = map_image.duplicate() # Giữ bản sao vĩnh viễn của VN_display_map.png
		# Đọc ảnh ID qua Resource Loader (Chạy chuẩn 100% trên cả Web, PC, Mobile)
		var id_tex = load("res://VN_id_map.png") as Texture2D
		if id_tex:
			id_map_image = id_tex.get_image()
		else:
			id_map_image = map_image.duplicate()
			
		map_sprite.texture = ImageTexture.create_from_image(map_image)
		
		# Gán texture của ID map cho Shader selection
		if map_sprite.material is ShaderMaterial and id_tex:
			map_sprite.material.set_shader_parameter("id_map_texture", id_tex)
		
		cache_province_pixels()
		
		# Nếu là chế độ 63 xứ quân, tô màu tất cả 63 tỉnh theo màu phe độc lập
		if GameManager and GameManager.current_mode == GameManager.MODE_63_WARLORDS:
			for prov in provinces_data:
				var fac_col = faction_colors.get(prov["faction"], Color.WHITE)
				var orig_color = Color.from_string(prov.get("original_color", prov["color"]), Color.BLACK)
				var target_b = int(round(orig_color.b * 255.0))
				if province_pixel_cache.has(target_b):
					for pt in province_pixel_cache[target_b]:
						var base_c = base_display_image.get_pixel(pt.x, pt.y)
						if max(base_c.r, max(base_c.g, base_c.b)) < 0.255:
							continue
						map_image.set_pixel(pt.x, pt.y, fac_col)
			if map_sprite.texture is ImageTexture:
				map_sprite.texture.update(map_image)
			else:
				map_sprite.texture = ImageTexture.create_from_image(map_image)
	
	# Khởi tạo vùng chứa các đơn vị hành quân thời gian thực
	armies_container = Node2D.new()
	armies_container.name = "ArmiesContainer"
	armies_container.z_index = 5
	map_sprite.add_child(armies_container)
	
	spawn_troop_markers()
	hide_province_panel()
	set_province_selection_shader(Color(0, 0, 0, 0), false)
	
	# Kết nối sự kiện nút tỉnh & điều quân chi tiết
	if menu_button:
		menu_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	if recruit_button:
		recruit_button.pressed.connect(_on_recruit_button_pressed)
	if recruit_slider:
		recruit_slider.value_changed.connect(_on_recruit_slider_value_changed)
	if recruit_preset_25_button:
		recruit_preset_25_button.pressed.connect(func(): set_recruit_preset(0.25))
	if recruit_preset_50_button:
		recruit_preset_50_button.pressed.connect(func(): set_recruit_preset(0.50))
	if recruit_preset_75_button:
		recruit_preset_75_button.pressed.connect(func(): set_recruit_preset(0.75))
	if recruit_preset_max_button:
		recruit_preset_max_button.pressed.connect(func(): set_recruit_preset(1.00))
	if confirm_recruit_button:
		confirm_recruit_button.pressed.connect(_on_confirm_recruit_pressed)
	if move_button:
		move_button.pressed.connect(_on_move_button_pressed)
	if sweep_button:
		sweep_button.pressed.connect(_on_sweep_button_pressed)
	if action_buttons_hbox:
		cancel_march_button = Button.new()
		cancel_march_button.name = "CancelMarchButton"
		cancel_march_button.text = "⛔ Hủy hành quân"
		cancel_march_button.visible = false
		cancel_march_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cancel_march_button.add_theme_font_size_override("font_size", 11)
		cancel_march_button.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
		
		var cancel_style = StyleBoxFlat.new()
		cancel_style.bg_color = Color(0.45, 0.1, 0.1, 0.9)
		cancel_style.border_color = Color(0.9, 0.35, 0.35, 0.85)
		cancel_style.set_border_width_all(1)
		cancel_style.set_corner_radius_all(4)
		cancel_march_button.add_theme_stylebox_override("normal", cancel_style)
		
		cancel_march_button.pressed.connect(_on_cancel_march_button_pressed)
		action_buttons_hbox.add_child(cancel_march_button)

		# Nút Giải tán quân (Disband Troops)
		var disband_button = Button.new()
		disband_button.name = "DisbandButton"
		disband_button.text = "🗑️ Giải tán quân"
		disband_button.visible = false
		disband_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		disband_button.add_theme_font_size_override("font_size", 11)
		disband_button.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))

		var disband_style = StyleBoxFlat.new()
		disband_style.bg_color = Color(0.5, 0.2, 0.1, 0.9)
		disband_style.border_color = Color(0.9, 0.4, 0.2, 0.85)
		disband_style.set_border_width_all(1)
		disband_style.set_corner_radius_all(4)
		disband_button.add_theme_stylebox_override("normal", disband_style)

		disband_button.pressed.connect(_on_disband_button_pressed)
		action_buttons_hbox.add_child(disband_button)
	if confirm_target_button:
		confirm_target_button.pressed.connect(_on_confirm_target_pressed)
	if troop_slider:
		troop_slider.value_changed.connect(_on_troop_slider_value_changed)
	if preset_25_button:
		preset_25_button.pressed.connect(func(): _set_slider_preset(0.25))
	if preset_50_button:
		preset_50_button.pressed.connect(func(): _set_slider_preset(0.50))
	if preset_75_button:
		preset_75_button.pressed.connect(func(): _set_slider_preset(0.75))
	if preset_100_button:
		preset_100_button.pressed.connect(func(): _set_slider_preset(1.00))

	# Kết nối sự kiện Giải tán quân
	if disband_slider:
		disband_slider.mouse_filter = Control.MOUSE_FILTER_STOP
		disband_slider.value_changed.connect(_on_disband_slider_value_changed)
	if confirm_disband_button:
		confirm_disband_button.mouse_filter = Control.MOUSE_FILTER_STOP
		confirm_disband_button.pressed.connect(_on_confirm_disband_pressed)
	if disband_preset_25_button:
		disband_preset_25_button.mouse_filter = Control.MOUSE_FILTER_STOP
		disband_preset_25_button.pressed.connect(func(): set_disband_preset(0.25))
	if disband_preset_50_button:
		disband_preset_50_button.mouse_filter = Control.MOUSE_FILTER_STOP
		disband_preset_50_button.pressed.connect(func(): set_disband_preset(0.50))
	if disband_preset_75_button:
		disband_preset_75_button.mouse_filter = Control.MOUSE_FILTER_STOP
		disband_preset_75_button.pressed.connect(func(): set_disband_preset(0.75))
	if disband_preset_100_button:
		disband_preset_100_button.mouse_filter = Control.MOUSE_FILTER_STOP
		disband_preset_100_button.pressed.connect(func(): set_disband_preset(1.00))
	
	# Kết nối sự kiện Ngoại giao
	if dip_improve_button:
		dip_improve_button.pressed.connect(_on_dip_improve_button_pressed)
	if dip_insult_button:
		dip_insult_button.pressed.connect(_on_dip_insult_button_pressed)
	if dip_access_button:
		dip_access_button.pressed.connect(_on_dip_access_button_pressed)
	if dip_alliance_button:
		dip_alliance_button.pressed.connect(_on_dip_alliance_button_pressed)
	if dip_war_button:
		dip_war_button.pressed.connect(_on_dip_war_button_pressed)
	
	# Kết nối sự kiện điều khiển thời gian
	if pause_button:
		pause_button.pressed.connect(toggle_pause)
	if speed_1_button:
		speed_1_button.pressed.connect(func(): set_speed(1))
	if speed_2_button:
		speed_2_button.pressed.connect(func(): set_speed(2))
	if speed_3_button:
		speed_3_button.pressed.connect(func(): set_speed(3))
	
	# Thiết lập mốc thời gian theo chế độ chơi
	if GameManager:
		if GameManager.current_mode == GameManager.MODE_SCENARIO_1611:
			current_year = 1611
		elif GameManager.current_mode == GameManager.MODE_FOUR_FACTIONS or GameManager.current_mode == GameManager.MODE_63_WARLORDS:
			current_year = 2026
	current_day = 1
	current_month = 1

	# Khởi tạo hiển thị ban đầu
	update_date_display()
	update_gold_display()
	update_speed_buttons_ui()
	
	# Thông báo chào mừng đầu trận
	var mode_name = "TỨ QUỐC GIAO TRANH"
	if GameManager:
		if GameManager.current_mode == GameManager.MODE_SCENARIO_1611:
			mode_name = "ĐẠI VIỆT 1611"
		elif GameManager.current_mode == GameManager.MODE_63_WARLORDS:
			mode_name = "TỬ CHIẾN (63 XỨ QUÂN)"
	
	if is_lobby_mode:
		show_notification("🗺️ SẢNH CHỌN QUỐC GIA: Nhấp chuột vào một tỉnh trên bản đồ để chọn phe lãnh đạo!")
	else:
		show_notification("🚩 CHIẾN DỊCH: %s! Bạn đang chỉ huy phe [%s]." % [mode_name, player_faction])

	setup_lobby_ui()

	# Nạp kịch bản Đại Việt 1611 nếu đang ở chế độ 1611
	if GameManager and GameManager.current_mode == GameManager.MODE_SCENARIO_1611:
		call_deferred("_load_scenario_1611")

func _load_scenario_1611() -> void:
	if ScenarioManager:
		var sc_data = ScenarioManager.active_scenario
		if sc_data.is_empty():
			sc_data = ScenarioManager.load_scenario("res://data/scenarios/scenario_1611.json")
		if sc_data.has("year"):
			current_year = int(sc_data["year"])
		else:
			current_year = 1611
		current_day = 1
		current_month = 1
		update_date_display()
		var success = ScenarioManager.apply_scenario(sc_data, self)
		if success and not is_lobby_mode:
			var fac_display = player_faction
			if sc_data.has("factions") and sc_data["factions"].has(player_faction):
				fac_display = sc_data["factions"][player_faction].get("display_name", sc_data["factions"][player_faction].get("name", player_faction))
			show_notification("📜 Khởi đầu kịch bản: Đại Việt 1611 — Bạn đang chỉ huy phe [%s]!" % fac_display)
			update_gold_display()

func setup_lobby_ui() -> void:
	if lobby_panel and is_instance_valid(lobby_panel):
		lobby_panel.visible = is_lobby_mode
		return
	
	lobby_panel = PanelContainer.new()
	lobby_panel.name = "LobbyPanel"
	lobby_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Định vị góc dưới bên trái (anchors_preset = Control.PRESET_BOTTOM_LEFT)
	lobby_panel.anchors_preset = Control.PRESET_BOTTOM_LEFT
	lobby_panel.anchor_top = 1.0
	lobby_panel.anchor_bottom = 1.0
	lobby_panel.offset_left = 20.0
	lobby_panel.offset_top = -185.0
	lobby_panel.offset_right = 380.0
	lobby_panel.offset_bottom = -20.0
	lobby_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = Color(0.07, 0.08, 0.13, 0.95)
	style_panel.border_color = Color(1.0, 0.84, 0.2, 0.9)
	style_panel.set_border_width_all(2)
	style_panel.set_corner_radius_all(8)
	style_panel.shadow_color = Color(0, 0, 0, 0.6)
	style_panel.shadow_size = 12
	lobby_panel.add_theme_stylebox_override("panel", style_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	lobby_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "🗺️ SẢNH CHỌN QUỐC GIA (LOBBY MAP)"
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.35, 1.0))
	vbox.add_child(title)
	
	lobby_faction_label = Label.new()
	lobby_faction_label.text = "👉 Nhấp chuột lên một tỉnh trên bản đồ để chọn phe..."
	lobby_faction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lobby_faction_label.add_theme_font_size_override("font_size", 12)
	lobby_faction_label.add_theme_color_override("font_color", Color(0.9, 0.93, 0.98, 1.0))
	vbox.add_child(lobby_faction_label)
	
	lobby_capital_label = Label.new()
	lobby_capital_label.text = "(Bản đồ đang tạm dừng • Tự do quan sát lãnh thổ)"
	lobby_capital_label.add_theme_font_size_override("font_size", 11)
	lobby_capital_label.add_theme_color_override("font_color", Color(0.65, 0.8, 1.0, 1.0))
	vbox.add_child(lobby_capital_label)
	
	lobby_confirm_button = Button.new()
	lobby_confirm_button.text = "⚔️ CHÍNH THỨC VÀO TRẬN"
	lobby_confirm_button.custom_minimum_size = Vector2(0, 40)
	lobby_confirm_button.focus_mode = Control.FOCUS_NONE
	lobby_confirm_button.mouse_filter = Control.MOUSE_FILTER_STOP
	lobby_confirm_button.disabled = true
	lobby_confirm_button.add_theme_font_size_override("font_size", 13)
	
	_update_lobby_button_style(false)
	
	lobby_confirm_button.pressed.connect(_on_lobby_confirm_pressed)
	vbox.add_child(lobby_confirm_button)
	
	$UI.add_child(lobby_panel)
	lobby_panel.visible = is_lobby_mode

func _update_lobby_button_style(enabled: bool) -> void:
	if not lobby_confirm_button:
		return
	var btn_style = StyleBoxFlat.new()
	btn_style.set_corner_radius_all(6)
	if enabled:
		btn_style.bg_color = Color(0.85, 0.65, 0.1, 1.0)
		btn_style.border_color = Color(1.0, 0.9, 0.45, 1.0)
		btn_style.set_border_width_all(2)
		lobby_confirm_button.add_theme_color_override("font_color", Color(0.12, 0.08, 0.01, 1.0))
	else:
		btn_style.bg_color = Color(0.18, 0.20, 0.26, 0.8)
		btn_style.border_color = Color(0.3, 0.35, 0.45, 0.6)
		btn_style.set_border_width_all(1)
		lobby_confirm_button.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.7))
	lobby_confirm_button.add_theme_stylebox_override("normal", btn_style)
	lobby_confirm_button.add_theme_stylebox_override("hover", btn_style)
	lobby_confirm_button.add_theme_stylebox_override("pressed", btn_style)
	lobby_confirm_button.add_theme_stylebox_override("disabled", btn_style)

func _handle_lobby_click(click_pos: Vector2) -> void:
	var clicked_prov = get_province_data_at_pos(click_pos)
	if clicked_prov.is_empty():
		return
	
	var fac = clicked_prov.get("owner", clicked_prov.get("faction", ""))
	if fac == "":
		return
	
	lobby_selected_faction = fac
	lobby_selected_province = clicked_prov
	
	# Tô sáng viền tỉnh được chọn bằng shader
	var id_hex = clicked_prov.get("id_color", clicked_prov.get("original_color", clicked_prov.get("color", "")))
	set_province_selection_shader(Color.from_string(id_hex, Color.BLACK), true)
	
	var fac_display = fac
	if ScenarioManager and ScenarioManager.active_scenario.has("factions") and ScenarioManager.active_scenario["factions"].has(fac):
		fac_display = ScenarioManager.active_scenario["factions"][fac].get("display_name", ScenarioManager.active_scenario["factions"][fac].get("name", fac))
	
	var prov_name = clicked_prov.get("name", "Tỉnh")
	var prov_troops = int(clicked_prov.get("troops", 0))
	
	if lobby_faction_label:
		lobby_faction_label.text = "👑 Bạn đang chọn: " + fac_display
	if lobby_capital_label:
		lobby_capital_label.text = "📍 Thủ phủ: %s • ⚔️ Quân số: %d" % [prov_name, prov_troops]
	
	if lobby_confirm_button:
		lobby_confirm_button.disabled = false
		lobby_confirm_button.text = "⚔️ CHÍNH THỨC VÀO TRẬN (LÃNH ĐẠO: %s)" % fac_display
		_update_lobby_button_style(true)

func _on_lobby_confirm_pressed() -> void:
	if lobby_selected_faction == "" or lobby_selected_province.is_empty():
		show_notification("⚠️ Vui lòng nhấp chọn một tỉnh trên bản đồ trước!")
		return
	
	player_faction = lobby_selected_faction
	if GameManager:
		GameManager.selected_player_faction = lobby_selected_faction
		GameManager.player_faction = lobby_selected_faction
		GameManager.player_province_id = lobby_selected_province.get("id", "")
		GameManager.is_lobby_mode = false
	is_lobby_mode = false
	
	if lobby_panel:
		lobby_panel.visible = false
	
	var fac_display = player_faction
	if ScenarioManager and ScenarioManager.active_scenario.has("factions") and ScenarioManager.active_scenario["factions"].has(player_faction):
		fac_display = ScenarioManager.active_scenario["factions"][player_faction].get("display_name", ScenarioManager.active_scenario["factions"][player_faction].get("name", player_faction))
	
	show_notification("🚩 BẮT ĐẦU VÁN ĐẤU! Bạn đang thống lĩnh phe [%s] (Thủ phủ: %s). Chúc bách chiến bách thắng!" % [
		fac_display,
		lobby_selected_province.get("name", "")
	])
	
	# Mở bảng thông tin của tỉnh thủ phủ đã chọn
	show_province_info(lobby_selected_province)
	
	# Cập nhật kinh tế & ngày tháng
	update_gold_display()
	update_date_display()
	
	# Bắt đầu thời gian game
	is_paused = false
	if pause_button:
		pause_button.text = "⏸ Tạm dừng"
		pause_button.modulate = Color.WHITE

func reset_to_lobby_mode() -> void:
	is_lobby_mode = true
	is_paused = true
	lobby_selected_faction = ""
	lobby_selected_province = {}
	if lobby_panel:
		lobby_panel.visible = true
	if lobby_faction_label:
		lobby_faction_label.text = "👉 Nhấp chuột lên một tỉnh trên bản đồ để chọn phe..."
	if lobby_capital_label:
		lobby_capital_label.text = "(Bản đồ đang tạm dừng • Tự do quan sát lãnh thổ)"
	if lobby_confirm_button:
		lobby_confirm_button.disabled = true
		lobby_confirm_button.text = "⚔️ CHÍNH THỨC VÀO TRẬN"
		_update_lobby_button_style(false)
	if province_panel:
		province_panel.visible = false
	set_province_selection_shader(Color(0, 0, 0, 0), false)
	if pause_button:
		pause_button.text = "▶ Tiếp tục"
	if GameManager:
		if GameManager.current_mode == GameManager.MODE_SCENARIO_1611:
			current_year = 1611
		elif GameManager.current_mode == GameManager.MODE_FOUR_FACTIONS or GameManager.current_mode == GameManager.MODE_63_WARLORDS:
			current_year = 2026
	current_day = 1
	current_month = 1
	update_date_display()

func cache_province_pixels() -> void:
	if not id_map_image:
		return
	province_pixel_cache.clear()
	var size = id_map_image.get_size()
	for y in range(int(size.y)):
		for x in range(int(size.x)):
			var c = id_map_image.get_pixel(x, y)
			if c.a > 0.1 and c.b > 0.0:
				var target_b = int(round(c.b * 255.0))
				if not province_pixel_cache.has(target_b):
					province_pixel_cache[target_b] = []
				province_pixel_cache[target_b].append(Vector2i(x, y))

func _process(delta: float) -> void:
	if not is_paused:
		var duration = SPEED_DURATIONS.get(game_speed, 1.0)
		day_timer += delta
		while day_timer >= duration:
			day_timer -= duration
			advance_one_day()
		
		# Đồng bộ tốc độ hành quân theo tốc độ thời gian của game (1x, 2x, 3x)
		var time_scale = 1.0 / duration
		update_active_armies(delta * time_scale)

func update_active_armies(dt: float) -> void:
	var i = active_armies.size() - 1
	while i >= 0:
		var army = active_armies[i]
		var path: Array = army.get("path", [])
		var total_legs: int = int(army.get("total_legs", 1))

		# Kiểm tra xem quân này đã bị hủy lệnh (path bị xóa, total_legs = 0)
		if path.is_empty() or total_legs <= 0:
			# Quân đã bị hủy lệnh, dọn dẹp visual và xóa khỏi active_armies
			if is_instance_valid(army.get("badge_root")):
				army["badge_root"].queue_free()
			if is_instance_valid(army.get("line")):
				army["line"].queue_free()
			active_armies.remove_at(i)
			i -= 1
			continue

		var curr_leg: int = int(army.get("current_leg", 0))
		var leg_duration: float = float(army.get("leg_duration", 1.6))

		army["leg_progress"] = float(army.get("leg_progress", 0.0)) + (dt / leg_duration)

		if army["leg_progress"] >= 1.0:
			if curr_leg + 1 < total_legs:
				# Vượt qua 1 chặng tỉnh trung gian an toàn (tuyệt đối KHÔNG kích hoạt giao tranh hay chiếm đất)
				curr_leg += 1
				army["current_leg"] = curr_leg
				army["leg_progress"] = 0.0
			else:
				# Đã đến tỉnh đích cuối cùng (Target)!
				army["leg_progress"] = 1.0
				_resolve_army_arrival(army)
				if is_instance_valid(army.get("badge_root")):
					army["badge_root"].queue_free()
				if is_instance_valid(army.get("line")):
					army["line"].queue_free()
				active_armies.remove_at(i)
				i -= 1
				continue
		
		# Cập nhật vị trí hiển thị lerp mượt mà giữa 2 đỉnh của chặng hiện tại
		if curr_leg + 1 < path.size():
			var p_from = get_province_local_pos(path[curr_leg])
			var p_to = get_province_local_pos(path[curr_leg + 1])
			var t = clamp(float(army["leg_progress"]), 0.0, 1.0)
			if is_instance_valid(army.get("badge_root")):
				army["badge_root"].position = p_from.lerp(p_to, t)
		
		i -= 1

func load_provinces_json() -> void:
	var file_path = "res://provinces.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_text = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			provinces_data = json.data
			provinces_by_id.clear()
			provinces_by_id_color.clear()
			provinces_by_id_num.clear()
			var is_63_warlords = (GameManager and GameManager.current_mode == GameManager.MODE_63_WARLORDS)
			for prov in provinces_data:
				var prov_id = str(prov.get("id", ""))
				if prov_id != "":
					provinces_by_id[prov_id] = prov
				
				var id_hex = prov.get("id_color", prov.get("color", "")).to_lower()
				prov["original_color"] = id_hex
				prov["current_color"] = id_hex
				provinces_by_id_color[id_hex] = prov
				
				var id_color = Color.from_string(id_hex, Color.BLACK)
				var id_num = int(round(id_color.b * 255.0))
				provinces_by_id_num[id_num] = prov
				
				if is_63_warlords:
					prov["faction"] = prov.get("name", "Vô danh")
					prov["troops"] = 30
					var col = GameManager.get_warlord_color_by_num(id_num)
					prov["current_color"] = "#" + col.to_html(false).to_lower()
					faction_colors[prov["faction"]] = col
				else:
					var fac = prov.get("faction", "")
					if fac != "" and not faction_colors.has(fac):
						faction_colors[fac] = Color.from_string(id_hex, Color.WHITE)
			print("Đã load provinces.json thành công với %d tỉnh thành (Chế độ: %s)!" % [
				provinces_data.size(),
				"Loạn 63 Xứ Quân" if is_63_warlords else "Tứ Quốc Tranh Hùng"
			])
			
			var fac_list = []
			for p in provinces_data:
				var fac = p.get("faction", "")
				if fac != "" and not fac_list.has(fac):
					fac_list.append(fac)
			if DiplomacyManager:
				DiplomacyManager.init_factions(fac_list)
		else:
			print("Lỗi parse JSON provinces.json")

func get_province_neighbors(prov: Dictionary) -> Array:
	var result: Array = []
	var n_ids = prov.get("neighbors", [])
	for nid in n_ids:
		var sid = str(nid)
		if provinces_by_id.has(sid):
			result.append(provinces_by_id[sid])
	return result

# ==============================================================================
# CỔNG KIỂM TRA NGOẠI GIAO (DIPLOMACY GUARD CHECK)
# ==============================================================================
func can_send_troops_to(source_prov: Dictionary, target_prov: Dictionary, show_ui_warning: bool = true) -> bool:
	if source_prov.is_empty() or target_prov.is_empty():
		return false
	
	var src_fac = source_prov.get("faction", player_faction)
	var tgt_fac = target_prov.get("faction", target_prov.get("owner", ""))
	
	# 1. Cùng phe: Di chuyển nội bộ / tiếp viện bình thường
	if tgt_fac == src_fac or tgt_fac == "":
		return true
	
	# 2. Đồng minh: Cho phép chi viện phòng thủ
	if DiplomacyManager and DiplomacyManager.is_allied(src_fac, tgt_fac):
		return true
	
	# 3. Phe khác không phải đồng minh: Bắt buộc PHẢI ĐANG CÓ CHIẾN TRANH
	var is_war = false
	if DiplomacyManager:
		is_war = DiplomacyManager.is_at_war(src_fac, tgt_fac)
	
	if not is_war:
		if show_ui_warning and src_fac == player_faction:
			show_notification("⚠️ Chưa tuyên chiến! Bạn không thể tấn công phe này khi đang hòa bình.")
			# Tự động bật bảng Ngoại giao của phe đó lên để người chơi thao tác tuyên chiến hợp lệ nếu đủ điều kiện
			show_province_info(target_prov)
		return false
	
	return true

# ==============================================================================
# THUẬT TOÁN TÌM ĐƯỜNG THEO ĐỒ THỊ LÁNG GIỀNG (GRAPH PATHFINDING - BFS)
# ==============================================================================
func find_path(from_province: Dictionary, to_province: Dictionary, mover_faction: String = "") -> Array:
	if from_province.is_empty() or to_province.is_empty():
		return []
	
	var start_id = str(from_province.get("id"))
	var end_id = str(to_province.get("id"))
	if start_id == end_id:
		return [from_province]
	
	if mover_faction == "":
		mover_faction = from_province.get("faction", player_faction)
	
	# Kiểm tra cổng Ngoại giao: Nếu đích đến là phe khác mà chưa tuyên chiến thì không có đường tấn công hợp lệ
	if not can_send_troops_to(from_province, to_province, false):
		return []
	
	var queue: Array = [start_id]
	var visited: Dictionary = {start_id: true}
	var parent: Dictionary = {}
	var found: bool = false
	
	while queue.size() > 0:
		var curr_id = queue.pop_front()
		if curr_id == end_id:
			found = true
			break
		
		var curr_prov = provinces_by_id.get(curr_id)
		if curr_prov == null:
			continue
		
		var neighbors = curr_prov.get("neighbors", [])
		for nid in neighbors:
			var sid = str(nid)
			if visited.has(sid):
				continue
			
			var next_prov = provinces_by_id.get(sid)
			if next_prov == null:
				continue
			
			# 1. Đích đến cuối cùng (Target): Luôn là điểm đến hợp lệ để tấn công hoặc tiếp viện
			if sid == end_id:
				visited[sid] = true
				parent[sid] = curr_id
				queue.append(sid)
				continue
			
			# 2. Tỉnh trung gian: Bắt buộc phải có quyền đi qua an toàn (phe ta, đồng minh, hoặc có quyền hành quân)
			var next_fac = next_prov.get("faction", next_prov.get("owner", ""))
			var is_passable = false
			
			if next_fac == mover_faction:
				is_passable = true
			elif DiplomacyManager:
				if DiplomacyManager.is_allied(mover_faction, next_fac) or DiplomacyManager.has_military_access(mover_faction, next_fac):
					is_passable = true
			
			# Tỉnh trung lập không có quyền đi, hoặc tỉnh địch -> Bị coi là vật cản không thể đi xuyên qua
			if not is_passable:
				continue
			
			visited[sid] = true
			parent[sid] = curr_id
			queue.append(sid)
	
	if not found:
		return []
	
	var path_ids: Array = []
	var curr = end_id
	while curr != "":
		path_ids.push_front(curr)
		curr = parent.get(curr, "")
	
	var result: Array = []
	for pid in path_ids:
		var p = provinces_by_id.get(pid)
		if p != null:
			result.append(p)
	return result

func find_province_path(source: Dictionary, target: Dictionary, mover_faction: String = "") -> Array:
	return find_path(source, target, mover_faction)

# ==============================================================================
# QUẢN LÝ THỜI GIAN & CHU KỲ KINH TẾ
# ==============================================================================
func advance_one_day() -> void:
	current_day += 1
	var days_in_month = get_days_in_month(current_month, current_year)
	
	if current_day > days_in_month:
		current_day = 1
		current_month += 1
		if current_month > 12:
			current_month = 1
			current_year += 1
		
		trigger_monthly_economy()
	
	update_date_display()

func get_working_age_population(prov: Dictionary) -> int:
	var total_working = 0
	if prov.has("demographics"):
		var demo = prov["demographics"]
		if demo.has("male"):
			total_working += int(demo["male"].get("working_age", 0))
		if demo.has("female"):
			total_working += int(demo["female"].get("working_age", 0))
	return total_working

func get_province_income(prov: Dictionary) -> int:
	var total_working_age = get_working_age_population(prov)
	var labor_income = int(total_working_age / 100000)
	return BASE_INCOME_PER_PROVINCE + labor_income

func get_total_player_troops() -> int:
	var total = 0
	for prov in provinces_data:
		if can_recruit(prov):
			total += int(prov.get("troops", 0))
	for army in active_armies:
		if army.get("faction") == player_faction:
			total += int(army.get("troops", 0))
	return total

func get_player_military_upkeep() -> int:
	var total_troops = get_total_player_troops()
	return int(total_troops * UPKEEP_PER_TROOP)

func get_player_total_province_income() -> int:
	var total = 0
	for prov in provinces_data:
		if can_recruit(prov):
			total += get_province_income(prov)
	return total

func get_player_net_monthly_gold() -> int:
	var total_prov_income = get_player_total_province_income()
	var total_upkeep = get_player_military_upkeep()
	var diplomat_expense = 0
	if DiplomacyManager:
		diplomat_expense = DiplomacyManager.get_player_diplomat_expense(player_faction)
	return total_prov_income - total_upkeep - diplomat_expense

func trigger_monthly_economy() -> void:
	var dip_result = {}
	if DiplomacyManager:
		dip_result = DiplomacyManager.monthly_tick(player_faction, player_gold)
	
	var total_income = get_player_total_province_income()
	var total_upkeep = get_player_military_upkeep()
	var diplomat_expense = dip_result.get("diplomat_cost", 0)
	var net_monthly_gold = total_income - total_upkeep - diplomat_expense
	player_gold += net_monthly_gold
	update_gold_display()
	
	var sign_str = "+" if net_monthly_gold >= 0 else ""
	var cancel_notif = ""
	if dip_result.has("cancelled_factions") and dip_result["cancelled_factions"].size() > 0:
		cancel_notif = " (Đã hủy sứ giả tới %s do hết vàng!)" % ", ".join(dip_result["cancelled_factions"])
	
	show_notification("💰 ĐẦU THÁNG %02d/%d: Thuế +%s, Quân phí -%s%s (Thu ròng: %s%s Vàng)%s!" % [
		current_month, current_year,
		format_number(total_income),
		format_number(total_upkeep),
		(", Ngoại giao -%d" % diplomat_expense) if diplomat_expense > 0 else "",
		sign_str,
		format_number(net_monthly_gold),
		cancel_notif
	])
	print("Kinh te dau thang %02d/%d: Thue +%d, Upkeep -%d, Ngoai giao -%d, Thu rong: %+d (Tong vang: %d)" % [
		current_month, current_year, total_income, total_upkeep, diplomat_expense, net_monthly_gold, player_gold
	])
	
	if not selected_province.is_empty():
		show_province_info(selected_province)

func get_player_province_count() -> int:
	var count = 0
	for prov in provinces_data:
		if prov.get("faction") == player_faction:
			count += 1
	return count

func get_days_in_month(month: int, year: int) -> int:
	if month in [1, 3, 5, 7, 8, 10, 12]:
		return 31
	elif month in [4, 6, 9, 11]:
		return 30
	elif month == 2:
		var is_leap = (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
		return 29 if is_leap else 28
	return 30

func update_date_display() -> void:
	if date_label:
		date_label.text = "📅 %02d/%02d/%d" % [current_day, current_month, current_year]

func update_gold_display() -> void:
	if gold_label:
		var net_gold = get_player_net_monthly_gold()
		var sign_str = "+" if net_gold >= 0 else ""
		gold_label.text = "💰 %s (%s%s/thg)" % [format_number(player_gold), sign_str, format_number(net_gold)]
		var color = Color("#69f0ae") if net_gold >= 0 else Color("#ff5252")
		gold_label.add_theme_color_override("font_color", color)

func toggle_pause() -> void:
	set_paused(not is_paused)

func set_paused(paused: bool) -> void:
	if is_lobby_mode and not paused:
		show_notification("⚠️ Hãy chọn một tỉnh và bấm 'CHÍNH THỨC VÀO TRẬN' trước khi bắt đầu thời gian!")
		return
	is_paused = paused
	if pause_button:
		if is_paused:
			pause_button.text = "▶ Tiếp tục"
			pause_button.modulate = Color(1.3, 0.7, 0.7)
			if is_move_mode:
				cancel_move_mode()
			show_notification("⏸ Thời gian đã tạm dừng.")
		else:
			pause_button.text = "⏸ Tạm dừng"
			pause_button.modulate = Color.WHITE
			show_notification("▶ Tiếp tục thời gian.")
	
	if not selected_province.is_empty():
		show_province_info(selected_province)

func set_speed(speed: int) -> void:
	if is_lobby_mode:
		show_notification("⚠️ Hãy chọn một tỉnh và bấm 'CHÍNH THỨC VÀO TRẬN' trước khi tăng tốc!")
		return
	game_speed = speed
	update_speed_buttons_ui()

func update_speed_buttons_ui() -> void:
	var highlight = Color(1.3, 1.2, 0.4)
	if speed_1_button:
		speed_1_button.modulate = highlight if game_speed == 1 else Color.WHITE
	if speed_2_button:
		speed_2_button.modulate = highlight if game_speed == 2 else Color.WHITE
	if speed_3_button:
		speed_3_button.modulate = highlight if game_speed == 3 else Color.WHITE

# ==============================================================================
# HỆ THỐNG SHADER CHỌN TỈNH (LÀM SÁNG DIỆN TÍCH + VIỀN TƯƠNG PHẢN GPU)
# ==============================================================================
func set_province_selection_shader(color: Color, selected: bool) -> void:
	if map_sprite and map_sprite.material is ShaderMaterial:
		map_sprite.material.set_shader_parameter("target_color", color)
		map_sprite.material.set_shader_parameter("is_selected", selected)

# ==============================================================================
# HỆ THỐNG NHÃN SỐ QUÂN TRỰC TIẾP TRÊN BẢN ĐỒ
# ==============================================================================
func spawn_troop_markers() -> void:
	if not map_sprite:
		return
	
	markers_container = Node2D.new()
	markers_container.name = "TroopMarkers"
	map_sprite.add_child(markers_container)
	
	var tex_size = map_sprite.texture.get_size()
	
	for prov in provinces_data:
		var center_pos = get_province_center(prov)
		if center_pos == Vector2.ZERO:
			continue
		
		var local_pos = center_pos
		if map_sprite.centered:
			local_pos = center_pos - tex_size / 2.0
		
		var marker_root = Node2D.new()
		marker_root.name = "Marker_" + str(prov.get("id"))
		marker_root.position = local_pos
		marker_root.scale = Vector2(0.5, 0.5) # Giảm 50% kích thước nhãn lính
		markers_container.add_child(marker_root)
		
		var badge = PanelContainer.new()
		badge.name = "Badge"
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.08, 0.08, 0.08, 0.85)
		style.border_color = Color(1.0, 1.0, 1.0, 0.9)
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		style.content_margin_left = 2
		style.content_margin_right = 2
		style.content_margin_top = 1
		style.content_margin_bottom = 1
		badge.add_theme_stylebox_override("panel", style)
		
		var label = Label.new()
		label.name = "CountLabel"
		var troops = int(prov.get("troops", 0))
		label.text = format_number(troops)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color.WHITE)
		badge.add_child(label)
		
		var badge_size = Vector2(24, 14)
		badge.custom_minimum_size = badge_size
		badge.reset_size()
		badge.pivot_offset = badge.size / 2.0
		badge.position = -badge.size / 2.0
		
		marker_root.add_child(badge)
		province_labels[prov.get("id")] = label
		province_markers[prov.get("id")] = marker_root
		
		# Tối ưu hiển thị: chỉ hiện nhãn khi có quân (> 0), ẩn hoàn toàn khi <= 0
		marker_root.visible = (troops > 0)

func get_province_center(prov: Dictionary) -> Vector2:
	if prov.has("center") and prov["center"] is Array and prov["center"].size() == 2:
		return Vector2(prov["center"][0], prov["center"][1])
	
	return calculate_province_center_from_image(prov.get("original_color", prov["color"]))

func get_province_local_pos(prov: Dictionary) -> Vector2:
	var center_pos = get_province_center(prov)
	if map_sprite and map_sprite.centered and map_sprite.texture:
		var tex_size = map_sprite.texture.get_size()
		return center_pos - tex_size / 2.0
	return center_pos

func calculate_province_center_from_image(target_hex: String) -> Vector2:
	if not id_map_image:
		return Vector2.ZERO
	
	var target_color = Color.from_string(target_hex, Color.BLACK)
	var target_b = int(round(target_color.b * 255.0))
	var tex_size = id_map_image.get_size()
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var count: int = 0
	var step: int = 2
	
	for y in range(0, int(tex_size.y), step):
		for x in range(0, int(tex_size.x), step):
			var c = id_map_image.get_pixel(x, y)
			if c.a > 0.1 and int(round(c.b * 255.0)) == target_b:
				sum_x += x
				sum_y += y
				count += 1
	
	if count > 0:
		return Vector2(sum_x / count, sum_y / count)
	return Vector2.ZERO

func update_troop_label(prov: Dictionary) -> void:
	var prov_id = prov.get("id")
	var troops = int(prov.get("troops", 0))
	if province_labels.has(prov_id):
		var label: Label = province_labels[prov_id]
		label.text = format_number(troops)
	if province_markers.has(prov_id):
		var marker: Node2D = province_markers[prov_id]
		# Cập nhật trạng thái ẩn/hiện: có quân thì hiện, không có quân thì ẩn hoàn toàn
		marker.visible = (troops > 0)
		var badge = marker.get_node_or_null("Badge")
		if badge:
			badge.reset_size()
			badge.pivot_offset = badge.size / 2.0
			badge.position = -badge.size / 2.0

# ==============================================================================
# HỆ THỐNG ĐỔI MÀU LÃNH THỔ KHI BỊ CHIẾM (BẢO VỆ VIỀN RANH GIỚI TUYỆT ĐỐI)
# ==============================================================================
func repaint_province(prov: Dictionary, new_color: Color) -> void:
	if not map_image or not id_map_image or not base_display_image:
		return
	
	var orig_color = Color.from_string(prov.get("original_color", prov["color"]), Color.BLACK)
	var target_b = int(round(orig_color.b * 255.0))
	
	# Nếu có cache pixel thì duyệt trực tiếp tập điểm ảnh của tỉnh (cực nhanh, không loop toàn map)
	if province_pixel_cache.has(target_b):
		for pt in province_pixel_cache[target_b]:
			var base_c = base_display_image.get_pixel(pt.x, pt.y)
			# BẢO VỆ VIỀN: Nếu điểm ảnh thuộc đường viền ranh giới đen/xám (RGB < 65/255 ~ 0.255)
			# thì TUYỆT ĐỐI không đè màu phe mới lên, giữ nguyên viền bản đồ gốc!
			if max(base_c.r, max(base_c.g, base_c.b)) < 0.255:
				continue
			map_image.set_pixel(pt.x, pt.y, new_color)
	else:
		var size = map_image.get_size()
		for y in range(int(size.y)):
			for x in range(int(size.x)):
				var id_pixel = id_map_image.get_pixel(x, y)
				if id_pixel.a > 0.1 and int(round(id_pixel.b * 255.0)) == target_b:
					var base_c = base_display_image.get_pixel(x, y)
					if max(base_c.r, max(base_c.g, base_c.b)) < 0.255:
						continue
					map_image.set_pixel(x, y, new_color)
	
	if map_sprite.texture is ImageTexture:
		map_sprite.texture.update(map_image)
	else:
		map_sprite.texture = ImageTexture.create_from_image(map_image)
	
	prov["current_color"] = "#" + new_color.to_html(false).to_lower()
	print("Đã đổi màu lãnh thổ ", prov.get("name"), " sang màu của phe ", prov.get("faction"))

# ==============================================================================
# XỬ LÝ CLICK CHUỘT, PHÍM TẮT & COLOR-PICKING
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			toggle_pause()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_1:
			set_speed(1)
			return
		elif event.keycode == KEY_2:
			set_speed(2)
			return
		elif event.keycode == KEY_3:
			set_speed(3)
			return
		# ESC: Hủy chế độ chọn mục tiêu / Ngưng hành quân
		elif event.keycode == KEY_ESCAPE:
			if is_move_mode:
				cancel_move_mode()
				close_dispatch_container()
				show_notification("Đã hủy lệnh chọn mục tiêu.")
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and is_move_mode:
			cancel_move_mode()
			close_dispatch_container()
			show_notification("Đã hủy lệnh chọn mục tiêu (Right-click).")
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_press_pos = event.position
			is_left_mouse_down = true
			was_godot_double_click = event.double_click
		else:
			if is_left_mouse_down:
				is_left_mouse_down = false
				
				# Kiểm tra xem có đang hoặc vừa thực hiện vuốt / pan camera không
				var camera_is_panning = false
				var cam = get_node_or_null("Camera2D")
				if cam and (cam.is_touch_dragging or cam.just_finished_touch_drag or cam.is_dragging):
					camera_is_panning = true
				
				# Chỉ xử lý chọn tỉnh nếu không kéo camera và quãng đường chạm/nhấc < 15px
				if not camera_is_panning and mouse_press_pos.distance_to(event.position) < 15.0:
					var is_dbl = was_godot_double_click or event.double_click
					handle_left_click(get_global_mouse_position(), is_dbl)

func handle_left_click(click_pos: Vector2, is_godot_double_click: bool = false) -> void:
	if is_lobby_mode:
		_handle_lobby_click(click_pos)
		return

	var clicked_prov = get_province_data_at_pos(click_pos)
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 1. XỬ LÝ CHẾ ĐỘ CHỌN MỤC TIÊU TỪ BẢNG ĐIỀU QUÂN SLIDER
	if is_move_mode:
		if is_paused:
			show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
			return
		
		if clicked_prov.is_empty():
			cancel_move_mode()
			show_notification("Đã hủy lệnh chọn mục tiêu.")
			return
		
		if clicked_prov.get("id") == move_source_province.get("id"):
			cancel_move_mode()
			show_notification("Đã hủy lệnh chọn mục tiêu.")
			show_province_info(clicked_prov)
			return
		
		# Cổng kiểm tra Ngoại giao (Diplomacy Guard Check) trước khi phát lệnh điều quân
		if not can_send_troops_to(move_source_province, clicked_prov, true):
			cancel_move_mode()
			close_dispatch_container()
			return
		
		# Bắt đầu xuất quân theo số lượng đã chọn trên HSlider
		dispatch_army(move_source_province, clicked_prov, selected_troop_count)
		cancel_move_mode()
		close_dispatch_container()
		return

	# 2. XỬ LÝ THAO TÁC NHANH (DOUBLE-CLICK / DOUBLE-TAP TRONG VÒNG 0.35s)
	# Khi người chơi đang chọn Tỉnh A (thuộc phe mình và có quân > 0)
	# và nhấp đúp vào Tỉnh B bất kỳ -> Tự động điều TOÀN BỘ 100% quân sang Tỉnh B ngay lập tức!
	var time_delta = current_time - last_click_timestamp
	var is_double = is_godot_double_click or (time_delta <= 0.35 and not clicked_prov.is_empty() and clicked_prov.get("id") == last_click_prov_id)
	
	if is_double and not potential_double_click_source.is_empty() and not clicked_prov.is_empty():
		var source_prov = potential_double_click_source
		var source_troops = int(source_prov.get("troops", 0))
		var source_id = source_prov.get("id")
		var target_id = clicked_prov.get("id")
		
		if source_id != target_id and can_recruit(source_prov) and source_troops > 0:
			if is_paused:
				show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
				return
			
			# Cổng kiểm tra Ngoại giao (Diplomacy Guard Check) trước khi thực hiện double-click
			if not can_send_troops_to(source_prov, clicked_prov, true):
				potential_double_click_source = {}
				last_click_prov_id = ""
				last_click_timestamp = 0.0
				return
			
			var dispatched = dispatch_army(source_prov, clicked_prov, source_troops, false)
			if dispatched:
				show_notification("⚡ [Double-click] Đã điều toàn bộ 100%% (%s quân) từ %s sang %s!" % [
					format_number(source_troops), source_prov.get("name"), clicked_prov.get("name")
				])
			else:
				show_notification("⚠️ Không có đường đi an toàn từ %s đến %s!" % [source_prov.get("name"), clicked_prov.get("name")])
			potential_double_click_source = {}
			last_click_prov_id = ""
			last_click_timestamp = 0.0
			return

	# 3. LƯU NGUỒN TIỀM NĂNG CHO DOUBLE-CLICK LẦN CLICK KẾ TIẾP
	if not selected_province.is_empty() and can_recruit(selected_province) and int(selected_province.get("troops", 0)) > 0:
		potential_double_click_source = selected_province
	else:
		potential_double_click_source = {}

	# 4. CHỌN VÀ HIỂN THỊ THÔNG TIN TỈNH (SINGLE CLICK)
	if not clicked_prov.is_empty():
		last_click_prov_id = clicked_prov.get("id")
		last_click_timestamp = current_time
		show_province_info(clicked_prov)
	else:
		last_click_prov_id = ""
		last_click_timestamp = 0.0
		hide_province_panel()
		set_province_selection_shader(Color(0, 0, 0, 0), false)

func get_province_data_at_pos(click_pos: Vector2) -> Dictionary:
	if not map_sprite:
		return {}
	var local_pos = map_sprite.to_local(click_pos)
	return get_province_at_local_pos(local_pos)

func get_province_at_local_pos(local_pos: Vector2) -> Dictionary:
	if not id_map_image:
		return {}
	
	var tex_size = id_map_image.get_size()
	var pixel_pos = local_pos
	if map_sprite and map_sprite.centered:
		pixel_pos += tex_size / 2.0
	
	var pixel_x = int(round(pixel_pos.x))
	var pixel_y = int(round(pixel_pos.y))
	
	if pixel_x >= 0 and pixel_x < tex_size.x and pixel_y >= 0 and pixel_y < tex_size.y:
		var color: Color = id_map_image.get_pixel(pixel_x, pixel_y)
		if color.a > 0.1 and color.b > 0.0:
			var target_b = int(round(color.b * 255.0))
			if provinces_by_id_num.has(target_b):
				return provinces_by_id_num[target_b]
			var hex_color = "#" + color.to_html(false).to_lower()
			if provinces_by_id_color.has(hex_color):
				return provinces_by_id_color[hex_color]
	
	# Nếu chạm mép hoặc viền đen, quét bán kính nhỏ xung quanh (r=3 pixel)
	for dy in [-3, 0, 3]:
		for dx in [-3, 0, 3]:
			var nx = pixel_x + dx
			var ny = pixel_y + dy
			if nx >= 0 and nx < tex_size.x and ny >= 0 and ny < tex_size.y:
				var nc = id_map_image.get_pixel(nx, ny)
				if nc.a > 0.1 and nc.b > 0.0:
					var nb = int(round(nc.b * 255.0))
					if provinces_by_id_num.has(nb):
						return provinces_by_id_num[nb]
	
	return {}

func format_number(n: int) -> String:
	var s = str(abs(n))
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	if n < 0:
		res = "-" + res
	return res

func get_total_population(prov: Dictionary) -> int:
	return int(prov.get("total_population", 0))

func get_male_population(prov: Dictionary) -> int:
	if prov.has("demographics") and prov["demographics"].has("male"):
		var m = prov["demographics"]["male"]
		return int(m.get("under_18", 0)) + int(m.get("working_age", 0)) + int(m.get("senior", 0))
	return 0

func get_female_population(prov: Dictionary) -> int:
	if prov.has("demographics") and prov["demographics"].has("female"):
		var f = prov["demographics"]["female"]
		return int(f.get("under_18", 0)) + int(f.get("working_age", 0)) + int(f.get("senior", 0))
	return 0

func get_male_working_age(prov: Dictionary) -> int:
	if prov.has("demographics") and prov["demographics"].has("male"):
		return int(prov["demographics"]["male"].get("working_age", 0))
	return 0

func has_recruited_this_month(prov: Dictionary) -> bool:
	return prov.get("last_recruited_month", -1) == current_month and prov.get("last_recruited_year", -1) == current_year

func get_remaining_pop_quota(prov: Dictionary) -> int:
	var male_working = get_male_working_age(prov)
	var max_by_population = int(male_working * 0.03)
	if prov.get("last_recruited_month", -1) != current_month or prov.get("last_recruited_year", -1) != current_year:
		prov["recruited_this_month"] = 0
	var recruited_so_far = prov.get("recruited_this_month", 0)
	return max(0, max_by_population - recruited_so_far)

func get_max_recruitable(prov: Dictionary) -> int:
	var remaining_pop = get_remaining_pop_quota(prov)
	var max_by_money = int(player_gold / COST_PER_TROOP)
	return min(remaining_pop, max_by_money)

func update_province_panel_size() -> void:
	if not province_panel:
		return
	if diplomacy_container and diplomacy_container.visible:
		province_panel.offset_top = -370.0
	elif (dispatch_container and dispatch_container.visible) or (recruit_container and recruit_container.visible) or (disband_container and disband_container.visible):
		province_panel.offset_top = -485.0
	else:
		province_panel.offset_top = -315.0

func close_dispatch_container() -> void:
	if dispatch_container:
		dispatch_container.visible = false
	if move_button:
		move_button.text = "Điều quân..."
	if confirm_target_button:
		confirm_target_button.text = "🎯 Chọn mục tiêu"
	update_province_panel_size()

func close_recruit_container() -> void:
	if recruit_container:
		recruit_container.visible = false
	if recruit_button and not selected_province.is_empty() and can_recruit(selected_province):
		var remaining_quota = get_remaining_pop_quota(selected_province)
		var max_rec = get_max_recruitable(selected_province)
		if remaining_quota <= 0:
			recruit_button.disabled = true
			recruit_button.text = "Đã tuyển hết hạn ngạch tháng %02d" % current_month
		elif player_gold < COST_PER_TROOP:
			recruit_button.disabled = true
			recruit_button.text = "Không đủ Vàng (Cần ≥ %d💰)" % COST_PER_TROOP
		else:
			recruit_button.disabled = false
			recruit_button.text = "🎖️ Tuyển quân (Tối đa: %s)" % format_number(max_rec)
	update_province_panel_size()

func open_recruit_container() -> void:
	if selected_province.is_empty() or not can_recruit(selected_province) or is_paused:
		return
	close_dispatch_container()
	close_disband_container()
	var remaining_quota = get_remaining_pop_quota(selected_province)
	var max_by_money = int(player_gold / COST_PER_TROOP)
	var max_rec = min(remaining_quota, max_by_money)
	
	if remaining_quota <= 0:
		show_notification("⚠️ %s đã tuyển hết chỉ tiêu 3%% của tháng %02d/%d! Chờ tháng sau." % [
			selected_province.get("name"), current_month, current_year
		])
		return
	
	if max_by_money <= 0:
		show_notification("⚠️ Không đủ Vàng để tuyển quân! (Cần ít nhất %d Vàng/lính)" % COST_PER_TROOP)
		return
	
	if recruit_slider:
		recruit_slider.min_value = 1
		recruit_slider.max_value = max_rec
		recruit_slider.step = 1
		# Mặc định khi mở: Đặt ở mức tương ứng với 50% số tiền người chơi hiện có
		var default_by_gold = int((player_gold * 0.5) / COST_PER_TROOP)
		recruit_slider.value = clamp(default_by_gold, 1, max_rec)
		_update_recruit_cost_label(recruit_slider.value)
	
	if recruit_container:
		recruit_container.visible = true
	if recruit_button:
		recruit_button.text = "Đóng tuyển quân ✖"
	update_province_panel_size()

func _update_recruit_cost_label(val: float) -> void:
	var count = int(val)
	var cost = count * COST_PER_TROOP
	if recruit_cost_label:
		recruit_cost_label.text = "Tuyển: %s lính (Tốn: %s Vàng)" % [format_number(count), format_number(cost)]

func _on_recruit_slider_value_changed(val: float) -> void:
	_update_recruit_cost_label(val)

func set_recruit_preset(ratio: float) -> void:
	if selected_province.is_empty():
		return
	var max_rec = get_max_recruitable(selected_province)
	if max_rec <= 0 or not recruit_slider:
		return
	var target_val = int(round(max_rec * ratio))
	recruit_slider.value = clamp(target_val, 1, max_rec)
	_update_recruit_cost_label(recruit_slider.value)

func _on_confirm_recruit_pressed() -> void:
	if selected_province.is_empty():
		return
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return
	if not can_recruit(selected_province):
		show_notification("⚠️ Không thể tuyển quân tại tỉnh khác phe!")
		return
	
	var count = int(recruit_slider.value) if recruit_slider else 0
	if count <= 0:
		show_notification("⚠️ Số lượng tân binh cần tuyển phải lớn hơn 0!")
		return
	
	var cost = count * COST_PER_TROOP
	if player_gold < cost:
		show_notification("⚠️ Không đủ Vàng để tuyển %s lính (Cần %s Vàng)!" % [format_number(count), format_number(cost)])
		return
	
	var remaining_quota = get_remaining_pop_quota(selected_province)
	if count > remaining_quota:
		show_notification("⚠️ Vượt quá chỉ tiêu nhân lực còn lại (%s lính) của tháng này!" % format_number(remaining_quota))
		return
	
	# Trừ tiền
	player_gold -= cost
	update_gold_display()
	
	# Trừ dân số nam độ tuổi lao động và tổng dân số
	if selected_province.has("demographics") and selected_province["demographics"].has("male"):
		selected_province["demographics"]["male"]["working_age"] = max(0, selected_province["demographics"]["male"]["working_age"] - count)
	selected_province["total_population"] = max(0, selected_province.get("total_population", 0) - count)
	
	# Cộng quân vào tỉnh
	selected_province["troops"] = int(selected_province.get("troops", 0)) + count
	
	# Cập nhật hạn ngạch tháng
	selected_province["recruited_this_month"] = selected_province.get("recruited_this_month", 0) + count
	selected_province["last_recruited_month"] = current_month
	selected_province["last_recruited_year"] = current_year
	
	update_troop_label(selected_province)
	close_recruit_container()
	show_province_info(selected_province)
	
	show_notification("🎖️ Đã tuyển +%s tân binh tại %s (Chi phí: %s Vàng)!" % [
		format_number(count),
		selected_province.get("name"),
		format_number(cost)
	])
	print("Tuyển quân thành công (+%d) tại %s - Tốn %d Vàng (Vàng còn: %d) - Quân số: %d" % [
		count,
		selected_province.get("name"),
		cost,
		player_gold,
		selected_province["troops"]
	])

func close_disband_container() -> void:
	if disband_container:
		disband_container.visible = false
	var disband_button = action_buttons_hbox.get_node_or_null("DisbandButton") if action_buttons_hbox else null
	if disband_button:
		disband_button.text = "🗑️ Giải tán quân"
	update_province_panel_size()

func open_disband_container() -> void:
	if selected_province.is_empty() or not can_recruit(selected_province) or is_paused:
		return
	close_dispatch_container()
	close_recruit_container()
	cancel_move_mode()

	var troops = int(selected_province.get("troops", 0))
	if troops <= 0:
		show_notification("⚠️ %s không có quân để giải tán!" % selected_province.get("name"))
		return

	if disband_slider:
		disband_slider.min_value = 1
		disband_slider.max_value = max(1, troops)
		disband_slider.step = 1
		disband_slider.value = max(1, int(ceil(troops * 0.5)))
	_update_disband_slider_ui()

	if disband_container:
		disband_container.visible = true
	var disband_button = action_buttons_hbox.get_node_or_null("DisbandButton") if action_buttons_hbox else null
	if disband_button:
		disband_button.text = "Đóng giải tán"
	update_province_panel_size()

func _update_disband_slider_ui() -> void:
	if not disband_slider or selected_province.is_empty():
		return
	var troops = int(selected_province.get("troops", 0))
	var count = int(disband_slider.value)
	var pct = int(round((float(count) / float(max(1, troops))) * 100.0))
	var returned_pop = int(count * 0.5)
	if disband_count_label:
		disband_count_label.text = "%s / %s (%d%%) -> +%s Dân" % [
			format_number(count), format_number(troops), pct, format_number(returned_pop)
		]

func _on_disband_slider_value_changed(_val: float) -> void:
	_update_disband_slider_ui()

func set_disband_preset(ratio: float) -> void:
	if selected_province.is_empty() or not disband_slider:
		return
	var troops = int(selected_province.get("troops", 0))
	if troops <= 0:
		return
	var val = int(round(troops * ratio))
	if ratio >= 1.0:
		val = troops
	disband_slider.value = clamp(val, 1, troops)
	_update_disband_slider_ui()

func _on_confirm_disband_pressed() -> void:
	if selected_province.is_empty() or not disband_slider:
		return
	var count = int(disband_slider.value)
	var prov_id = selected_province.get("id")
	disband_troops(prov_id, count)

func show_province_info(prov: Dictionary) -> void:
	selected_province = prov
	if province_panel:
		name_label.text = "🏛️ " + str(prov.get("name", "Không rõ"))
		nation_label.text = "Quốc gia: " + str(prov.get("nation", "VIE"))
		faction_label.text = "Phe: " + str(prov.get("faction", prov.get("owner", "Vô chủ")))
		
		var is_player_prov = can_recruit(prov)
		var target_fac = prov.get("faction", prov.get("owner", ""))
		
		if is_player_prov:
			if diplomacy_container:
				diplomacy_container.visible = false
			
			if population_label:
				population_label.visible = true
			if demographics_label:
				demographics_label.visible = true
			if manpower_label:
				manpower_label.visible = true
			if income_label:
				income_label.visible = true
			if troops_label:
				troops_label.visible = true
			if recruit_button:
				recruit_button.visible = true
			if action_buttons_hbox:
				action_buttons_hbox.visible = true
			
			var tot_pop = get_total_population(prov)
			var m_pop = get_male_population(prov)
			var f_pop = get_female_population(prov)
			var m_work = get_male_working_age(prov)
			var current_troops = int(prov.get("troops", 0))
			
			if population_label:
				population_label.text = "👥 Dân số: %s người" % format_number(tot_pop)
			if demographics_label:
				demographics_label.text = "  • Nam: %s | Nữ: %s" % [format_number(m_pop), format_number(f_pop)]
			if manpower_label:
				manpower_label.text = "  • Nam độ tuổi lao động (15-64): %s" % format_number(m_work)
			
			var prov_income = get_province_income(prov)
			if income_label:
				income_label.text = "💰 Thu nhập: +%s đồng/tháng" % format_number(prov_income)
			
			if troops_label:
				troops_label.text = "⚔️ Quân đồn trú: %s quân" % format_number(current_troops)
			
			var has_troops = current_troops > 0
			var can_sweep = current_troops >= 10
			var remaining_quota = get_remaining_pop_quota(prov)
			var max_rec = get_max_recruitable(prov)
			
			if is_paused:
				recruit_button.disabled = true
				recruit_button.text = "⏸ Đang dừng (Pause)"
				move_button.disabled = true
				move_button.text = "Đang dừng"
				if sweep_button:
					sweep_button.disabled = true
					sweep_button.text = "Đang dừng"
				close_dispatch_container()
				close_recruit_container()
			else:
				if remaining_quota <= 0:
					recruit_button.disabled = true
					recruit_button.text = "Đã tuyển hết hạn ngạch tháng %02d" % current_month
					close_recruit_container()
				elif player_gold < COST_PER_TROOP:
					recruit_button.disabled = true
					recruit_button.text = "Không đủ Vàng (Cần ≥ %d💰)" % COST_PER_TROOP
					close_recruit_container()
				else:
					recruit_button.disabled = false
					if recruit_container and recruit_container.visible:
						recruit_button.text = "Đóng tuyển quân ✖"
					else:
						recruit_button.text = "🎖️ Tuyển quân (Tối đa: %s)" % format_number(max_rec)
				
				move_button.disabled = not has_troops
				if not has_troops:
					close_dispatch_container()
					move_button.text = "Hết quân"
				else:
					if dispatch_container and dispatch_container.visible:
						_refresh_dispatch_slider()
					else:
						move_button.text = "Điều quân..."
				
				if sweep_button:
					sweep_button.disabled = not can_sweep
					if can_sweep:
						sweep_button.text = "⚡ Càn quét"
					else:
						sweep_button.text = "Càn quét (≥10)"
				
				# Cập nhật hiển thị nút Ngưng hành quân nếu có đạo quân xuất phát từ tỉnh này
				if cancel_march_button:
					var prov_id = prov.get("id")
					var outgoing_count = 0
					for a in active_armies:
						if a.get("faction") == player_faction and a.get("source", {}).get("id") == prov_id:
							outgoing_count += int(a.get("troops", 0))
					
					if outgoing_count > 0:
						cancel_march_button.visible = true
						cancel_march_button.text = "⛔ Hủy quân đi (%s)" % format_number(outgoing_count)
					else:
						cancel_march_button.visible = false
				# Cập nhật hiển thị nút Giải tán quân (chỉ hiện khi tỉnh có quân và thuộc phe người chơi)
				var disband_button = action_buttons_hbox.get_node_or_null("DisbandButton")
				if disband_button:
					if has_troops:
						disband_button.visible = true
						if disband_container and disband_container.visible:
							disband_button.text = "Đóng giải tán"
						else:
							disband_button.text = "🗑️ Giải tán quân"
					else:
						disband_button.visible = false
						close_disband_container()
		else:
			# Tỉnh đối phương / trung lập: Chuyển sang Bảng Ngoại giao
			if population_label:
				population_label.visible = false
			if demographics_label:
				demographics_label.visible = false
			if manpower_label:
				manpower_label.visible = false
			if income_label:
				income_label.visible = false
			if troops_label:
				troops_label.visible = false
			if recruit_button:
				recruit_button.visible = false
			if action_buttons_hbox:
				action_buttons_hbox.visible = false
			close_dispatch_container()
			close_recruit_container()
			close_disband_container()
			
			if diplomacy_container:
				diplomacy_container.visible = true
				_update_diplomacy_ui(target_fac)
			
		province_panel.visible = true
		update_province_panel_size()
	
	# Cập nhật Shader để làm sáng diện tích và vẽ viền tương phản cho tỉnh đang chọn
	var id_hex = prov.get("id_color", prov.get("original_color", prov["color"]))
	var target_color = Color.from_string(id_hex, Color.BLACK)
	set_province_selection_shader(target_color, true)

func _update_diplomacy_ui(target_fac: String) -> void:
	if not diplomacy_container or not DiplomacyManager:
		return
	
	var prov_count = 0
	for p in provinces_data:
		if p.get("faction") == target_fac:
			prov_count += 1
	
	if dip_faction_header:
		dip_faction_header.text = "🏛️ Phe: %s (Chiếm giữ: %d tỉnh)" % [target_fac, prov_count]
	
	var rel = DiplomacyManager.get_relation(player_faction, target_fac)
	var is_war = DiplomacyManager.is_at_war(player_faction, target_fac)
	var is_ally = DiplomacyManager.is_allied(player_faction, target_fac)
	var has_acc = DiplomacyManager.has_military_access(player_faction, target_fac)
	var is_improving = DiplomacyManager.is_improving_relations(player_faction, target_fac)
	var insult_cd = DiplomacyManager.get_insult_cooldown(player_faction, target_fac)
	
	var status_text = "Trung lập"
	if is_war:
		status_text = "⚔️ ĐANG CÓ CHIẾN TRANH"
	elif is_ally:
		status_text = "🤝 LIÊN MINH QUÂN SỰ"
	elif has_acc:
		status_text = "📜 CÓ QUYỀN HÀNH QUÂN"
	elif rel <= -50:
		status_text = "Thù địch gay gắt"
	elif rel < 0:
		status_text = "Căng thẳng"
	elif rel >= 50:
		status_text = "Rất thân thiết"
	elif rel > 0:
		status_text = "Hữu hảo"
	
	if dip_relation_score_label:
		dip_relation_score_label.text = "Quan hệ: %+d / 100 (%s)" % [rel, status_text]
	
	if dip_relation_bar:
		dip_relation_bar.value = rel
		var bar_color = Color("#ffca28") # vàng
		if rel < -30:
			bar_color = Color("#ff5252") # đỏ
		elif rel > 30:
			bar_color = Color("#69f0ae") # xanh lá
		var sb = StyleBoxFlat.new()
		sb.bg_color = bar_color
		sb.set_corner_radius_all(3)
		dip_relation_bar.add_theme_stylebox_override("fill", sb)
	
	# Top quốc gia thân thiết & thù địch
	var friends = DiplomacyManager.get_top_friends(target_fac, 3)
	var enemies = DiplomacyManager.get_top_enemies(target_fac, 3)
	
	if dip_top_friends_label:
		if friends.is_empty():
			dip_top_friends_label.text = "🟢 Thân thiết: Không có"
		else:
			var arr = []
			for f in friends:
				arr.append("%s (%+d)" % [f["faction"], f["relations"]])
			dip_top_friends_label.text = "🟢 Thân nhất: %s" % ", ".join(arr)
	
	if dip_top_enemies_label:
		if enemies.is_empty():
			dip_top_enemies_label.text = "🔴 Thù địch: Không có"
		else:
			var arr = []
			for e in enemies:
				arr.append("%s (%+d)" % [e["faction"], e["relations"]])
			dip_top_enemies_label.text = "🔴 Thù địch nhất: %s" % ", ".join(arr)
	
	# Nút Cải thiện quan hệ
	if dip_improve_button:
		if is_improving:
			dip_improve_button.text = "🕊️ Dừng cải thiện (5💰/thg)"
			dip_improve_button.modulate = Color(1.2, 1.2, 0.8)
		else:
			dip_improve_button.text = "🕊️ Cải thiện (5💰/thg)"
			dip_improve_button.modulate = Color(1.0, 1.0, 1.0)
	
	# Nút Xúc phạm ngoại giao
	if dip_insult_button:
		if insult_cd > 0:
			dip_insult_button.disabled = true
			dip_insult_button.text = "🤬 Xúc phạm (Chờ %d thg)" % insult_cd
		else:
			dip_insult_button.disabled = false
			dip_insult_button.text = "🤬 Xúc phạm (-30)"
	
	# Nút Xin quyền hành quân
	if dip_access_button:
		if has_acc or is_ally:
			dip_access_button.disabled = true
			dip_access_button.text = "✓ Đã có quyền đi"
		elif rel < 20:
			dip_access_button.disabled = true
			dip_access_button.text = "🚶 Xin hành quân (≥20)"
		else:
			dip_access_button.disabled = false
			dip_access_button.text = "🚶 Xin quyền hành quân"
	
	# Nút Liên minh quân sự
	if dip_alliance_button:
		if is_ally:
			dip_alliance_button.disabled = true
			dip_alliance_button.text = "✓ Đã là Đồng minh"
		elif rel < 75:
			dip_alliance_button.disabled = true
			dip_alliance_button.text = "🤝 Liên minh (≥75)"
		else:
			dip_alliance_button.disabled = false
			dip_alliance_button.text = "🤝 Ký hiệp ước Liên minh"
	
	# Nút Tuyên chiến
	if dip_war_button:
		if is_war:
			dip_war_button.disabled = true
			dip_war_button.text = "⚔️ Đang có chiến tranh"
		else:
			dip_war_button.disabled = false
			dip_war_button.text = "⚔️ Tuyên chiến!"

func _on_dip_improve_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var target_fac = selected_province.get("faction", selected_province.get("owner", ""))
	if target_fac == "" or target_fac == player_faction:
		return
	var is_improving = DiplomacyManager.is_improving_relations(player_faction, target_fac)
	if is_improving:
		DiplomacyManager.set_improving_relations(player_faction, target_fac, false)
		show_notification("🕊️ Đã triệu hồi nhà ngoại giao về từ phe [%s]!" % target_fac)
	else:
		if player_gold < 5:
			show_notification("⚠️ Không đủ Vàng (Cần 5 Vàng để bắt đầu cử nhà ngoại giao)!")
			return
		DiplomacyManager.set_improving_relations(player_faction, target_fac, true)
		show_notification("🕊️ Đã cử nhà ngoại giao sang [%s] (Chi phí: 5 Vàng/tháng, +3 điểm/tháng)!" % target_fac)
	update_gold_display()
	_update_diplomacy_ui(target_fac)

func _on_dip_insult_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var target_fac = selected_province.get("faction", selected_province.get("owner", ""))
	if target_fac == "" or target_fac == player_faction:
		return
	if not DiplomacyManager.can_insult(player_faction, target_fac):
		show_notification("⚠️ Vừa mới xúc phạm phe này! Cần chờ hồi phục quan hệ.")
		return
	DiplomacyManager.insult(player_faction, target_fac)
	var new_rel = DiplomacyManager.get_relation(player_faction, target_fac)
	show_notification("🤬 Bạn đã gửi tối hậu thư xúc phạm phe [%s]! Quan hệ giảm -30 (Còn: %+d)." % [target_fac, new_rel])
	_update_diplomacy_ui(target_fac)

func _on_dip_access_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var target_fac = selected_province.get("faction", selected_province.get("owner", ""))
	if target_fac == "" or target_fac == player_faction:
		return
	var rel = DiplomacyManager.get_relation(player_faction, target_fac)
	if rel < 20:
		show_notification("⚠️ Quan hệ chưa đủ tin cậy (cần ≥ +20, hiện tại: %+d) để xin quyền hành quân!" % rel)
		return
	DiplomacyManager.grant_military_access(player_faction, target_fac)
	show_notification("📜 Phe [%s] đã đồng ý cấp quyền hành quân qua địa phận của họ!" % target_fac)
	_update_diplomacy_ui(target_fac)

func _on_dip_alliance_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var target_fac = selected_province.get("faction", selected_province.get("owner", ""))
	if target_fac == "" or target_fac == player_faction:
		return
	var rel = DiplomacyManager.get_relation(player_faction, target_fac)
	if rel < 75:
		show_notification("⚠️ Quan hệ chưa đạt mức đồng minh (cần ≥ +75, hiện tại: %+d)!" % rel)
		return
	DiplomacyManager.form_alliance(player_faction, target_fac)
	show_notification("🎉 LIÊN MINH QUÂN SỰ thành lập giữa [%s] và [%s]! Mở quyền hành quân 2 chiều." % [player_faction, target_fac])
	_update_diplomacy_ui(target_fac)

func _on_dip_war_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var target_fac = selected_province.get("faction", selected_province.get("owner", ""))
	if target_fac == "" or target_fac == player_faction:
		return
	DiplomacyManager.declare_war(player_faction, target_fac)
	show_notification("⚔️ BẠN ĐÃ CHÍNH THỨC TUYÊN CHIẾN VỚI PHE [%s]! Quan hệ tụt xuống -100." % target_fac)
	_update_diplomacy_ui(target_fac)

func hide_province_panel() -> void:
	selected_province = {}
	close_dispatch_container()
	close_recruit_container()
	if diplomacy_container:
		diplomacy_container.visible = false
	if cancel_march_button:
		cancel_march_button.visible = false
	cancel_move_mode()
	if province_panel:
		province_panel.visible = false
	set_province_selection_shader(Color(0, 0, 0, 0), false)

func can_recruit(prov: Dictionary) -> bool:
	var prov_faction = prov.get("faction", prov.get("owner", ""))
	return prov_faction == player_faction

func _on_recruit_button_pressed() -> void:
	if selected_province.is_empty():
		return
	
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return
	
	if recruit_container and recruit_container.visible:
		close_recruit_container()
	else:
		open_recruit_container()

func _on_move_button_pressed() -> void:
	if selected_province.is_empty():
		return
	
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return
	
	var troops = int(selected_province.get("troops", 0))
	if troops <= 0:
		show_notification("⚠️ %s không có quân để điều động!" % selected_province.get("name"))
		return
	
	if dispatch_container:
		if dispatch_container.visible:
			close_dispatch_container()
			cancel_move_mode()
		else:
			close_recruit_container()
			close_disband_container()
			dispatch_container.visible = true
			move_button.text = "Đóng điều quân"
			_refresh_dispatch_slider()
			update_province_panel_size()

func _refresh_dispatch_slider() -> void:
	if selected_province.is_empty() or not troop_slider:
		return
	var troops = int(selected_province.get("troops", 0))
	troop_slider.min_value = 1
	troop_slider.max_value = max(1, troops)
	troop_slider.step = 1
	if troop_slider.value > troops or troop_slider.value < 1:
		troop_slider.value = max(1, int(ceil(troops * 0.5)))
	_update_dispatch_count_label()

func _set_slider_preset(ratio: float) -> void:
	if selected_province.is_empty() or not troop_slider:
		return
	var troops = int(selected_province.get("troops", 0))
	if troops <= 0:
		return
	var val = int(round(troops * ratio))
	if ratio >= 1.0:
		val = troops
	else:
		val = max(1, val)
	troop_slider.value = val

func _on_troop_slider_value_changed(_val: float) -> void:
	_update_dispatch_count_label()

func _update_dispatch_count_label() -> void:
	if selected_province.is_empty() or not dispatch_count_label or not troop_slider:
		return
	var max_troops = int(selected_province.get("troops", 0))
	var cur_val = int(troop_slider.value)
	var percent = int(round((float(cur_val) / max(1, max_troops)) * 100.0))
	dispatch_count_label.text = "%s / %s (%d%%)" % [format_number(cur_val), format_number(max_troops), percent]

func _on_confirm_target_pressed() -> void:
	if selected_province.is_empty():
		return
	
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return
	
	if is_move_mode:
		cancel_move_mode()
		show_notification("Đã hủy chọn mục tiêu.")
		return
	
	var troops = int(selected_province.get("troops", 0))
	if troops <= 0:
		show_notification("⚠️ %s không có quân để điều động!" % selected_province.get("name"))
		return
	
	is_move_mode = true
	move_source_province = selected_province
	selected_troop_count = int(troop_slider.value)
	
	if confirm_target_button:
		confirm_target_button.text = "❌ Hủy chọn mục tiêu"
	
	show_notification("👉 [Điều %s quân từ %s] Click chọn tỉnh đích trên bản đồ..." % [
		format_number(selected_troop_count), selected_province.get("name")
	])

func cancel_move_mode() -> void:
	is_move_mode = false
	move_source_province = {}
	selected_troop_count = 0
	if confirm_target_button:
		confirm_target_button.text = "🎯 Chọn mục tiêu"

# ==============================================================================
# HỆ THỐNG HÀNH QUÂN THỜI GIAN THỰC (REAL-TIME ARMY MOVEMENT)
# ==============================================================================
func _on_sweep_button_pressed() -> void:
	if selected_province.is_empty():
		return
	
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return
	
	if not can_recruit(selected_province):
		show_notification("⚠️ Chỉ có thể ra lệnh càn quét từ tỉnh thuộc phe mình!")
		return
	
	var total_troops = int(selected_province.get("troops", 0))
	if total_troops < 10:
		show_notification("⚠️ Cần tối thiểu 10 quân để phát lệnh càn quét!")
		return
	
	var source_prov = selected_province
	var source_faction = source_prov.get("faction", player_faction)
	
	# Quét tìm tất cả các tỉnh GIÁP RANH TRỰC TIẾP thuộc PHE ĐANG CÓ CHIẾN TRANH
	var enemy_neighbors: Array = []
	for nb in get_province_neighbors(source_prov):
		var nb_faction = nb.get("faction", nb.get("owner", ""))
		if nb_faction != source_faction:
			if DiplomacyManager and DiplomacyManager.is_at_war(source_faction, nb_faction):
				enemy_neighbors.append(nb)
	
	if enemy_neighbors.is_empty():
		show_notification("⚠️ Chưa tuyên chiến với bất kỳ phe láng giềng nào! Không thể càn quét khi đang hòa bình.")
		return
	
	var n_targets = enemy_neighbors.size()
	
	# Giữ lại quân phòng thủ tại tỉnh nhà (mặc định 10 quân, hoặc ít hơn nếu thiếu)
	var garrison_kept = 10
	if total_troops - garrison_kept < n_targets:
		garrison_kept = max(1, total_troops - n_targets)
	
	var available_troops = total_troops - garrison_kept
	if available_troops < n_targets:
		show_notification("⚠️ Quân số không đủ để chia cho %d mũi tiến công giáp ranh!" % n_targets)
		return
	
	var troops_per_wing = int(available_troops / n_targets)
	if troops_per_wing <= 0:
		show_notification("⚠️ Quân số quá ít để chia cho %d mũi tiến công giáp ranh!" % n_targets)
		return
	
	var actual_total_dispatched = troops_per_wing * n_targets
	garrison_kept = total_troops - actual_total_dispatched # Phần dư dồn lại vào lính thủ
	
	# Xuất N đạo quân tỏa đi các tỉnh địch cùng lúc
	for target_prov in enemy_neighbors:
		dispatch_army(source_prov, target_prov, troops_per_wing, false)
	
	# Đảm bảo số quân tại tỉnh xuất phát được cập nhật chính xác
	source_prov["troops"] = garrison_kept
	update_troop_label(source_prov)
	show_province_info(source_prov)
	
	# Đóng bảng slider nếu đang mở
	close_dispatch_container()
	if is_move_mode:
		cancel_move_mode()
	
	var target_names: Array = []
	for t in enemy_neighbors:
		target_names.append(t.get("name", ""))
	
	show_notification("⚡ CÀN QUÉT: %s đã tỏa %d cánh quân (mỗi cánh %d lính) đánh chiếm [%s]! (Giữ lại %d lính thủ)" % [
		source_prov.get("name"), n_targets, troops_per_wing, ", ".join(target_names), garrison_kept
	])
	print("--- PHÁT LỆNH ĐÁNH LAN (CÀN QUÉT) ---")
	print("Tỉnh xuất phát: %s (%d lính) -> Chia %d cánh x %d lính -> Các tỉnh: %s. Giữ lại thủ: %d" % [
		source_prov.get("name"), total_troops, n_targets, troops_per_wing, ", ".join(target_names), garrison_kept
	])

func execute_troop_action(source: Dictionary, target: Dictionary, troop_amount: Variant) -> void:
	if not can_send_troops_to(source, target, true):
		return
	var count = 0
	if troop_amount is float:
		count = int(ceil(source.get("troops", 0) * troop_amount))
	else:
		count = int(troop_amount)
	dispatch_army(source, target, count)

func dispatch_army(source: Dictionary, target: Dictionary, troop_count: int, show_notify: bool = true) -> bool:
	if source.is_empty() or target.is_empty():
		return false
	
	var source_id = str(source.get("id"))
	var target_id = str(target.get("id"))
	if source_id == target_id:
		return false
	
	var source_troops = int(source.get("troops", 0))
	if source_troops <= 0:
		if show_notify:
			show_notification("⚠️ %s không có quân để điều động!" % source.get("name"))
		return false
	
	# Cổng kiểm tra Ngoại giao (Diplomacy Guard Check): Bắt buộc kiểm tra quan hệ ngoại giao trước khi phát lệnh
	if not can_send_troops_to(source, target, show_notify):
		return false
	
	var source_faction: String = source.get("faction", player_faction)
	var target_faction: String = target.get("faction", target.get("owner", ""))
	
	# Tìm đường đi an toàn theo đồ thị láng giềng (Graph Pathfinding)
	var path: Array = find_path(source, target, source_faction)
	if path.is_empty() or path.size() < 2:
		if show_notify:
			show_notification("⚠️ Không có đường đi an toàn đến mục tiêu!")
		return false
	
	var moving_troops: int = clamp(troop_count, 1, source_troops)
	var remaining_in_source: int = source_troops - moving_troops
	
	# Trừ quân ở tỉnh xuất phát ngay lập tức
	source["troops"] = remaining_in_source
	update_troop_label(source)
	
	# Nếu đang mở bảng thông tin của tỉnh xuất phát, làm mới lại giao diện
	if not selected_province.is_empty() and selected_province.get("id") == source.get("id"):
		show_province_info(source)
	
	# 1. Đường hành quân (Line2D nối qua TẤT CẢ các chặng waypoints trên lộ trình)
	var line = Line2D.new()
	line.name = "MarchLine_%s_%s" % [source_id, target_id]
	line.width = 2.5
	line.default_color = Color(1.0, 0.85, 0.25, 0.65)
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	for prov in path:
		line.add_point(get_province_local_pos(prov))
	if armies_container:
		armies_container.add_child(line)
	
	# 2. Node hiển thị đơn vị lính hành quân trên bản đồ
	var start_pos = get_province_local_pos(path[0])
	var troop_script = load("res://troop.gd")
	var badge_root = troop_script.new()
	badge_root.name = "ArmyBadge_%s_%s" % [source_id, target_id]
	badge_root.position = start_pos
	badge_root.scale = Vector2(0.65, 0.65) # Đồng bộ thu nhỏ nhãn hành quân
	badge_root.z_index = 10

	var badge = PanelContainer.new()
	badge.name = "Panel"
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	style.border_color = Color(1.0, 0.84, 0.0, 1.0) # Viền vàng ánh kim nổi bật
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	badge.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.name = "ArmyLabel"
	label.text = "⚔ " + str(moving_troops)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	badge.add_child(label)
	
	var army_badge_size = Vector2(34, 16)
	badge.custom_minimum_size = army_badge_size
	badge.size = army_badge_size
	badge.pivot_offset = army_badge_size / 2.0
	badge.position = -army_badge_size / 2.0
	badge_root.add_child(badge)
	
	if armies_container:
		armies_container.add_child(badge_root)
	
	var total_legs = path.size() - 1
	var army_data = {
		"path": path,
		"current_leg": 0,
		"total_legs": total_legs,
		"leg_progress": 0.0,
		"leg_duration": 1.6, # 1.6 giây cho mỗi chặng tỉnh liền kề (ở tốc độ 1x)
		"source": source,
		"target": target,
		"troops": moving_troops,
		"faction": source_faction,
		"badge_root": badge_root,
		"line": line
	}

	# Gán army_data vào troop node và khởi tạo nút Hủy lệnh nếu là quân của người chơi
	badge_root.army_data = army_data
	badge_root.movement_canceled.connect(_on_army_movement_canceled)
	if source_faction == player_faction and badge_root.has_method("setup_cancel_button"):
		badge_root.setup_cancel_button(true)

	active_armies.append(army_data)
	
	if show_notify:
		if path.size() > 2:
			var waypoints_names: Array = []
			for p in path.slice(1, path.size() - 1):
				waypoints_names.append(p.get("name", ""))
			show_notification("🚩 %d quân từ %s tiến về %s (qua an toàn: %s, còn lại: %d quân)!" % [
				moving_troops, source.get("name"), target.get("name"), ", ".join(waypoints_names), remaining_in_source
			])
		else:
			show_notification("🚩 %d quân từ %s tiến về %s (còn lại: %d quân)!" % [
				moving_troops, source.get("name"), target.get("name"), remaining_in_source
			])
	
	print("--- XUẤT QUÂN HÀNH QUÂN THEO ĐỒ THỊ ---")
	var path_names: Array = []
	for p in path:
		path_names.append(p.get("name", ""))
	print("Lộ trình: %s (%d lính). Số chặng: %d" % [" -> ".join(path_names), moving_troops, total_legs])
	return true

func _resolve_army_arrival(army: Dictionary) -> void:
	var source = army["source"]
	var target = army["target"]
	var moving_troops: int = army["troops"]
	var army_faction: String = army["faction"]
	
	var target_faction = target.get("faction", target.get("owner", ""))
	var is_same_faction = (target_faction == army_faction)
	var is_allied = (DiplomacyManager and DiplomacyManager.is_allied(army_faction, target_faction))
	var has_access = (DiplomacyManager and DiplomacyManager.has_military_access(army_faction, target_faction))
	var is_war = (DiplomacyManager and DiplomacyManager.is_at_war(army_faction, target_faction))
	
	if is_same_faction:
		target["troops"] = target.get("troops", 0) + moving_troops
		show_notification("🚚 TIẾP VIỆN THÀNH CÔNG: %d quân đã hội quân tại %s (Tổng đồn trú: %d quân)!" % [
			moving_troops, target.get("name"), target["troops"]
		])
		print("--- VIỆN BINH ĐẾN NƠI ---")
		print("Hội quân: %d quân từ %s đến %s (Tổng quân: %d)" % [
			moving_troops, source.get("name"), target.get("name"), target["troops"]
		])
	elif is_allied:
		target["troops"] = target.get("troops", 0) + moving_troops
		show_notification("🤝 TIẾP VIỆN ĐỒNG MINH: %d quân đã chi viện cho %s (%s) (Tổng đồn trú: %d quân)!" % [
			moving_troops, target.get("name"), target_faction, target["troops"]
		])
		print("--- CHI VIỆN ĐỒNG MINH ---")
		print("Chi viện: %d quân từ %s đến %s (%s)" % [
			moving_troops, source.get("name"), target.get("name"), target_faction
		])
	elif has_access and not is_war:
		target["troops"] = target.get("troops", 0) + moving_troops
		show_notification("🚶 ĐỒN TRÚ/QUÁ CẢNH: %d quân đã tập kết tại %s (%s) theo hiệp ước hành quân!" % [
			moving_troops, target.get("name"), target_faction
		])
	else:
		# Giao tranh (Combat)!
		if DiplomacyManager and not DiplomacyManager.is_at_war(army_faction, target_faction):
			DiplomacyManager.declare_war(army_faction, target_faction)
			show_notification("⚔️ CHIẾN TRANH BÙNG NỔ giữa %s và %s!" % [army_faction, target_faction])
		
		var defender_troops = target.get("troops", 0)
		print("--- GIAO TRANH BẮT ĐẦU ---")
		print("Công: %s (%s) mang %d quân" % [source.get("name"), army_faction, moving_troops])
		print("Thủ: %s (%s) có %d quân" % [target.get("name"), target_faction, defender_troops])
		
		if moving_troops > defender_troops:
			var leftover_at_target = moving_troops - defender_troops
			target["troops"] = leftover_at_target
			target["faction"] = army_faction
			if target.has("owner"):
				target["owner"] = army_faction
			
			var new_faction_color = faction_colors.get(army_faction, Color.RED)
			repaint_province(target, new_faction_color)
			update_gold_display()
			
			show_notification("⚔️ THẮNG TRẬN! Chiếm %s thành công (đồn trú: %d quân)!" % [
				target.get("name"), leftover_at_target
			])
			print("Kết quả: Thắng trận! Đã chiếm đóng %s với %d quân còn lại." % [target.get("name"), leftover_at_target])
		else:
			target["troops"] = defender_troops - moving_troops
			show_notification("⚠️ TẤN CÔNG THẤT BẠI! %d quân tử trận tại %s. Quân phòng thủ còn %d." % [
				moving_troops, target.get("name"), target["troops"]
			])
			print("Kết quả: Thất bại! Quân phòng thủ %s còn lại %d." % [target.get("name"), target["troops"]])
	
	update_troop_label(target)
	if not selected_province.is_empty() and selected_province.get("id") == target.get("id"):
		show_province_info(target)

# ==============================================================================
# HỆ THỐNG HỦY LỆNH DI CHUYỂN (CANCEL MOVEMENT)
# ==============================================================================
func is_province_safe_for_faction(prov: Dictionary, mover_faction: String) -> bool:
	if prov == null or prov.is_empty():
		return false
	var prov_fac = str(prov.get("faction", prov.get("owner", "")))
	if prov_fac == mover_faction:
		return true
	if DiplomacyManager:
		if DiplomacyManager.is_at_war(mover_faction, prov_fac):
			return false
		if DiplomacyManager.is_allied(mover_faction, prov_fac) or DiplomacyManager.has_military_access(mover_faction, prov_fac):
			return true
	return false

func determine_army_stop_province(army_data: Dictionary) -> Dictionary:
	if not army_data or not (army_data is Dictionary):
		return {}
	
	var path: Array = army_data.get("path", [])
	var mover_faction: String = str(army_data.get("faction", ""))
	var curr_leg: int = int(army_data.get("current_leg", 0))
	var progress: float = float(army_data.get("leg_progress", 0.0))
	var source: Dictionary = army_data.get("source", {})
	
	if path.is_empty():
		return source
	if path.size() == 1:
		return path[0]
	
	curr_leg = clamp(curr_leg, 0, path.size() - 2)
	var prov_a: Dictionary = path[curr_leg]
	var prov_b: Dictionary = path[curr_leg + 1]
	
	var a_safe = is_province_safe_for_faction(prov_a, mover_faction)
	var b_safe = is_province_safe_for_faction(prov_b, mover_faction)
	
	# Nếu đã đi hơn nửa đường (progress >= 0.5) và tỉnh B an toàn -> Đóng quân tại tỉnh B
	if progress >= 0.5 and b_safe:
		return prov_b
	# Nếu tỉnh A an toàn -> Đóng quân tại tỉnh A
	if a_safe:
		return prov_a
	if b_safe:
		return prov_b
	
	# Tìm lùi về các chặng an toàn trước đó trên lộ trình
	for k in range(curr_leg - 1, -1, -1):
		if is_province_safe_for_faction(path[k], mover_faction):
			return path[k]
	
	return source if not source.is_empty() else prov_a

func _on_army_movement_canceled(army_data: Dictionary) -> void:
	# Xử lý khi troop node phát tín hiệu hủy di chuyển
	var troops = int(army_data.get("troops", 0))
	var badge_root = army_data.get("badge_root")
	var cancel_pos = Vector2.ZERO
	if army_data.has("cancel_pos") and army_data["cancel_pos"] != Vector2.ZERO:
		cancel_pos = army_data["cancel_pos"]
	elif is_instance_valid(badge_root):
		cancel_pos = badge_root.position
	elif army_data.has("start_pos"):
		cancel_pos = army_data["start_pos"]

	# 1. Xác định tỉnh tiếp nhận quân (Tỉnh dừng chân gần nhất đã tính trong troop.gd hoặc tính lại)
	var dest_prov = army_data.get("stop_province")
	if not dest_prov or not (dest_prov is Dictionary) or dest_prov.is_empty():
		dest_prov = determine_army_stop_province(army_data)
	if not dest_prov or not (dest_prov is Dictionary) or dest_prov.is_empty():
		dest_prov = army_data.get("source", {})
	
	# Lấy tham chiếu chuẩn trong provinces_by_id nếu có
	var prov_id = str(dest_prov.get("id", ""))
	if prov_id != "" and provinces_by_id.has(prov_id):
		dest_prov = provinces_by_id[prov_id]
	
	if cancel_pos == Vector2.ZERO and not dest_prov.is_empty():
		cancel_pos = get_province_local_pos(dest_prov)

	# 2. Đóng quân / hoàn trả quân vào tỉnh tiếp nhận (tuyệt đối không nhảy cóc về điểm xuất phát ban đầu)
	if dest_prov and dest_prov is Dictionary and not dest_prov.is_empty():
		dest_prov["troops"] = int(dest_prov.get("troops", 0)) + troops
		update_troop_label(dest_prov)
		if not selected_province.is_empty():
			show_province_info(selected_province)

	# 3. Xóa khỏi danh sách active_armies
	if active_armies.has(army_data):
		active_armies.erase(army_data)

	# 4. Dọn dẹp visual (line)
	var line = army_data.get("line")
	if is_instance_valid(line):
		line.queue_free()

	# 5. Hiệu ứng visual: Floating text nổi lên trên bản đồ
	var dest_name = dest_prov.get("name", "tỉnh dừng chân") if not dest_prov.is_empty() else "tỉnh"
	spawn_floating_text("⛔ Đã dừng tại %s (+%s)" % [dest_name, format_number(troops)], cancel_pos, Color(1.0, 0.4, 0.4))

	# 6. Hiệu ứng âm thanh procedural
	play_cancel_sound()

	# 7. Thông báo trên thanh UI
	if is_instance_valid(self) and not is_paused:
		show_notification("⛔ Đã ngưng hành quân! %s quân đã đóng quân tại %s." % [
			format_number(troops), dest_name
		])

func cancel_army_movement(army_data: Dictionary) -> void:
	# Hàm công khai để hủy di chuyển từ bên ngoài (UI, hotkey, panel, v.v.)
	if not army_data or not army_data is Dictionary:
		return

	var badge_root = army_data.get("badge_root")
	if is_instance_valid(badge_root) and badge_root.has_method("cancel_movement"):
		badge_root.cancel_movement()
	else:
		if not army_data.has("stop_province") or army_data["stop_province"].is_empty():
			army_data["stop_province"] = determine_army_stop_province(army_data)
		_on_army_movement_canceled(army_data)

func _on_cancel_march_button_pressed() -> void:
	if selected_province.is_empty():
		return
	var prov_id = selected_province.get("id")
	var to_cancel: Array = []
	for a in active_armies:
		if a.get("faction") == player_faction and a.get("source", {}).get("id") == prov_id:
			to_cancel.append(a)

	if to_cancel.is_empty():
		show_notification("Không có đạo quân nào đang xuất phát từ %s!" % selected_province.get("name"))
		return

	for a in to_cancel:
		cancel_army_movement(a)

	show_province_info(selected_province)

func _on_disband_button_pressed() -> void:
	if selected_province.is_empty():
		return
	if disband_container and disband_container.visible:
		close_disband_container()
	else:
		open_disband_container()

func disband_troops(province_id: String, amount: int) -> bool:
	if is_paused:
		show_notification("⏸ Thời gian đang dừng, hãy tiếp tục thời gian để thực hiện hành động!")
		return false
	if province_id.is_empty() or amount <= 0:
		return false
	if not provinces_by_id.has(province_id):
		return false
	var prov = provinces_by_id[province_id]
	if not can_recruit(prov):
		show_notification("⚠️ Bạn chỉ có thể giải tán quân tại tỉnh thuộc phe mình!")
		return false
	var current_troops = int(prov.get("troops", 0))
	if current_troops < amount:
		show_notification("⚠️ %s không đủ %s quân để giải tán!" % [prov.get("name"), format_number(amount)])
		return false

	prov["troops"] = current_troops - amount
	var returned_pop = int(amount * 0.5)
	prov["total_population"] = int(prov.get("total_population", 0)) + returned_pop

	if not prov.has("demographics"):
		prov["demographics"] = {"male": {}, "female": {}}
	if not prov["demographics"].has("male"):
		prov["demographics"]["male"] = {"under_18": 0, "working_age": 0, "senior": 0}
	if not prov["demographics"].has("female"):
		prov["demographics"]["female"] = {"under_18": 0, "working_age": 0, "senior": 0}

	var male_returned = int(returned_pop * 0.5)
	var male_working_returned = int(male_returned * 0.7)
	prov["demographics"]["male"]["working_age"] = int(prov["demographics"]["male"].get("working_age", 0)) + male_working_returned

	update_troop_label(prov)
	update_gold_display()

	var prov_pos = get_province_local_pos(prov)
	spawn_floating_text("-%s Quân (+%s Dân)" % [format_number(amount), format_number(returned_pop)], prov_pos, Color(1.0, 0.55, 0.2))
	show_notification("🗑️ Đã giải tán %s quân tại %s (hoàn trả +%s vào dân số)!" % [
		format_number(amount), prov.get("name"), format_number(returned_pop)
	])

	close_disband_container()
	if not selected_province.is_empty() and selected_province.get("id") == province_id:
		show_province_info(prov)
	return true

func spawn_floating_text(text: String, pos: Vector2, color: Color = Color(1.0, 0.9, 0.3)) -> void:
	var label = Label.new()
	label.text = text
	label.z_index = 35
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("outline_size", 4)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var initial_size = Vector2(160, 22)
	label.custom_minimum_size = initial_size
	label.size = initial_size
	label.pivot_offset = initial_size * 0.5
	label.position = pos - Vector2(initial_size.x * 0.5, 28.0)
	
	if armies_container:
		armies_container.add_child(label)
	else:
		add_child(label)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 32.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)

func play_cancel_sound() -> void:
	var player = AudioStreamPlayer.new()
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050
	gen.buffer_length = 0.15
	player.stream = gen
	add_child(player)
	player.play()
	var playback = player.get_stream_playback()
	if playback:
		var sample_count = int(22050 * 0.1)
		for i in range(sample_count):
			var t = float(i) / 22050.0
			var freq = lerp(460.0, 220.0, float(i) / sample_count)
			var env = (1.0 - float(i) / sample_count) * 0.18
			var sample = sin(2.0 * PI * freq * t) * env
			playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(0.25).timeout.connect(player.queue_free)

func show_notification(msg: String) -> void:
	if notification_panel and notification_label:
		notification_label.text = msg
		notification_panel.visible = true
		
		if not is_move_mode:
			var timer = get_tree().create_timer(3.5)
			notify_timer = timer
			timer.timeout.connect(func():
				if notify_timer == timer and not is_move_mode and notification_panel:
					notification_panel.visible = false
			)
