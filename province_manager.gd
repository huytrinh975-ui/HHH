extends Node

signal troops_disbanded(province_id: String, remaining_troops: int)
signal troops_recruited(province_id: String, new_troop_count: int, cost: int)

var _main_node: Node = null

func _ready() -> void:
	_get_main_node()

func _get_main_node() -> Node:
	if _main_node and is_instance_valid(_main_node):
		return _main_node
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		_main_node = tree.root.get_node_or_null("Main")
		if not _main_node:
			for child in tree.root.get_children():
				if child.name == "Main" or child.has_method("disband_troops") or child.has_method("update_troop_label"):
					_main_node = child
					break
	return _main_node

func disband_troops(province_id: String, amount: int) -> bool:
	var main_node = _get_main_node()
	if not main_node:
		push_error("ProvinceManager: Main node chưa sẵn sàng")
		return false

	if province_id.is_empty():
		push_error("ProvinceManager: province_id rỗng")
		return false

	if amount <= 0:
		push_error("ProvinceManager: Số lượng giải tán phải > 0")
		return false

	if main_node.has_method("disband_troops"):
		var success = main_node.disband_troops(province_id, amount)
		if success:
			var remaining = 0
			var p_dict = main_node.get("provinces_by_id")
			if p_dict and p_dict.has(province_id):
				remaining = int(p_dict[province_id].get("troops", 0))
			emit_signal("troops_disbanded", province_id, remaining)
		return success

	var provinces_by_id = main_node.get("provinces_by_id")
	if not provinces_by_id or not provinces_by_id.has(province_id):
		push_error("ProvinceManager: Không tìm thấy tỉnh ID '%s'" % province_id)
		return false

	var prov = provinces_by_id[province_id]
	var player_faction = main_node.get("player_faction")

	# Kiểm tra quyền sở hữu
	if prov.get("faction") != player_faction and prov.get("owner") != player_faction:
		push_error("ProvinceManager: Tỉnh '%s' không thuộc phe người chơi (%s)" % [province_id, player_faction])
		return false

	var current_troops = int(prov.get("troops", 0))
	if current_troops < amount:
		push_error("ProvinceManager: Tỉnh '%s' không đủ quân (có %d, cần %d)" % [province_id, current_troops, amount])
		return false

	# Thực hiện giải tán
	prov["troops"] = current_troops - amount

	# Hoàn trả 50% số quân vào dân số
	var returned_pop = int(amount * 0.5)
	prov["total_population"] = int(prov.get("total_population", 0)) + returned_pop

	# Cập nhật demographics: cộng vào nam giới độ tuổi lao động
	if not prov.has("demographics"):
		prov["demographics"] = {"male": {}, "female": {}}
	if not prov["demographics"].has("male"):
		prov["demographics"]["male"] = {"under_18": 0, "working_age": 0, "senior": 0}
	if not prov["demographics"].has("female"):
		prov["demographics"]["female"] = {"under_18": 0, "working_age": 0, "senior": 0}

	# Ước tính: trong số dân hoàn trả, ~50% là nam, ~70% độ tuổi lao động
	var male_returned = int(returned_pop * 0.5)
	var male_working_returned = int(male_returned * 0.7)
	prov["demographics"]["male"]["working_age"] = int(prov["demographics"]["male"].get("working_age", 0)) + male_working_returned

	# Cập nhật nhãn hiển thị trên bản đồ và ngân sách topbar
	main_node.call_deferred("update_troop_label", prov)
	if main_node.has_method("update_gold_display"):
		main_node.call_deferred("update_gold_display")

	# Cập nhật giao diện nếu đang chọn tỉnh này
	var selected_province = main_node.get("selected_province")
	if not selected_province.is_empty() and selected_province.get("id") == province_id:
		main_node.call_deferred("show_province_info", prov)

	# Phát signal
	emit_signal("troops_disbanded", province_id, prov["troops"])

	print("ProvinceManager: Đã giải tán %d quân tại %s (còn lại: %d, dân số +%d)" % [
		amount, prov.get("name", province_id), prov["troops"], returned_pop
	])

	return true

func recruit_troops(province_id: String, amount: int) -> bool:
	"""
	Tuyển quân tại một tỉnh (logic tập trung từ main.gd).
	Trả về true nếu thành công.
	"""
	if not _main_node:
		push_error("ProvinceManager: Main node chưa sẵn sàng")
		return false

	var provinces_by_id = _main_node.get("provinces_by_id")
	if not provinces_by_id or not provinces_by_id.has(province_id):
		push_error("ProvinceManager: Không tìm thấy tỉnh ID '%s'" % province_id)
		return false

	var prov = provinces_by_id[province_id]
	var player_faction = _main_node.get("player_faction")
	var player_gold = _main_node.get("player_gold")
	var COST_PER_TROOP = _main_node.get("COST_PER_TROOP")

	if prov.get("faction") != player_faction and prov.get("owner") != player_faction:
		push_error("ProvinceManager: Tỉnh '%s' không thuộc phe người chơi" % province_id)
		return false

	var cost = amount * COST_PER_TROOP
	if player_gold < cost:
		push_error("ProvinceManager: Không đủ vàng (cần %d, có %d)" % [cost, player_gold])
		return false

	# Kiểm tra hạn ngạch dân số (3% nam giới độ tuổi lao động)
	var male_working = int(prov.get("demographics", {}).get("male", {}).get("working_age", 0))
	var max_recruitable = int(male_working * 0.03)
	var recruited_this_month = int(prov.get("recruited_this_month", 0))
	if recruited_this_month + amount > max_recruitable:
		push_error("ProvinceManager: Vượt hạn ngạch tuyển quân tháng này")
		return false

	# Trừ tiền, trừ dân số, cộng quân
	_main_node.set("player_gold", player_gold - cost)
	prov["demographics"]["male"]["working_age"] = male_working - amount
	prov["total_population"] = int(prov.get("total_population", 0)) - amount
	prov["troops"] = int(prov.get("troops", 0)) + amount
	prov["recruited_this_month"] = recruited_this_month + amount

	var current_month = _main_node.get("current_month")
	var current_year = _main_node.get("current_year")
	prov["last_recruited_month"] = current_month
	prov["last_recruited_year"] = current_year

	_main_node.call_deferred("update_gold_display")
	_main_node.call_deferred("update_troop_label", prov)

	var selected_province = _main_node.get("selected_province")
	if not selected_province.is_empty() and selected_province.get("id") == province_id:
		_main_node.call_deferred("show_province_info", prov)

	emit_signal("troops_recruited", province_id, prov["troops"], cost)
	print("ProvinceManager: Đã tuyển %d quân tại %s (chi phí: %d vàng)" % [amount, prov.get("name", province_id), cost])

	return true

func get_province(province_id: String) -> Dictionary:
	"""Lấy dữ liệu tỉnh theo ID."""
	if not _main_node:
		return {}
	var provinces_by_id = _main_node.get("provinces_by_id")
	if provinces_by_id and provinces_by_id.has(province_id):
		return provinces_by_id[province_id]
	return {}

func set_province_troops(province_id: String, troops: int) -> bool:
	"""Thiết lập trực tiếp số quân tại tỉnh (dùng cho cheat/debug/scenario)."""
	if not _main_node:
		return false
	var provinces_by_id = _main_node.get("provinces_by_id")
	if provinces_by_id and provinces_by_id.has(province_id):
		var prov = provinces_by_id[province_id]
		prov["troops"] = max(0, troops)
		_main_node.call_deferred("update_troop_label", prov)
		return true
	return false

func add_province_troops(province_id: String, amount: int) -> bool:
	"""Cộng/trừ số quân tại tỉnh (dùng cho arrive/combat)."""
	if not _main_node:
		return false
	var provinces_by_id = _main_node.get("provinces_by_id")
	if provinces_by_id and provinces_by_id.has(province_id):
		var prov = provinces_by_id[province_id]
		prov["troops"] = max(0, int(prov.get("troops", 0)) + amount)
		_main_node.call_deferred("update_troop_label", prov)
		return true
	return false

# ==============================================================================
# HỆ THỐNG CÔNG TRÌNH, LAO ĐỘC, THẤT NGHIỆP
# ==============================================================================

func can_build(province_id: String, faction_id: String, building_type: String) -> bool:
	"""Kiểm tra xem có thể xây công trình tại tỉnh hay không."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return false

	if _main_node.has_method("can_build"):
		return _main_node.can_build(province_id, faction_id, building_type)

	return false

func build_structure(province_id: String, faction_id: String, building_type: String) -> bool:
	"""Xây dựng công trình mới tại tỉnh."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return false

	return _main_node.build_structure(province_id, faction_id, building_type)

func damage_buildings_on_combat(province_id: String) -> void:
	"""Khi tỉnh xảy ra đánh trận/đổi chủ, các công trình có xác suất bị hư."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return

	_main_node.damage_buildings_on_combat(province_id)

func repair_building(province_id: String, building_index: int, payer_faction_id: String) -> bool:
	"""Sửa chữa công trình bị hư."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return false

	return _main_node.repair_building(province_id, building_index, payer_faction_id)

func calculate_monthly_economy(province_id: String) -> Dictionary:
	"""Tính toán kinh tế hàng tháng của tỉnh."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return {}

	return _main_node.calculate_monthly_economy(province_id)

func get_building_list(province_id: String) -> Array:
	"""Lấy danh sách công trình của tỉnh."""
	if not _main_node:
		_get_main_node()
	if not _main_node:
		return []

	var prov = get_province(province_id)
	return prov.get("buildings", [])

func get_building_jobs_building_type(building_type: String) -> int:
	"""Lấy số việc làm cung cấp bởi từng loại công trình."""
	return _main_node.BUILDING_DATA[building_type]["jobs"] if _main_node.BUILDING_DATA.has(building_type) else 0

func get_building_cost(building_type: String) -> int:
	"""Lấy chi phí xây dựng công trình."""
	return _main_node.BUILDING_DATA[building_type]["cost"] if _main_node.BUILDING_DATA.has(building_type) else 0