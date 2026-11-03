extends Node

# ==============================================================================
# QUẢN LÝ DỮ LIỆU NGOẠI GIAO (DIPLOMACY MANAGER)
# ==============================================================================

# Ma trận quan hệ ngoại giao giữa các phe:
# Key: pair_key "facA<#>facB"
# Value: {
#   "relations": int (-100 đến +100, mặc định 0: Trung lập),
#   "is_at_war": bool,
#   "is_allied": bool,
#   "access": { facA: bool, facB: bool },
#   "improving": { facA: bool, facB: bool },
#   "insult_cooldown": { facA: int, facB: int }
# }
var diplomacy_matrix: Dictionary = {}
var all_factions: Array = []

const DIPLOMAT_COST: int = 5           # Chi phí duy trì nhà ngoại giao: 5 Vàng/tháng
const DIPLOMAT_RELATION_BOOST: int = 3 # Tăng +3 quan hệ/tháng khi cử ngoại giao
const INSULT_PENALTY: int = -30        # Xúc phạm ngoại giao trừ 30 điểm quan hệ
const INSULT_COOLDOWN_MONTHS: int = 3  # Cooldown 3 tháng chống spam xúc phạm
const MIN_RELATION_ACCESS: int = 20    # Yêu cầu quan hệ >= +20 để xin quyền hành quân
const MIN_RELATION_ALLIANCE: int = 75  # Yêu cầu quan hệ >= +75 để liên minh quân sự

func _ready() -> void:
	pass

func get_pair_key(facA: String, facB: String) -> String:
	if facA < facB:
		return facA + "<#>" + facB
	return facB + "<#>" + facA

func init_factions(factions_list: Array) -> void:
	for f in factions_list:
		var fac_str = str(f).strip_edges()
		if fac_str != "" and not all_factions.has(fac_str):
			all_factions.append(fac_str)
	
	for i in range(all_factions.size()):
		for j in range(i + 1, all_factions.size()):
			var f1 = all_factions[i]
			var f2 = all_factions[j]
			var key = get_pair_key(f1, f2)
			if not diplomacy_matrix.has(key):
				diplomacy_matrix[key] = {
					"relations": 0,
					"is_at_war": false,
					"is_allied": false,
					"access": { f1: false, f2: false },
					"improving": { f1: false, f2: false },
					"insult_cooldown": { f1: 0, f2: 0 }
				}

func _get_or_create_record(facA: String, facB: String) -> Dictionary:
	if facA == facB:
		return {}
	var key = get_pair_key(facA, facB)
	if not diplomacy_matrix.has(key):
		diplomacy_matrix[key] = {
			"relations": 0,
			"is_at_war": false,
			"is_allied": false,
			"access": { facA: false, facB: false },
			"improving": { facA: false, facB: false },
			"insult_cooldown": { facA: 0, facB: 0 }
		}
	return diplomacy_matrix[key]

# --- TRUY VẤN VÀ CẬP NHẬT QUAN HỆ ---

func get_relation(facA: String, facB: String) -> int:
	if facA == facB:
		return 100
	var rec = _get_or_create_record(facA, facB)
	return int(rec.get("relations", 0))

func set_relation(facA: String, facB: String, val: int) -> void:
	if facA == facB:
		return
	var rec = _get_or_create_record(facA, facB)
	rec["relations"] = clamp(val, -100, 100)

func change_relation(facA: String, facB: String, delta: int) -> void:
	if facA == facB:
		return
	var rec = _get_or_create_record(facA, facB)
	rec["relations"] = clamp(int(rec.get("relations", 0)) + delta, -100, 100)

# --- CHIẾN TRANH ---

func is_at_war(facA: String, facB: String) -> bool:
	if facA == facB or facA == "" or facB == "":
		return false
	var rec = _get_or_create_record(facA, facB)
	return rec.get("is_at_war", false)

func declare_war(facA: String, facB: String) -> void:
	if facA == facB:
		return
	var rec = _get_or_create_record(facA, facB)
	rec["is_at_war"] = true
	rec["is_allied"] = false
	if rec.has("access"):
		rec["access"][facA] = false
		rec["access"][facB] = false
	if rec.has("improving"):
		rec["improving"][facA] = false
		rec["improving"][facB] = false
	rec["relations"] = -100

# --- LIÊN MINH QUÂN SỰ ---

func is_allied(facA: String, facB: String) -> bool:
	if facA == facB:
		return true
	var rec = _get_or_create_record(facA, facB)
	return rec.get("is_allied", false)

func form_alliance(facA: String, facB: String) -> void:
	if facA == facB:
		return
	var rec = _get_or_create_record(facA, facB)
	rec["is_allied"] = true
	rec["is_at_war"] = false
	if not rec.has("access"):
		rec["access"] = {}
	rec["access"][facA] = true
	rec["access"][facB] = true
	if rec.get("relations", 0) < MIN_RELATION_ALLIANCE:
		rec["relations"] = MIN_RELATION_ALLIANCE

# --- QUYỀN HÀNH QUÂN (MILITARY ACCESS) ---

func has_military_access(from_fac: String, through_fac: String) -> bool:
	if from_fac == through_fac:
		return true
	if is_allied(from_fac, through_fac):
		return true
	var rec = _get_or_create_record(from_fac, through_fac)
	if rec.has("access"):
		return rec["access"].get(from_fac, false)
	return false

func grant_military_access(from_fac: String, through_fac: String) -> void:
	if from_fac == through_fac:
		return
	var rec = _get_or_create_record(from_fac, through_fac)
	if not rec.has("access"):
		rec["access"] = {}
	rec["access"][from_fac] = true

# --- CẢI THIỆN QUAN HỆ (DIPLOMATS) ---

func is_improving_relations(from_fac: String, to_fac: String) -> bool:
	if from_fac == to_fac:
		return false
	var rec = _get_or_create_record(from_fac, to_fac)
	if rec.has("improving"):
		return rec["improving"].get(from_fac, false)
	return false

func set_improving_relations(from_fac: String, to_fac: String, active: bool) -> void:
	if from_fac == to_fac:
		return
	var rec = _get_or_create_record(from_fac, to_fac)
	if not rec.has("improving"):
		rec["improving"] = {}
	rec["improving"][from_fac] = active

func get_player_diplomat_count(player_fac: String) -> int:
	var count = 0
	for other in all_factions:
		if other != player_fac and is_improving_relations(player_fac, other):
			count += 1
	return count

func get_player_diplomat_expense(player_fac: String) -> int:
	return get_player_diplomat_count(player_fac) * DIPLOMAT_COST

# --- XÚC PHẠM NGOẠI GIAO (INSULT) ---

func get_insult_cooldown(from_fac: String, to_fac: String) -> int:
	if from_fac == to_fac:
		return 0
	var rec = _get_or_create_record(from_fac, to_fac)
	if rec.has("insult_cooldown"):
		return rec["insult_cooldown"].get(from_fac, 0)
	return 0

func can_insult(from_fac: String, to_fac: String) -> bool:
	return get_insult_cooldown(from_fac, to_fac) <= 0

func insult(from_fac: String, to_fac: String) -> void:
	if from_fac == to_fac:
		return
	var rec = _get_or_create_record(from_fac, to_fac)
	change_relation(from_fac, to_fac, INSULT_PENALTY)
	if not rec.has("insult_cooldown"):
		rec["insult_cooldown"] = {}
	rec["insult_cooldown"][from_fac] = INSULT_COOLDOWN_MONTHS

# --- DANH SÁCH TOP PHE THÂN THIẾT & THÙ ĐỊCH ---

func get_top_friends(fac: String, limit: int = 3) -> Array:
	var list: Array = []
	for other in all_factions:
		if other != fac and other != "":
			list.append({
				"faction": other,
				"relations": get_relation(fac, other)
			})
	list.sort_custom(func(a, b): return a["relations"] > b["relations"])
	return list.slice(0, limit)

func get_top_enemies(fac: String, limit: int = 3) -> Array:
	var list: Array = []
	for other in all_factions:
		if other != fac and other != "":
			list.append({
				"faction": other,
				"relations": get_relation(fac, other)
			})
	list.sort_custom(func(a, b): return a["relations"] < b["relations"])
	return list.slice(0, limit)

# --- CƠ CHẾ CẬP NHẬT HÀNG THÁNG (MONTHLY TICK) ---

func monthly_tick(player_fac: String, player_gold: int) -> Dictionary:
	var diplomat_count = 0
	var cancelled_factions: Array = []
	
	for key in diplomacy_matrix.keys():
		var rec = diplomacy_matrix[key]
		var parts = key.split("<#>")
		if parts.size() != 2:
			continue
		var f1 = parts[0]
		var f2 = parts[1]
		
		var improving_f1 = rec.get("improving", {}).get(f1, false)
		var improving_f2 = rec.get("improving", {}).get(f2, false)
		var is_allied_pair = rec.get("is_allied", false)
		var is_at_war_pair = rec.get("is_at_war", false)
		
		# 1. Cải thiện quan hệ từ f1
		if improving_f1:
			if f1 == player_fac:
				if player_gold >= (diplomat_count + 1) * DIPLOMAT_COST:
					diplomat_count += 1
					rec["relations"] = min(100, rec.get("relations", 0) + DIPLOMAT_RELATION_BOOST)
				else:
					rec["improving"][f1] = false
					cancelled_factions.append(f2)
			else:
				rec["relations"] = min(100, rec.get("relations", 0) + DIPLOMAT_RELATION_BOOST)
		
		# 2. Cải thiện quan hệ từ f2
		if improving_f2:
			if f2 == player_fac:
				if player_gold >= (diplomat_count + 1) * DIPLOMAT_COST:
					diplomat_count += 1
					rec["relations"] = min(100, rec.get("relations", 0) + DIPLOMAT_RELATION_BOOST)
				else:
					rec["improving"][f2] = false
					cancelled_factions.append(f1)
			else:
				rec["relations"] = min(100, rec.get("relations", 0) + DIPLOMAT_RELATION_BOOST)
		
		# 3. Trôi quan hệ về 0 cho các phe không có tương tác
		if not improving_f1 and not improving_f2 and not is_allied_pair and not is_at_war_pair:
			var r = int(rec.get("relations", 0))
			if r > 0:
				rec["relations"] = r - 1
			elif r < 0:
				rec["relations"] = r + 1
		
		# 4. Giảm cooldown xúc phạm ngoại giao
		if rec.has("insult_cooldown"):
			for f in [f1, f2]:
				if rec["insult_cooldown"].get(f, 0) > 0:
					rec["insult_cooldown"][f] -= 1
	
	return {
		"diplomat_count": diplomat_count,
		"diplomat_cost": diplomat_count * DIPLOMAT_COST,
		"cancelled_factions": cancelled_factions
	}
