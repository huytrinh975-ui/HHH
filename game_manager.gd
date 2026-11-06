extends Node

# Định nghĩa các chế độ chơi / kịch bản
const MODE_SCENARIO_1611 = "DAI_VIET_1611"
const MODE_FOUR_FACTIONS = "TU_QUOC"
const MODE_63_WARLORDS = "LOAN_63"

# Trạng thái hiện tại
var current_mode: String = MODE_SCENARIO_1611
var is_lobby_mode: bool = true
var selected_player_faction: String = ""
var _player_faction: String = "LE_TRINH"

var player_faction: String:
	get:
		if selected_player_faction != "":
			return selected_player_faction
		return _player_faction
	set(val):
		_player_faction = val
		selected_player_faction = val

var player_province_id: String = "VNHN"

# Bảng màu 63 phe cho chế độ "Loạn 63 Xứ Quân"
var warlord_colors: Dictionary = {}

func set_player_faction(faction_id: String) -> void:
	selected_player_faction = faction_id
	_player_faction = faction_id

func _ready() -> void:
	init_warlord_colors()

func init_warlord_colors() -> void:
	warlord_colors.clear()
	# Tạo 63 màu sắc rực rỡ, độc nhất dựa trên phân bổ tỷ lệ vàng (Golden Ratio HSV)
	for i in range(63):
		var hue = fmod(float(i) * 0.618033988749895, 1.0)
		var sat = 0.78 if (i % 2 == 0) else 0.88
		var val = 0.85 if (i % 3 == 0) else 0.95
		warlord_colors[i + 1] = Color.from_hsv(hue, sat, val)

func get_warlord_color_by_num(id_num: int) -> Color:
	if warlord_colors.has(id_num):
		return warlord_colors[id_num]
	return Color.WHITE

func get_warlord_color_by_hex(id_hex: String) -> Color:
	var c = Color.from_string(id_hex, Color.BLACK)
	var id_num = int(round(c.b * 255.0))
	return get_warlord_color_by_num(id_num)
