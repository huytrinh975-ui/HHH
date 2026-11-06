extends Node2D

signal movement_canceled(army_data: Dictionary)

var army_data: Dictionary = {}
var cancel_button: Button = null

var _press_pos: Vector2 = Vector2.ZERO
var _drag_started: bool = false

func setup_cancel_button(is_player_owned: bool = true) -> void:
	if not is_player_owned:
		return
	
	if cancel_button and is_instance_valid(cancel_button):
		return
	
	cancel_button = Button.new()
	cancel_button.name = "CancelButton"
	cancel_button.text = "✕ Hủy"
	cancel_button.tooltip_text = "Ngưng hành quân (Hoàn trả quân về tỉnh xuất phát)"
	cancel_button.focus_mode = Control.FOCUS_NONE
	
	# Kích thước nhỏ gọn, đặt ngay phía trên nhãn quân số [-15, -23]
	var btn_size = Vector2(30, 14)
	cancel_button.custom_minimum_size = btn_size
	cancel_button.size = btn_size
	cancel_button.pivot_offset = btn_size * 0.5
	cancel_button.position = Vector2(-btn_size.x * 0.5, -23.0)
	
	# Theme & Font
	cancel_button.add_theme_font_size_override("font_size", 9)
	cancel_button.add_theme_color_override("font_color", Color(1.0, 0.95, 0.95, 0.95))
	cancel_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	
	# Style: Nền đỏ thẫm nổi bật, viền nhẹ
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.72, 0.12, 0.12, 0.9)
	style_normal.border_color = Color(1.0, 0.5, 0.5, 0.8)
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
	
	# Sử dụng MOUSE_FILTER_PASS để không chặn cử chỉ pan/zoom của Camera2D
	cancel_button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	cancel_button.gui_input.connect(_on_cancel_button_gui_input)
	add_child(cancel_button)

func _on_cancel_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pos = event.global_position
			_drag_started = false
		else:
			if not _drag_started and _press_pos != Vector2.ZERO and _press_pos.distance_to(event.global_position) < 12.0:
				var cam = get_viewport().get_camera_2d()
				if cam and (cam.get("is_touch_dragging") or cam.get("just_finished_touch_drag") or cam.get("is_pinch_zooming") or cam.get("is_dragging")):
					_press_pos = Vector2.ZERO
					_drag_started = false
					return
				get_viewport().set_input_as_handled()
				cancel_movement()
			_press_pos = Vector2.ZERO
			_drag_started = false

	elif event is InputEventScreenTouch:
		if event.pressed:
			_press_pos = event.position
			_drag_started = false
		else:
			if not _drag_started and _press_pos != Vector2.ZERO and _press_pos.distance_to(event.position) < 15.0:
				var cam = get_viewport().get_camera_2d()
				if cam and (cam.get("is_touch_dragging") or cam.get("just_finished_touch_drag") or cam.get("is_pinch_zooming") or cam.get("is_dragging")):
					_press_pos = Vector2.ZERO
					_drag_started = false
					return
				get_viewport().set_input_as_handled()
				cancel_movement()
			_press_pos = Vector2.ZERO
			_drag_started = false

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		var curr_pos = event.position if event is InputEventScreenDrag else event.global_position
		if _press_pos != Vector2.ZERO and _press_pos.distance_to(curr_pos) >= 12.0:
			_drag_started = true

func cancel_movement() -> void:
	if army_data and army_data is Dictionary:
		# 1. Dừng logic di chuyển: Xóa path queue để update_active_armies không tiếp tục di chuyển
		army_data["path"] = []
		army_data["total_legs"] = 0
		army_data["current_leg"] = 0
		army_data["leg_progress"] = 1.0

		# 2. Phát tín hiệu hủy di chuyển (main.gd sẽ nhận signal để hoàn trả quân, tạo floating text, cập nhật UI)
		emit_signal("movement_canceled", army_data)

		# 3. Dọn dẹp visual (line)
		var line = army_data.get("line")
		if is_instance_valid(line):
			line.queue_free()

		# 4. Giải phóng node troop
		queue_free()

func _on_cancel_movement_requested() -> void:
	cancel_movement()
