// 範例 2：UV 漸層。每個像素都知道自己在表面上的位置。
shader_type spatial;

void fragment() {
	ALBEDO = vec3(UV.x, UV.y, 0.5);  // 左右越右越紅，上下越下越綠
}
