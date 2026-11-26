// 第 7 集步驟 A：把 Fresnel 畫成黑白，看看哪裡反射多、哪裡反射少。
shader_type spatial;
render_mode unshaded;   // 不要光照：直接看顏色

uniform vec3 deep_color : source_color = vec3(0.02, 0.13, 0.22);    // 浪谷的顏色
uniform vec3 crest_color : source_color = vec3(0.07, 0.32, 0.42);   // 浪峰的顏色

// 每一個波：x、y 是方向，z 是陡度（0 到 1），w 是波長（公尺）
// 數字填在 ShaderMaterial 的 Shader Parameters → Waves，要和 buoys.gd 一樣
uniform vec4 waves[3];
uniform float gravity = 9.8;                         // 重力：每秒 9.8 公尺
uniform vec2 waves_origin = vec2(0.0, -26.0);       // 浮標方陣的中心（Buoys 節點的位置）
uniform float height_range = 1.4;                   // 浪大概有多高，用來把高度換成顏色
uniform float roughness : hint_range(0.0, 1.0) = 0.05;  // 越小越像鏡子，太陽的亮點越小越亮
uniform float specular : hint_range(0.0, 1.0) = 0.35;   // 反射有多強：0.35 剛好是水（正對著看反射 2%）
uniform sampler2D ripple_texture : hint_normal;     // 細小波紋的法線貼圖
uniform float ripple_size = 20.0;                   // 波紋貼圖每一格幾公尺
uniform vec2 ripple_flow = vec2(0.1, 0.0);          // 波紋每秒滑動幾格
uniform float neighbor_step = 0.1;                  // 算法線時，往旁邊看多遠（公尺）

varying float height;      // 這裡的浪有多高
varying vec2 world_xz;     // 這裡在世界中的位置（公尺）


// 一個 Gerstner 波（和第 5 集一樣）：位置 p 的水，在時間 t 被推到哪裡。
vec3 gerstner(vec4 wave, vec2 p, float t) {
	vec2 d = normalize(wave.xy);
	float k = 6.2831853 / wave.w;
	float c = sqrt(gravity / k);
	float f = k * (dot(d, p) - c * t);
	float a = wave.z / k;
	return vec3(d.x * a * cos(f), a * sin(f), d.y * a * cos(f));
}


// 三個波加起來：位置 p 的水總共被推了多少。
vec3 wave_offset(vec2 p, float t) {
	vec3 offset = vec3(0.0);
	for (int i = 0; i < 3; i++) {
		offset += gerstner(waves[i], p, t);
	}
	return offset;
}


void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz - waves_origin;
	vec3 here = wave_offset(p, TIME);           // 這個頂點被推到哪裡

	// 看看鄰居：往 x 和 z 各走一小步，那裡的水被推到哪裡
	float e = neighbor_step;
	vec3 next_x = vec3(e, 0.0, 0.0) + wave_offset(p + vec2(e, 0.0), TIME);
	vec3 next_z = vec3(0.0, 0.0, e) + wave_offset(p + vec2(0.0, e), TIME);

	// 從這裡指向鄰居的兩個方向，就是水面在這裡的兩個斜面
	vec3 along_x = next_x - here;
	vec3 along_z = next_z - here;

	// 外積：找出同時垂直兩個斜面的方向，就是法線（表面朝向哪裡）
	NORMAL = normalize(cross(along_z, along_x));

	VERTEX += here;
	height = here.y;
	world_xz = world.xz + here.xz;
}


void fragment() {
	// Fresnel：dot(NORMAL, VIEW) 是「表面正對著相機的程度」，1 是正對，0 是貼著看
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fresnel = 0.02 + 0.98 * pow(1.0 - facing, 5.0);   // 水：正對著看反射 2%，貼著看 100%
	ALBEDO = vec3(fresnel);   // 黑色 = 幾乎不反射，白色 = 全部反射
}
