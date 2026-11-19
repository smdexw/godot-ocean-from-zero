extends Node3D
## 第 5 集的浮標（沒有改）：和 water.gdshader 用同一個 Gerstner 公式、同一組數字。
## 每顆浮標記住自己原本的位置，每一幀算出那裡的水被推到哪裡。

@export var grid_size := 20      # 每一邊幾顆浮標
@export var spacing := 2.0       # 浮標之間的距離（公尺）
@export var gravity := 9.8       # 重力（公尺 / 秒²）
## 每一個波：x、y 是方向，z 是陡度（0 到 1），w 是波長（公尺）。要和 shader 的 waves 一樣。
@export var waves: Array[Vector4] = [
	Vector4(1.0, 0.0, 0.35, 16.0),
	Vector4(0.6, 0.8, 0.25, 9.6),
	Vector4(-0.4, 0.9, 0.15, 5.6),
]

var buoys := []                  # 每顆浮標和它原本的位置
var time := 0.0


func _ready() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.35
	mesh.height = 0.7
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.45, 0.1)
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


func _process(delta: float) -> void:
	time += delta
	for b in buoys:
		var p := Vector2(b.rest.x, b.rest.z)
		var offset := Vector3.ZERO
		for wave in waves:
			offset += gerstner(wave, p, time)
		b.node.position = b.rest + offset


## 一個 Gerstner 波：位置 p 的水，在時間 t 被推到哪裡。和 shader 的 gerstner() 一模一樣。
func gerstner(wave: Vector4, p: Vector2, t: float) -> Vector3:
	var d := Vector2(wave.x, wave.y).normalized()   # 方向：長度變成 1
	var k := TAU / wave.w                           # 波數
	var c := sqrt(gravity / k)                      # 速度：深水波的公式
	var f := k * (d.dot(p) - c * t)                 # 沿著方向走了多遠
	var a := wave.z / k                             # 振幅
	return Vector3(d.x * a * cos(f), a * sin(f), d.y * a * cos(f))
