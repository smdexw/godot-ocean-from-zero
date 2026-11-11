// 範例 8：頂點擺動。vertex() 改變每個頂點的位置（下一集的主角）。
shader_type spatial;

void vertex() {
	VERTEX.y += 0.15 * sin(VERTEX.x * 8.0 + TIME * 3.0);   // 頂點跟著 sin 上下動
}

void fragment() {
	ALBEDO = vec3(1.0, 0.45, 0.1);
}
