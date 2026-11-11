// 範例 5：圓形漣漪。用「離中心的距離」代替位置。
shader_type spatial;

void fragment() {
	float d = distance(UV, vec2(0.5));                    // 離中心多遠
	float wave = 0.5 + 0.5 * sin(d * 60.0 - TIME * 4.0);  // 一圈一圈往外跑
	ALBEDO = mix(vec3(0.0, 0.15, 0.35), vec3(0.4, 0.9, 1.0), wave);
}
