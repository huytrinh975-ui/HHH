extends Node2D

@onready var map_sprite: Sprite2D = $Test
@onready var province_panel: Panel = $UI/ProvincePanel
@onready var name_label: Label = $UI/ProvincePanel/VBoxContainer/NameLabel
@onready var nation_label: Label = $UI/ProvincePanel/VBoxContainer/NationLabel
@onready var faction_label: Label = $UI/ProvincePanel/VBoxContainer/FactionLabel
@onready var troops_label: Label = $UI/ProvincePanel/VBoxContainer/TroopsLabel
@onready var population_label: Label = $UI/ProvincePanel/VBoxContainer/PopulationLabel
@onready var demographics_label: Label = $UI/ProvincePanel/VBoxContainer/DemographicsLabel
@onready var manpower_label: Label = $UI/ProvincePanel/VBoxContainer/ManpowerLabel
@onready var start_button: Button = $UI/ProvincePanel/VBoxContainer/StartButton
@onready var mode_label: Label = $UI/HeaderPanel/MarginContainer/VBoxContainer/ModeLabel
@onready var back_button: Button = $UI/BackButton

var provinces_data: Array = []
var provinces_by_id_num: Dictionary = {}
var map_image: Image
var base_display_image: Image
var id_map_image: Image
var province_pixel_cache: Dictionary = {}
var selected_province: Dictionary = {}

var province_labels: Dictionary = {}
var province_markers: Dictionary = {}
var markers_container: Node2D = null

# Phân biệt chạm nhẹ (click chọn tỉnh) với vuốt bản đồ (pan camera)
var mouse_press_pos: Vector2 = Vector2.ZERO
var is_left_mouse_down: bool = false

func _ready() -> void:
	load_provinces_json()
	
	if back_button:
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://MainMenu.tscn"))
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	
	if mode_label:
		if GameManager.current_mode == GameManager.MODE_63_WARLORDS:
			mode_label.text = "Chế độ: LOẠN 63 XỨ QUÂN (Mỗi tỉnh là 1 phe độc lập • 30 lính)"
		else:
			mode_label.text = "Chế độ: TỨ QUỐC TRANH HÙNG (4 Đại Cường Quốc)"
	
	if map_sprite and map_sprite.texture:
		map_image = map_sprite.texture.get_image()
		base_display_image = map_image.duplicate()
		
		# Đọc ảnh ID qua Resource Loader (Chạy chuẩn 100% trên Web, PC, Mobile)
		var id_tex = load("res://VN_id_map.png") as Texture2D
		if id_tex:
			id_map_image = id_tex.get_image()
		else:
			id_map_image = map_image.duplicate()
			
		map_sprite.texture = ImageTexture.create_from_image(map_image)
		
		if map_sprite.material is ShaderMaterial and id_tex:
			map_sprite.material.set_shader_parameter("id_map_texture", id_tex)
		
		cache_province_pixels()
	
	# Khởi tạo bản đồ và quân số theo kịch bản đã chọn
	init_game_mode_data()
	
	spawn_troop_markers()
	hide_province_panel()
	set_province_selection_shader(Color(0, 0, 0, 0), false)

func load_provinces_json() -> void:
	var file_path = "res://provinces.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			provinces_data = json.data
			provinces_by_id_num.clear()
			for prov in provinces_data:
				var id_hex = prov.get("id_color", prov.get("color", "")).to_lower()
				prov["original_color"] = id_hex
				prov["current_color"] = id_hex
				var id_color = Color.from_string(id_hex, Color.BLACK)
				var id_num = int(round(id_color.b * 255.0))
				provinces_by_id_num[id_num] = prov

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

func init_game_mode_data() -> void:
	if GameManager.current_mode == GameManager.MODE_63_WARLORDS:
		# Loạn 63 Xứ Quân: Mỗi tỉnh là 1 phe độc lập, màu riêng, 30 quân
		for prov in provinces_data:
			prov["faction"] = prov.get("name", "Vô danh")
			prov["troops"] = 30
			var hex = prov.get("id_color", prov.get("original_color", prov.get("color", "")))
			var col = GameManager.get_warlord_color_by_hex(hex)
			prov["current_color"] = "#" + col.to_html(false).to_lower()
			
			var orig_color = Color.from_string(hex, Color.BLACK)
			var target_b = int(round(orig_color.b * 255.0))
			if province_pixel_cache.has(target_b):
				for pt in province_pixel_cache[target_b]:
					var base_c = base_display_image.get_pixel(pt.x, pt.y)
					if max(base_c.r, max(base_c.g, base_c.b)) < 0.255:
						continue
					map_image.set_pixel(pt.x, pt.y, col)
		
		if map_sprite.texture is ImageTexture:
			map_sprite.texture.update(map_image)
		else:
			map_sprite.texture = ImageTexture.create_from_image(map_image)
	else:
		# Tứ Quốc Tranh Hùng: 4 phe lớn như provinces.json
		pass

func repaint_province(prov: Dictionary, new_color: Color) -> void:
	if not map_image or not id_map_image or not base_display_image:
		return
	var orig_color = Color.from_string(prov.get("original_color", prov["color"]), Color.BLACK)
	var target_b = int(round(orig_color.b * 255.0))
	if province_pixel_cache.has(target_b):
		for pt in province_pixel_cache[target_b]:
			var base_c = base_display_image.get_pixel(pt.x, pt.y)
			if max(base_c.r, max(base_c.g, base_c.b)) < 0.255:
				continue
			map_image.set_pixel(pt.x, pt.y, new_color)
	if map_sprite.texture is ImageTexture:
		map_sprite.texture.update(map_image)
	else:
		map_sprite.texture = ImageTexture.create_from_image(map_image)

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
		var local_pos = center_pos - tex_size / 2.0 if map_sprite.centered else center_pos
		var marker_root = Node2D.new()
		marker_root.name = "Marker_" + str(prov.get("id"))
		marker_root.position = local_pos
		marker_root.scale = Vector2(0.5, 0.5)
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
		label.text = str(troops)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color.WHITE)
		badge.add_child(label)
		
		var badge_size = Vector2(24, 14)
		badge.custom_minimum_size = badge_size
		badge.size = badge_size
		badge.pivot_offset = badge_size / 2.0
		badge.position = -badge_size / 2.0
		marker_root.add_child(badge)
		marker_root.visible = (troops > 0)
		province_markers[prov.get("id")] = marker_root

func get_province_center(prov: Dictionary) -> Vector2:
	if prov.has("center") and prov["center"] is Array and prov["center"].size() == 2:
		return Vector2(prov["center"][0], prov["center"][1])
	return Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_press_pos = event.position
			is_left_mouse_down = true
		else:
			if is_left_mouse_down:
				is_left_mouse_down = false
				
				var camera_is_panning = false
				var cam = get_node_or_null("Camera2D")
				if cam and (cam.is_touch_dragging or cam.just_finished_touch_drag or cam.is_dragging):
					camera_is_panning = true
				
				if not camera_is_panning and mouse_press_pos.distance_to(event.position) < 15.0:
					var click_pos = get_global_mouse_position()
					var local_pos = map_sprite.to_local(click_pos)
					var clicked_prov = get_province_at_local_pos(local_pos)
					if clicked_prov.is_empty():
						hide_province_panel()
					else:
						show_province_info(clicked_prov)

func get_province_at_local_pos(local_pos: Vector2) -> Dictionary:
	if not id_map_image:
		return {}
	var tex_size = id_map_image.get_size()
	var pixel_pos = local_pos + (tex_size / 2.0 if map_sprite.centered else Vector2.ZERO)
	var px = int(round(pixel_pos.x))
	var py = int(round(pixel_pos.y))
	if px >= 0 and px < tex_size.x and py >= 0 and py < tex_size.y:
		var color: Color = id_map_image.get_pixel(px, py)
		if color.a > 0.1 and color.b > 0.0:
			var target_b = int(round(color.b * 255.0))
			if provinces_by_id_num.has(target_b):
				return provinces_by_id_num[target_b]
	for dy in [-3, 0, 3]:
		for dx in [-3, 0, 3]:
			var nx = px + dx
			var ny = py + dy
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

func show_province_info(prov: Dictionary) -> void:
	selected_province = prov
	if province_panel:
		name_label.text = "🏛️ " + str(prov.get("name", "Không rõ"))
		nation_label.text = "Quốc gia: " + str(prov.get("nation", "Việt Nam"))
		faction_label.text = "Phe: " + str(prov.get("faction", "Vô chủ"))
		
		var tot_pop = int(prov.get("total_population", 0))
		var m_work = 0
		var m_pop = 0
		var f_pop = 0
		if prov.has("demographics"):
			var d = prov["demographics"]
			if d.has("male"):
				var m = d["male"]
				m_work = int(m.get("working_age", 0))
				m_pop = int(m.get("under_18", 0)) + m_work + int(m.get("senior", 0))
			if d.has("female"):
				var f = d["female"]
				f_pop = int(f.get("under_18", 0)) + int(f.get("working_age", 0)) + int(f.get("senior", 0))
		
		if population_label:
			population_label.text = "👥 Dân số: %s người" % format_number(tot_pop)
		if demographics_label:
			demographics_label.text = "  • Nam: %s | Nữ: %s" % [format_number(m_pop), format_number(f_pop)]
		if manpower_label:
			manpower_label.text = "  • Nam nhập ngũ: %s" % format_number(m_work)
		
		troops_label.text = "⚔️ Quân khởi đầu: " + format_number(int(prov.get("troops", 0)))
		start_button.text = "⚔️ VÀO TRẬN (LÃNH ĐẠO " + str(prov.get("faction")) + ")"
		province_panel.visible = true
	var id_hex = prov.get("id_color", prov.get("original_color", prov.get("color", "")))
	set_province_selection_shader(Color.from_string(id_hex, Color.BLACK), true)

func hide_province_panel() -> void:
	selected_province = {}
	if province_panel:
		province_panel.visible = false
	set_province_selection_shader(Color(0, 0, 0, 0), false)

func set_province_selection_shader(color: Color, selected: bool) -> void:
	if map_sprite and map_sprite.material is ShaderMaterial:
		map_sprite.material.set_shader_parameter("target_color", color)
		map_sprite.material.set_shader_parameter("is_selected", selected)

func _on_start_button_pressed() -> void:
	if selected_province.is_empty():
		return
	GameManager.player_faction = selected_province.get("faction", "")
	GameManager.player_province_id = selected_province.get("id", "")
	print("Xac nhan chon phe: ", GameManager.player_faction, " - Che do: ", GameManager.current_mode)
	get_tree().change_scene_to_file("res://main.tscn")
