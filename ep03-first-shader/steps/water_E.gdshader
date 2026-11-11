// 第 3 集：水的第一個 shader。
// 顯示卡替畫面上的每一個像素執行一次 fragment()，決定這個像素是什麼顏色。
shader_type spatial;

// uniform：可以在屬性檢視器調整的參數（就像 GDScript 的 @export）
uniform vec3 deep_color : source_color = vec3(0.02, 0.13, 0.22);    // 浪谷的顏色
uniform vec3 crest_color : source_color = vec3(0.05, 0.28, 0.38);   // 浪峰的顏色
uniform float amplitude = 1.0;     // 和第 2 集的浮標用一樣的數字
uniform float wavelength = 16.0;
uniform float speed = 4.0;
uniform float plane_size = 2000.0;                  // 海面有多大（公尺）
uniform vec2 waves_origin = vec2(0.0, -26.0);       // 浮標方陣的中心（Buoys 節點的位置）
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D ripple_texture : hint_normal;     // 細小波紋的法線貼圖
uniform float ripple_scale = 100.0;                 // 波紋貼圖鋪幾次
uniform vec2 ripple_flow = vec2(0.1, 0.0);          // 波紋每秒滑動幾格


// 一個 sin 波，和第 2 集 buoys.gd 裡的 sine_wave 一模一樣。
float sine_wave(float d, float t, float a, float len, float v) {
	return a * sin(6.2831853 / len * (d - v * t));
}


// 把三個波加起來，也和第 2 集的 wave_height 一樣。
float wave_height(float x, float z, float t) {
	float h = 0.0;
	h += sine_wave(x, t, amplitude, wavelength, speed);
	h += sine_wave(x * 0.6 + z * 0.8, t, amplitude * 0.5, wavelength * 0.6, speed * 0.8);
	h += sine_wave(z * 0.9 - x * 0.4, t, amplitude * 0.25, wavelength * 0.35, speed * 1.2);
	return h;
}


void fragment() {
	vec2 p = (UV - 0.5) * plane_size - waves_origin;
	float h = wave_height(p.x, p.y, TIME);
	float t = clamp(h / 3.5 + 0.5, 0.0, 1.0);
	ALBEDO = mix(deep_color, crest_color, t);
	ROUGHNESS = roughness;
}
