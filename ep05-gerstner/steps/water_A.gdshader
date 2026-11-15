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


void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz - waves_origin;
	float k = 6.2831853 / 16.0;         // 波數：波長 16 公尺
	float a = 0.6 / k;                  // 振幅
	float f = k * (p.x - 5.0 * TIME);    // 每秒往前 5 公尺
	VERTEX.x += a * cos(f);              // 前後
	VERTEX.y += a * sin(f);              // 上下
	height = a * sin(f);
	world_xz = world.xz;
}


void fragment() {
	float t = clamp(height / (2.0 * height_range) + 0.5, 0.0, 1.0);
	ALBEDO = mix(deep_color, crest_color, t);        // 浪越高，顏色越亮
	ROUGHNESS = roughness;
	NORMAL_MAP = texture(ripple_texture, world_xz / ripple_size + ripple_flow * TIME).rgb;
}
