extends Node3D
## 第 2 集加碼：造浪實驗室。
## 同一片浮標，換不同的造浪方法；再用線段把波形連起來，看清楚浪的形狀。

enum WaveMode { SINE, SHARP, GERSTNER, NOISE, RIPPLE }

@export var mode := WaveMode.SINE   # 造浪方法
@export var show_buoys := true       # 顯示浮標
@export var show_lines := true       # 用線段畫出波形
@export var grid_lines := false      # 也畫直向的線，變成一張網（第 0 集的樣子）
@export_range(2, 200) var line_samples := 80   # 每條線用幾個點（越多越平滑）
@export var line_color := Color(1.0, 0.85, 0.25)
@export var buoy_color := Color(1.0, 0.45, 0.1)
@export var buoy_size := 0.35
@export var grid_size := 20
@export var spacing := 2.0
@export var amplitude := 1.0
@export var wavelength := 16.0
@export var speed := 4.0

var buoys := []                      # 每顆浮標和它原本的位置
var time := 0.0
var noise := FastNoiseLite.new()
var line_mesh := ImmediateMesh.new()
var line_material := StandardMaterial3D.new()


func _ready() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = buoy_size
	mesh.height = buoy_size * 2.0
	var material := StandardMaterial3D.new()
	material.albedo_color = buoy_color
	mesh.material = material

	var half := (grid_size - 1) * spacing / 2.0
	for i in grid_size:
		for j in grid_size:
			var buoy := MeshInstance3D.new()
			buoy.mesh = mesh
			var rest := Vector3(i * spacing - half, 0.0, j * spacing - half)
			buoy.position = rest
			add_child(buoy)
			buoys.append({"node": buoy, "rest": rest})

	# 雜訊：一種「平滑的亂數」，相鄰的點數值接近
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.06

	# 線段用不受光照影響的亮黃色，而且不會被海面擋住
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line_material.albedo_color = line_color
	line_material.no_depth_test = true
	line_material.render_priority = 1
	var lines := MeshInstance3D.new()
	lines.mesh = line_mesh
	add_child(lines)


func _process(delta: float) -> void:
	time += delta
	for b in buoys:
		b.node.visible = show_buoys
		b.node.position = b.rest + displacement(b.rest.x, b.rest.z, time)
	draw_lines()


## 每一排浮標各畫一條線：在這排上取 line_samples 個點，相鄰的點用線段連起來。
## grid_lines 打開時，直的方向也畫，就變成第 0 集那張會動的網子。
func draw_lines() -> void:
	line_mesh.clear_surfaces()
	if not show_lines:
		return
	var half := (grid_size - 1) * spacing / 2.0
	for j in grid_size:
		var z := j * spacing - half
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, line_material)
		for s in line_samples:
			var x := lerpf(-half, half, float(s) / (line_samples - 1))
			line_mesh.surface_add_vertex(Vector3(x, 0.0, z) + displacement(x, z, time))
		line_mesh.surface_end()
	if not grid_lines:
		return
	for i in grid_size:
		var x := i * spacing - half
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, line_material)
		for s in line_samples:
			var z := lerpf(-half, half, float(s) / (line_samples - 1))
			line_mesh.surface_add_vertex(Vector3(x, 0.0, z) + displacement(x, z, time))
		line_mesh.surface_end()


## 依照目前的造浪方法，算出位置 (x, z) 在時間 t 的位移。
func displacement(x: float, z: float, t: float) -> Vector3:
	var k := TAU / wavelength
	match mode:
		WaveMode.SINE:
			# 三個 sin 波加起來（主教學的方法）
			var h := amplitude * sin(k * (x - speed * t))
			h += amplitude * 0.5 * sin(k / 0.6 * (x * 0.6 + z * 0.8 - speed * 0.8 * t))
			h += amplitude * 0.25 * sin(k / 0.35 * (z * 0.9 - x * 0.4 - speed * 1.2 * t))
			return Vector3(0.0, h, 0.0)
		WaveMode.SHARP:
			# 把 sin 先換到 0～1，再取次方：浪峰變尖、浪谷變平
			var s := 0.5 + 0.5 * sin(k * (x - speed * t))
			return Vector3(0.0, amplitude * (2.0 * pow(s, 3.0) - 0.5), 0.0)
		WaveMode.GERSTNER:
			# Gerstner 波：水除了上下，也會前後移動，每個點在畫圓
			var phase := k * (x - speed * t)
			var steepness := 0.7
			return Vector3(-steepness / k * sin(phase), amplitude * cos(phase), 0.0)
		WaveMode.NOISE:
			# 雜訊：把時間當成第三個座標，雜訊就會慢慢變化
			return Vector3(0.0, amplitude * 2.0 * noise.get_noise_3d(x, z, t * 8.0), 0.0)
		WaveMode.RIPPLE:
			# 圓形漣漪：從中心往外擴散，離中心越遠越小
			var d := sqrt(x * x + z * z)
			var h := amplitude * 1.5 * sin(k * 1.5 * (d - speed * t)) * exp(-d * 0.05)
			return Vector3(0.0, h, 0.0)
	return Vector3.ZERO
