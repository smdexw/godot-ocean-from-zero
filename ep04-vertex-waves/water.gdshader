// 第 4 集：用 vertex() 把平面推成浪。
// vertex() 替網格的每一個頂點執行一次，決定頂點在哪裡；fragment() 再替每個像素決定顏色。
shader_type spatial;

// uniform：可以在屬性檢視器調整的參數（就像 GDScript 的 @export）
uniform vec3 deep_color : source_color = vec3(0.02, 0.13, 0.22);    // 浪谷的顏色
uniform vec3 crest_color : source_color = vec3(0.05, 0.28, 0.38);   // 浪峰的顏色
uniform float amplitude = 1.0;     // 和第 2 集的浮標用一樣的數字
uniform float wavelength = 16.0;
uniform float speed = 4.0;
uniform vec2 waves_origin = vec2(0.0, -26.0);       // 浮標方陣的中心（Buoys 節點的位置）
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D ripple_texture : hint_normal;     // 細小波紋的法線貼圖
uniform float ripple_size = 20.0;                   // 波紋貼圖每一格幾公尺
uniform vec2 ripple_flow = vec2(0.1, 0.0);          // 波紋每秒滑動幾格

// varying：vertex() 算好、交給 fragment() 用的數值
varying float height;      // 這裡的浪有多高
varying vec2 world_xz;     // 這裡在世界中的位置（公尺）


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


void vertex() {
	// VERTEX 是頂點在 Sea 自己身上的位置（本地座標）。
	// 乘上 MODEL_MATRIX 換成世界座標，海面移到哪裡，浪都還在同一個地方。
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz - waves_origin;       // 和浮標從同一個點開始量

	height = wave_height(p.x, p.y, TIME);
	VERTEX.y += height;                     // 把頂點往上（或往下）推
	world_xz = world.xz;
}


void fragment() {
	// height 是 vertex() 算好的；頂點之間的像素會拿到混合過的數值
	float t = clamp(height / 3.5 + 0.5, 0.0, 1.0);
	ALBEDO = mix(deep_color, crest_color, t);        // 浪越高，顏色越亮
	ROUGHNESS = roughness;
	// 細小的波紋：用世界座標鋪貼圖，海面怎麼移動，波紋都不會跟著跑
	NORMAL_MAP = texture(ripple_texture, world_xz / ripple_size + ripple_flow * TIME).rgb;
}
