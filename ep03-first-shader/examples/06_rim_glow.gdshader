// 範例 6：邊緣發光。表面越斜著對著我們，光越強（Fresnel 的原理）。
shader_type spatial;

uniform vec3 glow_color : source_color = vec3(0.3, 0.9, 1.0);

void fragment() {
	// NORMAL 是表面朝向，VIEW 是看過去的方向；正對著看時內積接近 1，邊緣接近 0
	float rim = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	ALBEDO = vec3(0.02, 0.05, 0.1);
	EMISSION = glow_color * pow(rim, 3.0) * 3.0;   // EMISSION：自己發光
}
