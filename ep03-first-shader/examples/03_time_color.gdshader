// 範例 3：隨時間變色。TIME 是遊戲開始後經過的秒數。
shader_type spatial;

void fragment() {
	float t = 0.5 + 0.5 * sin(TIME * 2.0);                     // 在 0 和 1 之間來回
	ALBEDO = mix(vec3(0.0, 0.2, 0.5), vec3(0.2, 0.8, 0.9), t);  // 在兩個顏色之間混合
}
