extends Node

signal scenario_applied(scenario_id: String)

const SCENARIO_DIR = "res://data/scenarios/"

var active_scenario: Dictionary = {}
var active_scenario_path: String = ""

func _ready() -> void:
	pass

func load_scenario(path: String) -> Dictionary:
	"""
	Đọc và parse file JSON kịch bản an toàn.
	Trả về Dictionary chứa dữ liệu kịch bản hoặc Dictionary rỗng nếu lỗi.
	"""
	if not FileAccess.file_exists(path):
		push_error("ScenarioManager: File không tồn tại: %s" % path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ScenarioManager: Không thể mở file: %s" % path)
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		push_error("ScenarioManager: Lỗi parse JSON tại %s: %s" % [path, json.get_error_message()])
		return {}

	var data = json.data
	if not data or not (data is Dictionary):
		push_error("ScenarioManager: Dữ liệu kịch bản không hợp lệ (không phải Dictionary)")
		return {}

	# Kiểm tra các trường bắt buộc
	if not data.has("id") or not data.has("provinces"):
		push_error("ScenarioManager: Thiếu trường bắt buộc 'id' hoặc 'provinces'")
		return {}

	active_scenario_path = path
	active_scenario = data
	print("ScenarioManager: Đã load kịch bản '%s' thành công từ %s" % [data.get("id"), path])
	return data

func apply_scenario(scenario_data: Dictionary, target_scene: Node = null) -> bool:
	"""
	Áp dụng kịch bản vào bản đồ game:
	- Cập nhật owner, troops, population, demographics cho 63 tỉnh
	- Tính toán lại các chỉ số phái sinh
	- Đổi màu sắc hiển thị tỉnh theo phe phái
	- Cập nhật nhãn quân số trên bản đồ
	- Khởi tạo DiplomacyManager với các phe phái mới
	- Phát signal scenario_applied khi hoàn tất
	"""
	if scenario_data.is_empty():
		push_error("ScenarioManager: Dữ liệu kịch bản rỗng, không thể áp dụng")
		return false

	active_scenario = scenario_data
	var scenario_id = scenario_data.get("id", "unknown")
	var provinces_config = scenario_data.get("provinces", [])
	var factions = scenario_data.get("factions", {})

	if provinces_config.is_empty():
		push_error("ScenarioManager: Kịch bản '%s' không có dữ liệu tỉnh" % scenario_id)
		return false

	# Xây dựng mapping màu phe phái từ kịch bản
	var scenario_faction_colors: Dictionary = {}
	for fac_key in factions:
		var fac_data = factions[fac_key]
		if fac_data.has("color"):
			scenario_faction_colors[fac_key] = Color(fac_data["color"])

	if target_scene == null:
		target_scene = _get_active_game_scene()

	# Đồng bộ và áp dụng phe người chơi đã chọn (selected_player_faction)
	var gm = _get_game_manager()
	var effective_player_faction: String = ""
	if gm and gm.selected_player_faction != "":
		effective_player_faction = gm.selected_player_faction
	elif target_scene != null and "player_faction" in target_scene and target_scene.player_faction != "" and factions.has(target_scene.player_faction):
		effective_player_faction = target_scene.player_faction
	else:
		effective_player_faction = "LE_TRINH"

	if gm:
		gm.selected_player_faction = effective_player_faction
		gm.player_faction = effective_player_faction
	if target_scene != null and "player_faction" in target_scene:
		target_scene.player_faction = effective_player_faction

	var provs_dict: Dictionary = {}
	if target_scene != null and "provinces_by_id" in target_scene:
		provs_dict = target_scene.provinces_by_id

	var updated_factions: Array = []
	
	if not provs_dict.is_empty():
		for prov_config in provinces_config:
			var prov_id = str(prov_config.get("id", ""))
			if prov_id.is_empty():
				continue

			var prov = provs_dict.get(prov_id)
			if prov == null:
				continue

			var faction_key = prov_config.get("faction", "")
			if faction_key.is_empty():
				continue

			# Cập nhật phe phái
			prov["faction"] = faction_key
			prov["owner"] = prov_config.get("owner", faction_key)

			# Cập nhật số quân
			prov["troops"] = int(prov_config.get("troops", 0))

			# Cập nhật dân số và nhân khẩu học
			if prov_config.has("total_population"):
				prov["total_population"] = int(prov_config["total_population"])
			if prov_config.has("demographics"):
				prov["demographics"] = prov_config["demographics"]

			# Tính lại các chỉ số phái sinh
			_recalculate_derived_stats(prov)

			# Cập nhật màu hiển thị
			var fac_color = scenario_faction_colors.get(faction_key)
			if fac_color and target_scene.has_method("repaint_province"):
				prov["current_color"] = "#" + fac_color.to_html(false).to_lower()
				target_scene.repaint_province(prov, fac_color)

			# Cập nhật nhãn hiển thị lính
			if target_scene.has_method("update_troop_label"):
				target_scene.update_troop_label(prov)

			if not updated_factions.has(faction_key):
				updated_factions.append(faction_key)

		# Cập nhật faction_colors toàn cục trên target_scene
		if "faction_colors" in target_scene:
			for fac_key in updated_factions:
				var fac_color = scenario_faction_colors.get(fac_key)
				if fac_color:
					target_scene.faction_colors[fac_key] = fac_color

		# Cập nhật giao diện nếu có tỉnh đang được chọn
		if "selected_province" in target_scene and not target_scene.selected_province.is_empty():
			if target_scene.has_method("show_province_info"):
				target_scene.show_province_info(target_scene.selected_province)

		if target_scene.has_method("calculate_monthly_income"):
			target_scene.calculate_monthly_income()
		if target_scene.has_method("update_gold_display"):
			target_scene.update_gold_display()

	# Khởi tạo lại DiplomacyManager với phe phái mới
	var dm = _get_diplomacy_manager()
	if dm:
		var fac_list = []
		if not updated_factions.is_empty():
			fac_list = updated_factions.duplicate()
		else:
			for fac_key in factions:
				fac_list.append(fac_key)
		dm.init_factions(fac_list)
		
		# Cài đặt quan hệ lịch sử đặc biệt cho 1611
		if scenario_id == "dai_viet_1611":
			if dm.has_method("declare_war"):
				dm.declare_war("LE_TRINH", "MAC")
			if dm.has_method("set_relation"):
				dm.set_relation("LE_TRINH", "NGUYEN", -30)
				dm.set_relation("LE_TRINH", "CHUA_BAU", -15)
				dm.set_relation("NGUYEN", "CHAMPA", -20)

	emit_signal("scenario_applied", scenario_id)
	print("ScenarioManager: Đã áp dụng kịch bản '%s' thành công!" % scenario_id)
	return true

func clear_active_scenario() -> void:
	active_scenario = {}
	active_scenario_path = ""

func _recalculate_derived_stats(prov: Dictionary) -> void:
	"""
	Tính toán lại các chỉ số phái sinh dựa trên dân số mới:
	- Đảm bảo cấu trúc demographics chuẩn
	- Reset hạn mức tuyển quân tháng hiện tại
	"""
	if not prov.has("demographics") or not (prov["demographics"] is Dictionary):
		var total = prov.get("total_population", 0)
		var male_working = int(total * 0.35)
		prov["demographics"] = {
			"male": {
				"under_18": int(total * 0.15),
				"working_age": male_working,
				"senior": int(total * 0.05)
			},
			"female": {
				"under_18": int(total * 0.15),
				"working_age": int(total * 0.35),
				"senior": int(total * 0.05)
			}
		}

	# Reset chỉ số tuyển quân tháng
	prov["recruited_this_month"] = 0
	prov["last_recruited_month"] = -1
	prov["last_recruited_year"] = -1

func get_scenario_list() -> Array:
	"""
	Lấy danh sách các file kịch bản có sẵn trong thư mục data/scenarios/
	"""
	var dir = DirAccess.open(SCENARIO_DIR)
	if dir == null:
		return []

	var files: Array = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path = SCENARIO_DIR + file_name
			var scenario = load_scenario(full_path)
			if not scenario.is_empty():
				files.append({
					"id": scenario.get("id", ""),
					"name": scenario.get("name", file_name),
					"year": scenario.get("year", 0),
					"path": full_path,
					"description": scenario.get("description", "")
				})
		file_name = dir.get_next()
	dir.list_dir_end()

	return files

func load_and_apply_scenario(scenario_id: String, target_scene: Node = null) -> bool:
	"""
	Tiện ích: Tìm và áp dụng kịch bản theo ID.
	"""
	if scenario_id == "dai_viet_1611":
		var data = load_scenario("res://data/scenarios/scenario_1611.json")
		return apply_scenario(data, target_scene)

	var scenarios = get_scenario_list()
	for s in scenarios:
		if s["id"] == scenario_id:
			var data = load_scenario(s["path"])
			return apply_scenario(data, target_scene)

	push_error("ScenarioManager: Không tìm thấy kịch bản ID '%s'" % scenario_id)
	return false

func _get_game_manager() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("GameManager")
	return null

func _get_diplomacy_manager() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		return tree.root.get_node_or_null("DiplomacyManager")
	return null

func _get_active_game_scene() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	var cur = tree.current_scene
	if cur and (cur.has_method("repaint_province") or "provinces_by_id" in cur):
		return cur
	if tree.root:
		for child in tree.root.get_children():
			if child and (child.has_method("repaint_province") or "provinces_by_id" in child):
				return child
	return null
