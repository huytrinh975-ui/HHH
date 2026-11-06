# Quy tắc Gameplay - Game Chiến thuật 2D 63 Tỉnh thành

Tài liệu này định nghĩa các quy tắc cốt lõi (source of truth) cho toàn bộ logic gameplay. Mọi tính năng mới, sửa đổi, hoặc refactor đều **bắt buộc** tuân thủ các quy tắc dưới đây. Không được ngoại lệ.

---

## 1. Di chuyển & Đồ thị láng giềng

### 1.1 Chỉ dùng danh sách láng giềng (`neighbors`)
- Mọi tương tác di chuyển giữa 63 tỉnh thành **bắt buộc** dùng danh sách đồ thị láng giềng `neighbors` trong `provinces.json`.
- **Tuyệt đối cấm**: Raycast, ray-casting, quét va chạm vật lý đường thẳng (`PhysicsRayQueryParameters2D`, `Area2D` overlap, `PhysicsDirectSpaceState2D.intersect_ray`, v.v.) trên đường đi.
- Tìm đường sử dụng thuật toán BFS/Dijkstra/A* trên đồ thị `neighbors` - xem hàm `find_path()` trong `main.gd`.

### 1.2 Node quân lính chỉ là Sprite (Visual Dummy)
- Đơn vị hành quân (`active_armies`) trên bản đồ chỉ là **node hiển thị visual** (`Node2D` chứa `PanelContainer` + `Label`), **không** gán `Area2D`, `CollisionShape2D`, hay bất kỳ `PhysicsBody2D` nào.
- Giao tranh và trừ quân **chỉ kích hoạt đúng 1 lần duy nhất** tại hàm `_resolve_army_arrival()` khi đơn vị đến tỉnh đích.

### 1.3 Quy tắc đi qua tỉnh trung gian (Waypoint transit)
- Tỉnh trung gian chỉ được phép đi xuyên qua nếu thỏa mãn **một** trong các điều kiện:
  1. Là đất của phe mình (`next_fac == mover_faction`)
  2. Là đất của đồng minh (`DiplomacyManager.is_allied(mover_faction, next_fac)`)
  3. Đã được cấp quyền hành quân (`DiplomacyManager.has_military_access(mover_faction, next_fac)`)
- **Tuyệt đối cấm**: Tự động tuyên chiến, tự động gây giao tranh, hay trừ quân khi đi qua tỉnh trung gian. Chỉ xử lý giao tranh tại tỉnh đích cuối cùng (target).

### 1.4 Kiểm tra trạng thái chiến tranh (`is_at_war`)
- Trước khi thực hiện **bất kỳ** lệnh: tấn công, càn quét (sweep), double-clickdispatch, confirm_target, **bắt buộc** gọi `can_send_troops_to(source, target, true)`.
- Hàm `can_send_troops_to()` trong `main.gd` đã tập trung logic này:
  - Cùng phe / đất vô chủ → Cho phép
  - Đồng minh → Cho phép (chi viện)
  - Phe khác không phải đồng minh → **Bắt buộc** `DiplomacyManager.is_at_war(src_fac, tgt_fac) == true`

### 1.5 Cho phép hủy lệnh di chuyển ("Ngưng hành quân")
- Người chơi có thể hủy lệnh điều quân giữa đường bằng cách click ra ngoài hoặc click lại tỉnh xuất phát.
- Xem `cancel_move_mode()` và logic trong `handle_left_click()` khi `is_move_mode == true`.

---

## 2. Kinh tế & Dân số

### 2.1 Quyết toán tài chính (Monthly Economy Tick)
- Diễn ra vào **ngày 01 hàng tháng** (khi `current_day` chuyển từ cuối tháng sang 1).
- Hàm xử lý: `trigger_monthly_economy()` trong `main.gd`, được gọi từ `advance_one_day()`.

### 2.2 Công thức Thu nhập
```
Tổng thu nhập tỉnh = BASE_INCOME_PER_PROVINCE (10 đồng) + Thuế lao động
Thuế lao động = floor(Tổng dân số nam/nữ độ tuổi lao động / 100.000)
```
- Xem `get_province_income()` và `get_working_age_population()`.

### 2.3 Chi phí duy trì quân sự (Upkeep)
```
Chi phí tháng = Tổng số quân của người chơi * UPKEEP_PER_TROOP (0.1 đồng/lính/tháng)
```
- Xem `get_player_military_upkeep()`.

### 2.4 Tuyển quân (Recruitment)
- Đơn giá: **COST_PER_TROOP = 2 Vàng / lính** (hằng số trong `main.gd`).
- Giới hạn tối đa: **3% nam giới độ tuổi lao động** của tỉnh (`male_working_age * 0.03`).
- Trừ trực tiếp vào số liệu nhân khẩu học:
  - `demographics.male.working_age -= count`
  - `total_population -= count`
- Hạn ngạch tháng: Theo dõi qua `recruited_this_month`, reset đầu tháng mới.
- Xem `_on_confirm_recruit_pressed()`, `get_max_recruitable()`, `get_remaining_pop_quota()`.

### 2.5 Hiển thị thu ròng (Net Gold)
- Label vàng hiển thị: `💰 {tổng_vàng} ({+/-}{thu_ròng}/thg)`
- Màu xanh (`#69f0ae`) nếu thu ròng ≥ 0, màu đỏ (`#ff5252`) nếu âm.
- Xem `update_gold_display()`.

---

## 3. Ngoại giao (Diplomacy) - Các ngưỡng quan trọng

| Hành động | Yêu cầu quan hệ | Chi phí | Cooldown |
|-----------|----------------|---------|----------|
| Cải thiện (Đ 파견 ngoại giao) | Bất kỳ | 5 Vàng/tháng | - |
| Xin quyền hành quân | ≥ +20 | Miễn phí | - |
| Ký hiệp ước Liên minh | ≥ +75 | Miễn phí | - |
| Xúc phạm ngoại giao | Bất kỳ | Miễn phí | 3 tháng |
| Tuyên chiến | Bất kỳ | Miễn phí | - |

- Xem `DiplomacyManager` constants: `MIN_RELATION_ACCESS`, `MIN_RELATION_ALLIANCE`, `INSULT_COOLDOWN_MONTHS`, `DIPLOMAT_COST`, `INSULT_PENALTY`.

---

## 4. Tương tác Click & Điều khiển

### 4.1 Phân biệt Click vs Pan Camera
- Chỉ xử lý click chọn tỉnh khi: **không kéo camera** VÀ **khoảng cách chạm/nhấc < 15px**.
- Xem `_unhandled_input()` và `handle_left_click()`: check `camera_is_panning` và `mouse_press_pos.distance_to(event.position) < 15.0`.

### 4.2 Double-click nhanh (0.35s)
- Click 1 lần chọn tỉnh nguồn → Lưu `potential_double_click_source`.
- Click 2 lần trong ≤ 0.35s vào tỉnh đích khác → Tự động điều **100% quân** từ nguồn sang đích.
- Kiểm tra ngoại giao (`can_send_troops_to`) trước khi dispatch.

### 4.3 Chế độ chọn mục tiêu (Move Mode)
- Nhấn "Điều quân..." → Mở slider chọn số lượng → Nhấn "🎯 Chọn mục tiêu" → Bật `is_move_mode = true`.
- Click tỉnh đích trên bản đồ → Gọi `dispatch_army()` → Tự tắt `is_move_mode`.

---

## 5. Càn quét (Sweep) - Tấn công đa hướng

- Chỉ khả thi khi: Tỉnh nguồn thuộc phe người chơi, có ≥ 10 quân, **và** có láng giềng địch **đang có chiến tranh**.
- Chia đều quân (trừ 10 quân phòng thủ) cho các mũi tấn công giáp ranh.
- Gọi `dispatch_army()` cho từng mục tiêu độc lập.

---

## 6. Quy tắc dữ liệu & Persistence

- `provinces.json`: Nguồn dữ liệu chính, chứa `id`, `name`, `neighbors` (array int), `center` [x,y], `color` (hex ID map), `faction`, `troops`, `demographics`, `total_population`.
- Mọi thay đổi runtime (màu lãnh thổ, quân số, dân số, quan hệ ngoại giao) cập nhật trực tiếp trên `provinces_data` array và `diplomacy_matrix` dictionary.

---

## ⚠️ Cấm tuyệt đối (Anti-patterns)

| Cấm | Lý do | Thay thế đúng |
|-----|-------|---------------|
| `Area2D`/`CollisionShape2D` trên unit hành quân | Gây giao tranh nhầm ở tỉnh trung gian, hiệu năng kém | Visual dummy + `dispatch_army` + `_resolve_army_arrival` |
| Raycast/Physics ray query tìm đường | Không chính xác ranh giới tỉnh, chậm | BFS trên `neighbors` graph |
| Tự động `declare_war` khi đi qua tỉnh trung gian | Vi phạm quy tắc ngoại giao, gây chiến tranh nhầm | Chỉ tuyên chiến tại đích trong `_resolve_army_arrival` |
| Hardcode tên tỉnh/ID trong logic | Không mở rộng được 63 tỉnh | Tra `provinces_by_id`, `provinces_by_id_num` |
| Bỏ qua `can_send_troops_to` trước dispatch | Gây bug ngoại giao, tấn công khi hòa bình | Luôn gọi guard check đầu hàm |

---

## 📌 Nguyên tắc mở rộng (Extension Principles)

1. **Single Source of Truth**: Logic ngoại giao chỉ ở `DiplomacyManager`, logic di chuyển chỉ ở `main.gd` (`find_path`, `dispatch_army`, `_resolve_army_arrival`).
2. **Guard First**: Mọi entry point công khai (button, click, double-click, sweep) phải gọi `can_send_troops_to()` đầu tiên.
3. **Visual ≠ Logic**: Node hiển thị (`armies_container` children) hoàn toàn tách biệt khỏi dữ liệu (`active_armies` array).
4. **Deterministic Combat**: Giao tranh chỉ ở `_resolve_army_arrival`, công thức đơn giản: `attacker > defender → chiếm đất, troops = diff`; ngược lại `defender -= attacker`.
5. **Monthly Tick Atomic**: `trigger_monthly_economy()` chạy một lần, cập nhật tất cả: thuế, upkeep, ngoại giao, quan hệ trôi, cooldown.