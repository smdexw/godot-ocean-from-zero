// 範例 4：棋盤格。用數學畫出圖案。
shader_type spatial;

uniform float tiles = 8.0;   // 每一邊幾格

void fragment() {
	vec2 cell = floor(UV * tiles);           // 這個像素在第幾格（整數）
	float c = mod(cell.x + cell.y, 2.0);     // 格子編號相加，除以 2 的餘數：0 或 1
	ALBEDO = mix(vec3(0.1), vec3(0.9), c);   // 0 是深色、1 是淺色
}
