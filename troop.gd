extends Node2D

signal movement_canceled(army_data: Dictionary)

var army_data: Dictionary = {}
var cancel_button: Button = null
var _is_canceling: bool = false

func setup_cancel_button(is_player_owned: bool = true) -> void:
	if not is_player_owned:
		return
	
	if cancel_button and is_instance_valid(cancel_button):
		return
	
	cancel_button = Button.new()
	cancel_button.name = "CancelButton"
	cancel_button.text = "✕ Hủy"
	cancel_button.tooltip_text = "Ngưng hành quân (Đóng quân tại tỉnh an toàn gần nhất)"
	cancel_button.focus_mode = Control.FOCUS_NONE
	
	# Kích thước nhỏ gọn, đặt lệch lên trên nhóm quân (y = -35)
	var btn_size = Vector2(28, 14)
	cancel_button.custom_minimum_size = btn_size
	cancel_button.size = btn_size
	cancel_button.pivot_offset = btn_size * 0.5
	cancel_button.position = Vector2(-btn_size.x * 0.5, -35.0)
	
	# Theme & Font
	cancel_button.add_theme_font_size_override("font_size", 9)
	cancel_button.add_theme_color_override("font_color", Color(1.0, 0.95, 0.95, 0.95))
	cancel_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	
	# Style: Nền đỏ thẫm nhỏ gọn, nổi bật
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.72, 0.12, 0.12, 0.92)
	style_normal.border_color = Color(1.0, 0.45, 0.45, 0.8)
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(3)
	style_normal.content_margin_top = 0
	style_normal.content_margin_bottom = 1
	style_normal.content_margin_left = 2
	style_normal.content_margin_right = 2
	cancel_button.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.92, 0.18, 0.18, 1.0)
	style_hover.border_color = Color(1.0, 0.85, 0.85, 1.0)
	style_hover.set_border_width_all(1)
	style_hover.set_corner_radius_all(3)
	style_hover.content_margin_top = 0
	style_hover.content_margin_bottom = 1
	style_hover.content_margin_left = 2
	style_hover.content_margin_right = 2
	cancel_button.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.45, 0.08, 0.08, 1.0)
	style_pressed.border_color = Color(1.0, 0.3, 0.3, 1.0)
	style_pressed.set_border_width_all(1)
	style_pressed.set_corner_radius_all(3)
	cancel_button.add_theme_stylebox_override("pressed", style_pressed)
	
	# Chặn và nhận trực tiếp sự kiện click
	cancel_button.mouse_filter = Control.MOUSE_FILTER_STOP
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	
	add_child(cancel_button)

func _on_cancel_button_pressed() -> void:
	get_viewport().set_input_as_handled()
	cancel_movement()

func _get_diplomacy_manager() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("DiplomacyManager")
	return null

func is_province_safe(prov: Dictionary, mover_faction: String) -> bool:
	if prov == null or prov.is_empty():
		return false
	var prov_fac = str(prov.get("faction", prov.get("owner", "")))
	if prov_fac == mover_faction:
		return true
	var dm = _get_diplomacy_manager()
	if dm:
		if dm.is_at_war(mover_faction, prov_fac):
			return false
		if dm.is_allied(mover_faction, prov_fac) or dm.has_military_access(mover_faction, prov_fac):
			return true
	return false

func get_nearest_safe_province() -> Dictionary:
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
	
	var a_safe = is_province_safe(prov_a, mover_faction)
	var b_safe = is_province_safe(prov_b, mover_faction)
	
	# Trường hợp 1: Nếu đã đi hơn nửa chặng (progress >= 0.5) và tỉnh B an toàn
	# (đất nhà / đồng minh / có quyền hành quân) -> cho quân đóng tại tỉnh B
	if progress >= 0.5 and b_safe:
		return prov_b
	
	# Nếu tỉnh A an toàn (tỉnh vừa bước qua hoặc chặng B là đất địch / chưa đi được bao nhiêu)
	# -> Quay đầu đóng quân tại tỉnh A
	if a_safe:
		return prov_a
	
	# Nếu chỉ tỉnh B an toàn
	if b_safe:
		return prov_b
	
	# Trường hợp ngoại lệ: Tìm lùi về các chặng an toàn trước đó trên lộ trình
	for k in range(curr_leg - 1, -1, -1):
		if is_province_safe(path[k], mover_faction):
			return path[k]
	
	return source if not source.is_empty() else prov_a

func cancel_movement() -> void:
	if _is_canceling:
		return
	_is_canceling = true

	if army_data and army_data is Dictionary:
		# 1. Xác định điểm dừng chân hợp lý (Tỉnh gần nhất / an toàn trên chặng hiện tại)
		var stop_prov = get_nearest_safe_province()
		army_data["stop_province"] = stop_prov
		army_data["cancel_pos"] = position

		# 2. Xóa sạch các chặng hành quân tiếp theo còn lại trong path queue
		army_data["path"] = []
		army_data["total_legs"] = 0
		army_data["current_leg"] = 0
		army_data["leg_progress"] = 1.0

		# 3. Phát tín hiệu hủy di chuyển (main.gd sẽ nhận signal để cộng quân vào tỉnh dừng chân, cập nhật UI)
		emit_signal("movement_canceled", army_data)

		# 4. Dọn dẹp visual đường đi (line)
		var line = army_data.get("line")
		if is_instance_valid(line):
			line.queue_free()

		# 5. Giải phóng node sprite quân
		queue_free()

func _on_cancel_movement_requested() -> void:
	cancel_movement()
