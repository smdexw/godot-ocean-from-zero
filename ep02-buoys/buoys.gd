extends Node3D
## 第 2 集：用 400 顆浮標排出一片會起伏的海。

@export var grid_size := 20      # 每一邊幾顆浮標
@export var spacing := 2.0       # 浮標之間的距離（公尺）
@export var amplitude := 1.0     # 振幅：浪有多高
@export var wavelength := 16.0   # 波長：一個浪有多長
@export var speed := 4.0         # 速度：浪每秒前進幾公尺

var buoys := []                  # 用來記住所有浮標
var time := 0.0                  # 經過了幾秒


func _ready() -> void:
	# 做一顆橘色的球，所有浮標共用
	var mesh := SphereMesh.new()
	mesh.radius = 0.35
	mesh.height = 0.7
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.45, 0.1)
	mesh.material = material

	# 排成 20 × 20 的方陣，中心在這個節點的位置
	var half := (grid_size - 1) * spacing / 2.0
	for i in grid_size:
		for j in grid_size:
			var buoy := MeshInstance3D.new()
			buoy.mesh = mesh
			buoy.position = Vector3(i * spacing - half, 0.0, j * spacing - half)
			add_child(buoy)
			buoys.append(buoy)


func _process(delta: float) -> void:
	time += delta
	for buoy in buoys:
		buoy.position.y = wave_height(buoy.position.x, buoy.position.z, time)


## 一個 sin 波。d 是沿著浪前進方向的距離。
func sine_wave(d: float, t: float, a: float, length: float, v: float) -> float:
	return a * sin(TAU / length * (d - v * t))


## 把三個方向、大小都不同的波加起來，就比較像真的海。
func wave_height(x: float, z: float, t: float) -> float:
	var h := 0.0
	h += sine_wave(x, t, amplitude, wavelength, speed)
	h += sine_wave(x * 0.6 + z * 0.8, t, amplitude * 0.5, wavelength * 0.6, speed * 0.8)
	h += sine_wave(z * 0.9 - x * 0.4, t, amplitude * 0.25, wavelength * 0.35, speed * 1.2)
	return h
