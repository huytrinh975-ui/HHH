# Dự án: Game Grand Strategy 2D (Tương tự Age of History)
- Engine: Godot 4 (GDScript)
- Cấu trúc ổn định hiện tại:
  + main.tscn: Gồm node gốc Node2D (gắn main.gd), Sprite2D tên Test (chứa ảnh VN Map.png, gắn ShaderMaterial province_selection.gdshader), Camera2D (gắn camera_controller.gd), và CanvasLayer tên UI chứa:
    - ProvincePanel: Hiển thị thông tin tỉnh, nút tuyển quân (+10 | 20💰) và cặp nút điều quân tỷ lệ (Điều 50% / Điều 100%).
    - NotificationPanel: Hiển thị thông báo trạng thái, tin chiến sự, thu thuế.
    - TimePanel: Góc trên bên phải hiển thị Tiền vàng, Ngày/Tháng/Năm, Nút Pause/Play và các nút chỉnh tốc độ 1x, 2x, 3x.
  + camera_controller.gd: Quản lý kéo bản đồ (Pan bằng chuột phải/giữa, phím WASD/mũi tên) và phóng to/thu nhỏ mượt mà (Zoom con lăn chuột hướng theo trỏ chuột, clamp min/max). Đã sửa cảnh báo property shadowing bằng `mouse_offset`.
  + VN Map.png: Ảnh bản đồ hiển thị gốc (1900x2833).
  + provinces.json: Chứa danh sách 4 vùng miền ổn định chuẩn (Bắc Bộ #ff0000, Bắc Trung Bộ #00ff00, Nam Trung Bộ & Tây Nguyên #ffff00, Nam Bộ #0000ff).
  + province_selection.gdshader:
    - Shader GPU so khớp `texture(TEXTURE, UV)` với `target_color`.
    - Làm sáng nhẹ diện tích tỉnh (`tint_factor = 0.35`) và vẽ viền trắng tương phản xung quanh viền ranh giới (`outline_width = 2.0`).
    - Biên dịch sạch sẽ, không dùng `return` trong `fragment()`.
  + main.gd:
    - Nhân bản `id_map_image = map_image.duplicate()` lúc `_ready()` đảm bảo 100% đồng bộ pixel, không phụ thuộc file ngoài gây lệch tỉ lệ hay kích thước.
    - Color-picking và phân định ranh giới hoạt động tức thì, ổn định 100%.
    - Hệ thống thời gian thực có tạm dừng (Real-Time with Pause): Bắt đầu từ 01/01/2026, các tốc độ 1x, 2x, 3x và phím tắt `Space`, `1`, `2`, `3`. Khóa tuyển/điều quân khi Pause.
    - Hệ thống điều động quân số theo tỷ lệ: Tùy chọn 50% hoặc 100% quân số, giữ chủ quyền tỉnh xuất phát, trừ hao giao tranh chuẩn xác.
    - Hệ thống kinh tế & thuế: Khởi đầu 100 vàng, thuế +25 vàng/tỉnh ngày đầu tháng, chi phí tuyển quân 20 vàng.
    - Đổi màu lãnh thổ khi bị chiếm (Dynamic Map Repainting) chuẩn xác và mượt mà.
