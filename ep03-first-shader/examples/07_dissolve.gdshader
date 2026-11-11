// 範例 7：溶解消失。雜訊比門檻小的像素就丟掉。
shader_type spatial;

uniform sampler2D noise_texture;   // 一張普通的雜訊貼圖

void fragment() {
	float n = texture(noise_texture, UV).r;           // 讀這個位置的雜訊（0 到 1）
	float cut = 0.15 + 0.35 * (0.5 + 0.5 * sin(TIME)); // 門檻隨時間上下
	if (n < cut) {
		discard;                                       // 丟掉這個像素，變成透明的洞
	}
	float edge = smoothstep(cut, cut + 0.06, n);       // 洞的邊緣附近接近 0
	ALBEDO = mix(vec3(1.0, 0.5, 0.1), vec3(0.85), edge);
	EMISSION = vec3(1.0, 0.4, 0.0) * (1.0 - edge) * 4.0;  // 邊緣燒紅
}
