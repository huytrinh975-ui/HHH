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
@onready var move_button: Button = $UI/ProvincePanel/VBoxContainer/ActionButtonsHBox/MoveButton
@onready var sweep_button: Button = $UI/ProvincePanel/VBoxContainer/ActionButtonsHBox/SweepButton
@onready var dispatch_container: VBoxContainer = $UI/ProvincePanel/VBoxContainer/DispatchContainer
@onready var dispatch_count_label: Label = $UI/ProvincePanel/VBoxContainer/DispatchContainer/DispatchHeader/DispatchCountLabel
@onready var troop_slider: HSlider = $UI/ProvincePanel/VBoxContainer/DispatchContainer/TroopSlider
@onready var preset_25_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset25Button
@onready var preset_50_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset50Button
@onready var preset_75_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset75Button
@onready var preset_100_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/PresetHBox/Preset100Button
@onready var confirm_target_button: Button = $UI/ProvincePanel/VBoxContainer/DispatchContainer/ConfirmTargetButton
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
var current_year: int = 2026

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
const RECRUIT_COST: int = 20           # Chi phí cũ (+10 lính)
const INCOME_PER_PROVINCE: int = 25    # Thuế thu về mỗi tỉnh vào ngày đầu tháng

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

func _ready() -> void:
	# Cập nhật phe người chơi từ GameManager nếu có
	if GameManager and GameManager.player_faction != "":
		player_faction = GameManager.player_faction
	
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
	
	# Kết nối sự kiện điều khiển thời gian
	if pause_button:
		pause_button.pressed.connect(toggle_pause)
	if speed_1_button:
		speed_1_button.pressed.connect(func(): set_speed(1))
	if speed_2_button:
		speed_2_button.pressed.connect(func(): set_speed(2))
	if speed_3_button:
		speed_3_button.pressed.connect(func(): set_speed(3))
	
	# Khởi tạo hiển thị ban đầu
	update_date_display()
	update_gold_display()
	update_speed_buttons_ui()
	
	# Thông báo chào mừng đầu trận
	var mode_name = "LOẠN 63 XỨ QUÂN" if (GameManager and GameManager.current_mode == GameManager.MODE_63_WARLORDS) else "TỨ QUỐC TRANH HÙNG"
	show_notification("🚩 CHIẾN DỊCH: %s! Bạn đang chỉ huy phe [%s]." % [mode_name, player_faction])

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
		army["progress"] += dt / army["duration"]
		
		if army["progress"] >= 1.0:
			army["progress"] = 1.0
			_resolve_army_arrival(army)
			if is_instance_valid(army["badge_root"]):
				army["badge_root"].queue_free()
			if is_instance_valid(army["line"]):
				army["line"].queue_free()
			active_armies.remove_at(i)
		else:
			var t = army["progress"]
			var current_pos = army["start_pos"].lerp(army["end_pos"], t)
			if is_instance_valid(army["badge_root"]):
				army["badge_root"].position = current_pos
			
			# KIỂM TRA CHẶN ĐÁNH DỌC ĐƯỜNG (ZONE OF CONTROL / INTERCEPT)
			if t > 0.05:
				var current_prov = get_province_at_local_pos(current_pos)
				if not current_prov.is_empty():
					var prov_id = current_prov.get("id")
					var source_id = army["source"].get("id")
					var target_id = army["target"].get("id")
					
					# Chỉ chặn đánh nếu là tỉnh trung gian (khác tỉnh xuất phát và chưa tới tỉnh đích)
					if prov_id != source_id and prov_id != target_id:
						var prov_faction = current_prov.get("faction", current_prov.get("owner", ""))
						var prov_troops = int(current_prov.get("troops", 0))
						
						# Nếu tỉnh trung gian thuộc PHE ĐỊCH và CÓ LÍNH ĐỒN TRÚ (> 0)
						if prov_faction != army["faction"] and prov_troops > 0:
							_resolve_army_intercept(army, current_prov)
							if is_instance_valid(army["badge_root"]):
								army["badge_root"].queue_free()
							if is_instance_valid(army["line"]):
								army["line"].queue_free()
							active_armies.remove_at(i)
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

func trigger_monthly_economy() -> void:
	var owned_count = get_player_province_count()
	var income = owned_count * INCOME_PER_PROVINCE
	player_gold += income
	update_gold_display()
	
	show_notification("💰 ĐẦU THÁNG %02d/%d: Thu thuế +%d vàng! Đã mở đợt tuyển quân mới cho các tỉnh." % [current_month, current_year, income])
	print("Kinh te dau thang %02d/%d: Thu +%d vang (so tinh: %d, tong vang: %d)" % [current_month, current_year, income, owned_count, player_gold])
	
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
		var monthly_income = get_player_province_count() * INCOME_PER_PROVINCE
		gold_label.text = "💰 %d (+%d/thg)" % [player_gold, monthly_income]

func toggle_pause() -> void:
	set_paused(not is_paused)

func set_paused(paused: bool) -> void:
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
			
			dispatch_army(source_prov, clicked_prov, source_troops)
			show_notification("⚡ [Double-click] Đã điều toàn bộ 100% (%s quân) từ %s sang %s!" % [
				format_number(source_troops), source_prov.get("name"), clicked_prov.get("name")
			])
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
	if (dispatch_container and dispatch_container.visible) or (recruit_container and recruit_container.visible):
		province_panel.offset_top = -450.0
	else:
		province_panel.offset_top = -290.0

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

func show_province_info(prov: Dictionary) -> void:
	selected_province = prov
	if province_panel:
		name_label.text = "🏛️ " + str(prov.get("name", "Không rõ"))
		nation_label.text = "Quốc gia: " + str(prov.get("nation", "VIE"))
		faction_label.text = "Phe: " + str(prov.get("faction", prov.get("owner", "Vô chủ")))
		
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
		
		troops_label.text = "⚔️ Quân đồn trú: %s quân" % format_number(current_troops)
		
		var is_player_prov = can_recruit(prov)
		var has_troops = current_troops > 0
		var can_sweep = is_player_prov and current_troops >= 10
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
		elif is_player_prov:
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
		else:
			recruit_button.disabled = true
			recruit_button.text = "Khác phe (Không thể tuyển)"
			move_button.disabled = true
			move_button.text = "Khác phe"
			if sweep_button:
				sweep_button.disabled = true
				sweep_button.text = "Khác phe"
			close_dispatch_container()
			close_recruit_container()
			
		province_panel.visible = true
		update_province_panel_size()
	
	# Cập nhật Shader để làm sáng diện tích và vẽ viền tương phản cho tỉnh đang chọn
	var id_hex = prov.get("id_color", prov.get("original_color", prov["color"]))
	var target_color = Color.from_string(id_hex, Color.BLACK)
	set_province_selection_shader(target_color, true)

func hide_province_panel() -> void:
	selected_province = {}
	close_dispatch_container()
	close_recruit_container()
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
	
	# Quét tìm tất cả các tỉnh GIÁP RANH TRỰC TIẾP thuộc PHE ĐỊCH
	var enemy_neighbors: Array = []
	for nb in get_province_neighbors(source_prov):
		var nb_faction = nb.get("faction", nb.get("owner", ""))
		if nb_faction != source_faction:
			enemy_neighbors.append(nb)
	
	if enemy_neighbors.is_empty():
		show_notification("⚠️ Không có tỉnh địch giáp ranh để đánh lan!")
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
	var count = 0
	if troop_amount is float:
		count = int(ceil(source.get("troops", 0) * troop_amount))
	else:
		count = int(troop_amount)
	dispatch_army(source, target, count)

func dispatch_army(source: Dictionary, target: Dictionary, troop_count: int, show_notify: bool = true) -> void:
	var source_troops = int(source.get("troops", 0))
	if source_troops <= 0:
		if show_notify:
			show_notification("⚠️ %s không có quân để điều động!" % source.get("name"))
		return
	
	var moving_troops: int = clamp(troop_count, 1, source_troops)
	var remaining_in_source: int = source_troops - moving_troops
	
	# Trừ quân ở tỉnh xuất phát ngay lập tức
	source["troops"] = remaining_in_source
	update_troop_label(source)
	
	# Nếu đang mở bảng thông tin của tỉnh xuất phát, làm mới lại giao diện
	if not selected_province.is_empty() and selected_province.get("id") == source.get("id"):
		show_province_info(source)
	
	var start_pos = get_province_local_pos(source)
	var end_pos = get_province_local_pos(target)
	
	# 1. Đường hành quân (Line2D nối từ tâm xuất phát đến tâm đích)
	var line = Line2D.new()
	line.name = "MarchLine_%s_%s" % [str(source.get("id")), str(target.get("id"))]
	line.width = 2.5
	line.default_color = Color(1.0, 0.85, 0.25, 0.65)
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.add_point(start_pos)
	line.add_point(end_pos)
	if armies_container:
		armies_container.add_child(line)
	
	# 2. Node hiển thị đơn vị lính hành quân trên bản đồ
	var badge_root = Node2D.new()
	badge_root.name = "ArmyBadge_%s_%s" % [str(source.get("id")), str(target.get("id"))]
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
	
	var army_data = {
		"source": source,
		"target": target,
		"troops": moving_troops,
		"faction": source.get("faction", player_faction),
		"start_pos": start_pos,
		"end_pos": end_pos,
		"progress": 0.0,
		"duration": 3.5, # 3.5 giây ở tốc độ 1x (nằm trong khoảng 3-5 giây)
		"badge_root": badge_root,
		"line": line
	}
	active_armies.append(army_data)
	
	if show_notify:
		show_notification("🚩 %d quân xuất phát từ %s tiến về %s (còn lại: %d quân)!" % [
			moving_troops, source.get("name"), target.get("name"), remaining_in_source
		])
	print("--- XUAT QUAN HANH QUAN ---")
	print("Xuat phat: %d quan tu %s -> %s (con lai tai tinh goc: %d)" % [
		moving_troops, source.get("name"), target.get("name"), remaining_in_source
	])

func _resolve_army_arrival(army: Dictionary) -> void:
	var source = army["source"]
	var target = army["target"]
	var moving_troops: int = army["troops"]
	var army_faction: String = army["faction"]
	
	var target_faction = target.get("faction", target.get("owner", ""))
	var is_friendly = (target_faction == army_faction)
	
	if is_friendly:
		target["troops"] = target.get("troops", 0) + moving_troops
		show_notification("🚚 TIẾP VIỆN THÀNH CÔNG: %d quân đã hội quân tại %s (Tổng đồn trú: %d quân)!" % [
			moving_troops, target.get("name"), target["troops"]
		])
		print("--- VIEN BINH DEN NOI ---")
		print("Hoi quan: %d quan tu %s den %s (Tong quan: %d)" % [
			moving_troops, source.get("name"), target.get("name"), target["troops"]
		])
	else:
		var defender_troops = target.get("troops", 0)
		print("--- GIAO TRANH BAT DAU ---")
		print("Cong: %s (%s) mang %d quân" % [source.get("name"), army_faction, moving_troops])
		print("Thu: %s (%s) có %d quân" % [target.get("name"), target_faction, defender_troops])
		
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
			print("Ket qua: Thang tran! Da chiem dong %s voi %d quan con lai." % [target.get("name"), leftover_at_target])
		else:
			target["troops"] = defender_troops - moving_troops
			show_notification("⚠️ TẤN CÔNG THẤT BẠI! %d quân tử trận tại %s. Quân phòng thủ còn %d." % [
				moving_troops, target.get("name"), target["troops"]
			])
			print("Ket qua: That bai! Quan phong thu %s con lai %d." % [target.get("name"), target["troops"]])
	
	update_troop_label(target)
	if not selected_province.is_empty() and selected_province.get("id") == target.get("id"):
		show_province_info(target)

# ==============================================================================
# XỬ LÝ CHẶN ĐÁNH DỌC ĐƯỜNG HÀNH QUÂN (ZONE OF CONTROL / INTERCEPT COMBAT)
# ==============================================================================
func _resolve_army_intercept(army: Dictionary, intercept_prov: Dictionary) -> void:
	var source = army["source"]
	var target = army["target"]
	var moving_troops: int = army["troops"]
	var army_faction: String = army["faction"]
	var intercept_faction: String = intercept_prov.get("faction", intercept_prov.get("owner", "Địch"))
	var defender_troops: int = intercept_prov.get("troops", 0)
	
	print("--- QUÂN ĐỘI BỊ CHẶN ĐÁNH DỌC ĐƯỜNG ---")
	print("Hành quân từ %s -> %s bị phục kích tại %s!" % [source.get("name"), target.get("name"), intercept_prov.get("name")])
	print("Quân ta: %d lính (%s) vs Quân đồn trú chặn đường: %d lính (%s)" % [
		moving_troops, army_faction, defender_troops, intercept_faction
	])
	
	if moving_troops > defender_troops:
		var leftover_troops = moving_troops - defender_troops
		intercept_prov["troops"] = leftover_troops
		intercept_prov["faction"] = army_faction
		if intercept_prov.has("owner"):
			intercept_prov["owner"] = army_faction
		
		var new_faction_color = faction_colors.get(army_faction, Color.RED)
		repaint_province(intercept_prov, new_faction_color)
		update_gold_display()
		
		show_notification("⚔️ BỊ CHẶN ĐÁNH! Quân đội bị chặn đánh tại %s nhưng đã CHIẾN THẮNG và chiếm đóng luôn tỉnh này (đồn trú: %d quân)!" % [
			intercept_prov.get("name"), leftover_troops
		])
		print("Ket qua: Thang tran! Da chiem dong tinh chan duong %s voi %d quan con lai." % [
			intercept_prov.get("name"), leftover_troops
		])
	else:
		var leftover_defenders = defender_troops - moving_troops
		intercept_prov["troops"] = leftover_defenders
		
		show_notification("⚠️ BỊ CHẶN ĐÁNH THẤT BẠI! Quân đội bị chặn đánh tại %s và bị tiêu diệt hoàn toàn. Quân địch còn %d." % [
			intercept_prov.get("name"), leftover_defenders
		])
		print("Ket qua: That bai! Toan bo %d quan da tu tran tai %s. Dich con %d." % [
			moving_troops, intercept_prov.get("name"), leftover_defenders
		])
	
	update_troop_label(intercept_prov)
	if not selected_province.is_empty() and selected_province.get("id") == intercept_prov.get("id"):
		show_province_info(intercept_prov)

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
