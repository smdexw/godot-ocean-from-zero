// 範例 1：單色。最小的 shader。
shader_type spatial;

void fragment() {
	ALBEDO = vec3(1.0, 0.45, 0.1);   // 紅、綠、藍，每個都是 0 到 1
}
