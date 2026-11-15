// 第 5 集：尖尖的浪，Gerstner 波。
// 水除了上下，還會前後移動，每一點都在畫圓；點在浪峰擠在一起，浪峰就變尖了。
shader_type spatial;

uniform vec3 deep_color : source_color = vec3(0.02, 0.13, 0.22);    // 浪谷的顏色
uniform vec3 crest_color : source_color = vec3(0.07, 0.32, 0.42);   // 浪峰的顏色

// 每一個波用一個 vec4 表示：x、y 是方向，z 是陡度（0 到 1），w 是波長（公尺）
// uniform 陣列不能在這裡寫預設值，數字填在 ShaderMaterial 的 Shader Parameters → Waves
// 要和 buoys.gd 裡的 waves 一模一樣，浮標才會浮在浪上
uniform vec4 waves[3];
uniform float gravity = 9.8;                         // 重力：每秒 9.8 公尺（Godot 的 1 = 1 公尺）
uniform vec2 waves_origin = vec2(0.0, -26.0);       // 浮標方陣的中心（Buoys 節點的位置）
uniform float height_range = 1.4;                   // 浪大概有多高，用來把高度換成顏色
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D ripple_texture : hint_normal;     // 細小波紋的法線貼圖
uniform float ripple_size = 20.0;                   // 波紋貼圖每一格幾公尺
uniform vec2 ripple_flow = vec2(0.1, 0.0);          // 波紋每秒滑動幾格

varying float height;      // 這裡的浪有多高（vertex() 算好交給 fragment()）
varying vec2 world_xz;     // 這裡在世界中的位置（公尺）


// 一個 Gerstner 波：算出位置 p 的水，在時間 t 被推到哪裡（x、y、z 三個方向的位移）。
vec3 gerstner(vec4 wave, vec2 p, float t) {
	vec2 d = normalize(wave.xy);             // 方向：把長度變成 1
	float k = 6.2831853 / wave.w;             // 波數：2π ÷ 波長
	float c = sqrt(gravity / k);              // 速度：深水波的公式，波越長跑越快
	float f = k * (dot(d, p) - c * t);        // 這一點在波上的位置（沿著方向走了多遠）
	float a = wave.z / k;                     // 振幅：陡度 ÷ 波數
	// cos 推前後、sin 推上下：每一點都在畫圓
	return vec3(d.x * a * cos(f), a * sin(f), d.y * a * cos(f));
}


void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz - waves_origin;        // 和浮標從同一個點開始量

	// 三個波的位移加起來
	vec3 offset = vec3(0.0);
	for (int i = 0; i < 3; i++) {
		offset += gerstner(waves[i], p, TIME);
	}

	VERTEX += offset;                        // 前後、上下都推
	height = offset.y;
	world_xz = world.xz + offset.xz;
}


void fragment() {
	float t = clamp(height / (2.0 * height_range) + 0.5, 0.0, 1.0);
	ALBEDO = mix(deep_color, crest_color, t);        // 浪越高，顏色越亮
	ROUGHNESS = roughness;
	NORMAL_MAP = texture(ripple_texture, world_xz / ripple_size + ripple_flow * TIME).rgb;
}
