@tool
extends Node3D
## 第 7 集小教室：反射實驗室。
## 選取這個節點，在屬性檢視器改數字，天空、太陽和海面的反射會馬上變化（@tool：在編輯器裡也會執行）。
## 前面兩排球：上排是一般材質（Metallic 0），下排是金屬（Metallic 1），Roughness 從左到右是 0 到 1。

## 天空正上方的顏色
@export var sky_top := Color(0.22, 0.42, 0.72):
	set(v):
		sky_top = v
		_apply()
## 地平線的顏色：遠處的海反射的就是這個顏色
@export var sky_horizon := Color(0.72, 0.8, 0.88):
	set(v):
		sky_horizon = v
		_apply()
## 太陽的高度（度）
@export_range(1.0, 90.0, 0.5) var sun_height := 30.0:
	set(v):
		sun_height = v
		_apply()
## 海面的粗糙度：0 像鏡子，越大反射越模糊
@export_range(0.0, 1.0, 0.01) var sea_roughness := 0.05:
	set(v):
		sea_roughness = v
		_apply()
## 海面反射有多強：0.35 剛好是水，0 完全不反射
@export_range(0.0, 1.0, 0.01) var sea_specular := 0.35:
	set(v):
		sea_specular = v
		_apply()


func _ready() -> void:
	_apply()


## 把上面的數字套到天空、太陽和海面的材質上。
func _apply() -> void:
	var env_node := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if env_node and env_node.environment and env_node.environment.sky:
		var sky := env_node.environment.sky.sky_material as ProceduralSkyMaterial
		if sky:
			sky.sky_top_color = sky_top
			sky.sky_horizon_color = sky_horizon
			sky.ground_horizon_color = sky_horizon
	var sun := get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.rotation_degrees.x = -sun_height
	var sea := get_node_or_null("Sea") as MeshInstance3D
	if sea and sea.material_override is ShaderMaterial:
		var mat := sea.material_override as ShaderMaterial
		mat.set_shader_parameter("roughness", sea_roughness)
		mat.set_shader_parameter("specular", sea_specular)
