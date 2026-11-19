@tool
extends Node3D
## 第 6 集小教室：光照與陰影實驗室。
## 選取這個節點，在屬性檢視器拉數字，太陽和影子會馬上變化（@tool：在編輯器裡也會執行）。

## 太陽的高度（度）：90 是正中午，從正上方照；越小越接近日落
@export_range(1.0, 90.0, 0.5) var sun_height := 35.0:
	set(v):
		sun_height = v
		_apply()
## 太陽從哪個方向來（度）：0 到 360 繞一圈
@export_range(0.0, 360.0, 1.0) var sun_direction := 150.0:
	set(v):
		sun_direction = v
		_apply()
## 光有多亮
@export_range(0.0, 4.0, 0.05) var energy := 1.0:
	set(v):
		energy = v
		_apply()
## 光的顏色
@export var color := Color.WHITE:
	set(v):
		color = v
		_apply()
## 要不要產生影子
@export var shadows := true:
	set(v):
		shadows = v
		_apply()
## 自動跑一天：太陽從日出走到日落，顏色也跟著變（會改掉上面的高度和顏色）
@export var auto_day := false
## 一天跑幾秒
@export_range(4.0, 60.0, 1.0) var day_seconds := 12.0

var _day := 0.0


func _ready() -> void:
	_apply()


func _process(delta: float) -> void:
	if not auto_day:
		return
	_day = fmod(_day + delta / day_seconds, 1.0)
	# 太陽沿著半圓走：日出（低）→ 正午（高）→ 日落（低）
	var h := sin(_day * PI)
	sun_height = lerpf(3.0, 75.0, h)
	# 太陽低的時候偏橘，高的時候偏白
	color = Color(1.0, 0.5, 0.25).lerp(Color.WHITE, clampf(h * 1.6, 0.0, 1.0))
	energy = lerpf(0.5, 1.2, h)


## 把上面的數字套到 Sun 節點上。
func _apply() -> void:
	var sun := get_node_or_null("Sun") as DirectionalLight3D
	if sun == null:
		return
	sun.rotation_degrees = Vector3(-sun_height, sun_direction, 0.0)
	sun.light_energy = energy
	sun.light_color = color
	sun.shadow_enabled = shadows
