# Quy ước Code - Godot 4.x (GDScript)

Tài liệu này định nghĩa các chuẩn lập trình, cấu trúc code, và conventions cho toàn bộ dự án game chiến thuật 63 tỉnh thành trên Godot 4.x.

---

## 1. Cú pháp & Nguyên tắc GDScript 4.x

### 1.1 Strong Typing (Typed GDScript)
- Luôn sử dụng kiểu dữ liệu cho biến, tham số hàm, và giá trị trả về.
- Cấm sử dụng kiểu dữ liệu mặc định là `Variant` (trừ khi cực kỳ cần thiết).
- **Ví dụ:**
  ```gdscript
  var player_gold: int = 100
  var army_data: Dictionary = {}
  func get_path(from: Dictionary, to: Dictionary) -> Array:
  ```

### 1.2 Attributes & Decorators
- Sử dụng `@export` cho mọi giá trị cần chỉnh sửa trong Editor.
- Sử dụng `@onready` cho các node con để đảm bảo đã sẵn sàng.
- **Ví dụ:**
  ```gdscript
  @export var army_speed: float = 1.5
  @onready var army_label: Label = $Badge/ArmyLabel
  ```

### 1.3 Signals & Callables
- Sử dụng Signal cho các sự kiện không đồng bộ thay vì Polling liên tục.
- Sử dụng `Callable` để gán sự kiện nút bấm hoặc timer cho gọn.
- **Ví dụ:**
  ```gdscript
  button.pressed.connect(func(): on_action_triggered())
  ```

---

## 2. Kiến trúc Quản lý (Architecture)

### 2.1 Singleton / Autoload Pattern
- Các trình quản lý dữ liệu toàn cục bắt buộc đặt vào Autoload.
- `DiplomacyManager`: Quản lý toàn bộ ma trận quan hệ, chiến tranh, liên minh, cải thiện quan hệ.
- `GameManager`: Lưu trạng thái, cài đặt chung (mode chơi, màu phe, id phe).
- `ProvinceManager` (nếu có): Quản lý tập trung dữ liệu tỉnh thành.

### 2.2 Tách biệt Logic & UI
- Script chính (`main.gd`) chỉ đóng vai trò điều phối (controller).
- Logic tính toán kinh tế/quân sự phải tách vào function, tránh viết trực tiếp trong `_process` hoặc `handle_left_click`.

---

## 3. Di chuyển & Tweening (Visual Smoothness)

- Tuyệt đối không di chuyển object thủ công bằng cách cộng tọa độ trong `_process`.
- Luôn sử dụng `create_tween()` để di chuyển visual đơn vị từ điểm A đến điểm B.
- **Quy tắc Tweening:**
  - Ngắt tween (`tween.kill()`) an toàn ngay khi có lệnh hủy hành quân (`cancel_move_mode`).
  - Lộ trình: Di chuyển tuần tự qua danh sách waypoint (tỉnh láng giềng) trong `path`.

---

## 4. Quy ước Đặt tên (Naming Conventions)

- **Biến/Hàm:** `snake_case` (ví dụ: `player_gold`, `trigger_monthly_economy`).
- **Class/Node:** `PascalCase` (ví dụ: `MainMenu`, `ProvincePanel`).
- **Hằng số:** `SCREAMING_SNAKE_CASE` (ví dụ: `COST_PER_TROOP`).
- **Ghi chú:** Ưu tiên dùng Tiếng Việt (theo yêu cầu dự án) cho chú thích, mô tả UI.

---

## 5. Quy tắc Code Review & Kiểm tra (Quality Gate)

### 5.1 Trước khi Commit / PR
- **Checklist bắt buộc:**
  - [ ] Đã đọc `gameplay_rules.md` chưa?
  - [ ] Có dùng `Area2D` hay `Raycast` cho unit hành quân không? (Nếu có → CẤM).
  - [ ] Kiểm tra `is_at_war` trước khi dispatch quân chưa?
  - [ ] Có dùng typed GDScript đầy đủ chưa?
  - [ ] Có ngắt tween an toàn không?

### 5.2 Xử lý lỗi (Error Handling)
- Sử dụng `if is_instance_valid(node):` trước khi truy cập bất kỳ node nào được dynamic `queue_free()`.
- Kiểm tra `is_empty()` trước khi truy cập bất kỳ phần tử dictionary tỉnh thành nào để tránh crash runtime.

---

## 6. Mẫu cấu trúc một hàm chuẩn

```gdscript
func example_function(prov_id: String, count: int) -> bool:
    # 1. Bảo vệ (Guard Clauses)
    if prov_id == "" or count <= 0:
        return false
    
    # 2. Logic chính
    var prov = provinces_by_id.get(prov_id)
    if not prov:
        return false
    
    # 3. Tác vụ (hạn chế lồng if/else quá nhiều)
    # ...
    
    return true
```

---

*Tài liệu này là cam kết chuẩn hóa code của dự án. Mọi sự thay đổi phải được thống nhất và cập nhật vào đây trước khi áp dụng.*