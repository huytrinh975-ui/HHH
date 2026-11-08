shader_type canvas_item;

uniform sampler2D id_map_texture : hint_default_black, filter_nearest;

// Cấu hình viền ranh giới chung cho toàn bộ 63 tỉnh
uniform vec4 province_border_color : source_color = vec4(0.08, 0.08, 0.08, 1.0);
uniform float province_border_width : hint_range(0.5, 5.0) = 1.0;

// Cấu hình cho tỉnh đang được chọn (Highlight)
uniform bool is_selected = false;
uniform vec4 target_color : source_color = vec4(0.0);
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform float tint_factor : hint_range(0.0, 1.0) = 0.35;

// Cấu hình cho các tỉnh trong vùng quét chọn (Multi Box Selection)
uniform bool is_multi_selected = false;
uniform vec4 multi_selected_colors[64];
uniform int multi_selected_count = 0;
uniform vec4 multi_outline_color : source_color = vec4(0.2, 1.0, 0.45, 1.0);
uniform vec4 multi_pulse_color : source_color = vec4(1.0, 0.88, 0.2, 1.0);

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	// Lấy ID tại pixel hiện tại (0 - 255)
	ivec3 cur_id = ivec3(round(texture(id_map_texture, UV).rgb * 255.0));
	
	// 1. Nếu pixel là biển hoặc khoảng trống: Giữ nguyên màu nền
	if (cur_id == ivec3(0) || original_color.a < 0.1) {
		COLOR = original_color;
	} else {
		// 2. Dò viền ranh giới chung giữa các tỉnh
		vec2 b_step = TEXTURE_PIXEL_SIZE * province_border_width;
		ivec3 up_id    = ivec3(round(texture(id_map_texture, UV + vec2(0.0, -b_step.y)).rgb * 255.0));
		ivec3 down_id  = ivec3(round(texture(id_map_texture, UV + vec2(0.0, b_step.y)).rgb * 255.0));
		ivec3 left_id  = ivec3(round(texture(id_map_texture, UV + vec2(-b_step.x, 0.0)).rgb * 255.0));
		ivec3 right_id = ivec3(round(texture(id_map_texture, UV + vec2(b_step.x, 0.0)).rgb * 255.0));

		bool is_province_border = (cur_id != up_id) || (cur_id != down_id) || 
		                          (cur_id != left_id) || (cur_id != right_id);

		// 3. Xử lý highlight các tỉnh trong vùng quét chọn (Multi Box Selection)
		bool handled_selection = false;
		if (is_multi_selected && multi_selected_count > 0) {
			bool is_in_multi = false;
			for (int i = 0; i < multi_selected_count; i++) {
				ivec3 sel_id = ivec3(round(multi_selected_colors[i].rgb * 255.0));
				if (sel_id != ivec3(0) && cur_id == sel_id) {
					is_in_multi = true;
					break;
				}
			}

			if (is_in_multi) {
				float pulse = 0.5 + 0.5 * sin(TIME * 6.0);
				vec4 active_multi_border = mix(multi_outline_color, multi_pulse_color, pulse);

				vec2 o_step = TEXTURE_PIXEL_SIZE * outline_width;
				ivec3 o_up    = ivec3(round(texture(id_map_texture, UV + vec2(0.0, -o_step.y)).rgb * 255.0));
				ivec3 o_down  = ivec3(round(texture(id_map_texture, UV + vec2(0.0, o_step.y)).rgb * 255.0));
				ivec3 o_left  = ivec3(round(texture(id_map_texture, UV + vec2(-o_step.x, 0.0)).rgb * 255.0));
				ivec3 o_right = ivec3(round(texture(id_map_texture, UV + vec2(o_step.x, 0.0)).rgb * 255.0));

				bool is_multi_border = (cur_id != o_up) || (cur_id != o_down) || 
				                       (cur_id != o_left) || (cur_id != o_right);

				if (is_multi_border) {
					COLOR = active_multi_border; // Viền vàng / xanh lá nhấp nháy rực rỡ
				} else {
					COLOR.rgb = mix(original_color.rgb, active_multi_border.rgb, 0.22); // Làm sáng nhẹ diện tích tỉnh
					COLOR.a = original_color.a;
				}
				handled_selection = true;
			}
		}

		// 4. Xử lý highlight tỉnh đang chọn đơn lẻ (Single Selection)
		if (!handled_selection && is_selected) {
			ivec3 target_id = ivec3(round(target_color.rgb * 255.0));
			if (target_id != ivec3(0) && cur_id == target_id) {
				vec2 o_step = TEXTURE_PIXEL_SIZE * outline_width;
				ivec3 o_up    = ivec3(round(texture(id_map_texture, UV + vec2(0.0, -o_step.y)).rgb * 255.0));
				ivec3 o_down  = ivec3(round(texture(id_map_texture, UV + vec2(0.0, o_step.y)).rgb * 255.0));
				ivec3 o_left  = ivec3(round(texture(id_map_texture, UV + vec2(-o_step.x, 0.0)).rgb * 255.0));
				ivec3 o_right = ivec3(round(texture(id_map_texture, UV + vec2(o_step.x, 0.0)).rgb * 255.0));

				bool is_selected_border = (cur_id != o_up) || (cur_id != o_down) || 
				                          (cur_id != o_left) || (cur_id != o_right);

				if (is_selected_border) {
					COLOR = outline_color; // Tô viền highlight
				} else {
					COLOR.rgb = mix(original_color.rgb, vec3(1.0), tint_factor); // Làm sáng trong tỉnh
					COLOR.a = original_color.a;
				}
				handled_selection = true;
			}
		}

		// 4. Nếu không phải tỉnh đang được highlight, hiển thị viền chung hoặc màu nền gốc
		if (!handled_selection) {
			if (is_province_border) {
				COLOR = province_border_color; // Viền ranh giới đen giữa các tỉnh
			} else {
				COLOR = original_color;
			}
		}
	}
}