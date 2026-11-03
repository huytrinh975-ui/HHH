extends Camera2D

@export_group("Zoom Settings")
@export var min_zoom: Vector2 = Vector2(0.2, 0.2)
@export var max_zoom: Vector2 = Vector2(4.0, 4.0)
@export var zoom_factor: float = 1.2
@export var zoom_speed: float = 12.0 # Tốc độ nội suy mượt cho cuộn chuột PC

@export_group("Pan Settings")
@export var keyboard_pan_speed: float = 700.0
@export var touch_drag_threshold: float = 10.0 # Ngưỡng di chuyển tối thiểu để nhận diện vuốt 1 ngón (pixel)

var target_zoom: Vector2 = Vector2.ONE
var is_dragging: bool = false # Cho PC chuột phải/chuột giữa
var zoom_anchor_mouse_pos: Vector2 = Vector2.ZERO

# Quản lý cảm ứng đa điểm cho Mobile / Web Mobile
var touch_points: Dictionary = {}
var touch_start_positions: Dictionary = {}
var is_touch_dragging: bool = false
var just_finished_touch_drag: bool = false

# Dành riêng cho Pinch-to-zoom 2 ngón tay (Cố định World Anchor, không cộng dồn relative, không dùng lerp)
var pinch_start_distance: float = 0.0
var pinch_start_zoom: Vector2 = Vector2.ONE
var pinch_world_anchor: Vector2 = Vector2.ZERO

func _ready() -> void:
	target_zoom = zoom

func _process(delta: float) -> void:
	just_finished_touch_drag = false
	_handle_keyboard_pan(delta)
	
	# CHỈ chạy nội suy mượt khi dùng chuột trên PC (khi không có ngón tay nào chạm)
	if touch_points.is_empty():
		_handle_smooth_zoom(delta)
	else:
		target_zoom = zoom

func _handle_keyboard_pan(delta: float) -> void:
	var move_vec = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_vec.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_vec.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_vec.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_vec.y += 1
	
	if move_vec != Vector2.ZERO:
		position += move_vec.normalized() * (keyboard_pan_speed / zoom.x) * delta

func _handle_smooth_zoom(delta: float) -> void:
	if zoom.distance_squared_to(target_zoom) > 0.00001:
		var prev_zoom = zoom
		var t = 1.0 - exp(-zoom_speed * delta)
		zoom = zoom.lerp(target_zoom, t)
		
		var viewport_size = get_viewport_rect().size
		var mouse_offset = zoom_anchor_mouse_pos - (viewport_size * 0.5)
		position += mouse_offset * (1.0 / prev_zoom.x - 1.0 / zoom.x)
	else:
		zoom = target_zoom

func _unhandled_input(event: InputEvent) -> void:
	# ----------------------------------------------------
	# 1. XỬ LÝ CẢM ỨNG DI ĐỘNG (TOUCH, PAN & PINCH-TO-ZOOM)
	# ----------------------------------------------------
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			touch_start_positions[event.index] = event.position
			
			if touch_points.size() == 1:
				is_touch_dragging = false
				target_zoom = zoom
			elif touch_points.size() == 2:
				is_touch_dragging = true
				var points = touch_points.values()
				var center = (points[0] + points[1]) * 0.5
				var viewport_center = get_viewport_rect().size * 0.5
				
				# Khởi tạo điểm mỏ neo tọa độ thế giới (world anchor) cố định nằm ngay dưới trung điểm 2 ngón tay
				pinch_start_distance = max(points[0].distance_to(points[1]), 1.0)
				pinch_start_zoom = zoom
				target_zoom = zoom
				pinch_world_anchor = position + (center - viewport_center) / zoom.x
				
				get_viewport().set_input_as_handled()
			elif touch_points.size() > 2:
				is_touch_dragging = true
				get_viewport().set_input_as_handled()
		else:
			# Khi nhấc ngón tay lên
			if is_touch_dragging:
				just_finished_touch_drag = true
				get_viewport().set_input_as_handled()
			
			touch_points.erase(event.index)
			touch_start_positions.erase(event.index)
			
			if touch_points.size() == 1:
				# Vừa chuyển từ 2 ngón về 1 ngón: cập nhật lại vị trí bắt đầu cho ngón còn lại
				var remaining_idx = touch_points.keys()[0]
				touch_start_positions[remaining_idx] = touch_points[remaining_idx]
				pinch_start_distance = 0.0
				is_touch_dragging = true # Giữ cờ drag để không nhận nhầm thành click khi nhấc ngón này lên
				target_zoom = zoom
			elif touch_points.is_empty():
				is_touch_dragging = false
				pinch_start_distance = 0.0
				target_zoom = zoom

	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
		
		# A. VUỐT 1 NGÓN TAY (TOUCH PAN)
		if touch_points.size() == 1:
			var start_pos: Vector2 = touch_start_positions.get(event.index, event.position)
			var total_dist: float = start_pos.distance_to(event.position)
			
			if not is_touch_dragging:
				if total_dist >= touch_drag_threshold:
					is_touch_dragging = true
			
			if is_touch_dragging:
				position -= event.relative / zoom.x
				get_viewport().set_input_as_handled()
		
		# B. PINCH-TO-ZOOM 2 NGÓN TAY (KHÓA CỨNG WORLD ANCHOR, KHÔNG CỘNG DỒN RELATIVE, KHÔNG LERP)
		elif touch_points.size() == 2:
			is_touch_dragging = true
			var points = touch_points.values()
			var current_dist: float = points[0].distance_to(points[1])
			var current_center: Vector2 = (points[0] + points[1]) * 0.5
			
			if pinch_start_distance > 1.0 and current_dist > 1.0:
				var ratio: float = current_dist / pinch_start_distance
				zoom = (pinch_start_zoom * ratio).clamp(min_zoom, max_zoom)
				target_zoom = zoom
				
				var viewport_center = get_viewport_rect().size * 0.5
				var center_offset = current_center - viewport_center
				position = pinch_world_anchor - (center_offset / zoom.x)
			
			get_viewport().set_input_as_handled()
		
		elif touch_points.size() > 2:
			is_touch_dragging = true
			get_viewport().set_input_as_handled()

	# ----------------------------------------------------
	# 2. XỬ LÝ CHUỘT TRÊN PC (GIỮ NGUYÊN 100%)
	# ----------------------------------------------------
	elif event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			is_dragging = event.pressed
			if is_dragging:
				get_viewport().set_input_as_handled()
		elif event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_start_zoom(zoom_factor, event.position)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_start_zoom(1.0 / zoom_factor, event.position)
				get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom.x
		get_viewport().set_input_as_handled()

func _start_zoom(factor: float, mouse_screen_pos: Vector2) -> void:
	zoom_anchor_mouse_pos = mouse_screen_pos
	target_zoom = (target_zoom * factor).clamp(min_zoom, max_zoom)
