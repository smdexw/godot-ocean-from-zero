# 零基礎做遊戲海洋：範例專案

YouTube 教學系列「零基礎做遊戲海洋」每一集的 Godot 範例專案。每集一個資料夾，每個資料夾都是一個可以直接打開的 Godot 專案。

![第 1 集成果：波紋流動的海](images/ep01-preview.gif)

## 怎麼使用

1. 下載這個 repo：按右上角綠色的 **Code** → **Download ZIP**，解壓縮。
2. 打開 Godot 4.7 以上（標準版），在專案管理員按「**匯入**」。
3. 選你要的那一集資料夾裡的 `project.godot`，例如 `ep01-first-sea/project.godot`。
4. 打開後按 **F5** 執行。

需要 Godot 4.7 以上，渲染器使用 Forward+（需要支援 Vulkan 的顯示卡）。

## 各集範例

| 集 | 資料夾 | 內容 | 影片 | 文章 |
| --- | --- | --- | --- | --- |
| 0 | — | 總覽：遊戲裡的海是怎麼做出來的（沒有範例專案） | [YouTube](https://www.youtube.com/watch?v=GWMWLkf4mzU) | [部落格](https://dev-mojo.blogspot.com/2026/11/godot-crest.html) |
| 1 | [ep01-first-sea](ep01-first-sea/) | 裝好 Godot，不寫程式，搭出第一片會動的海：天空、太陽、海面材質、法線貼圖、AnimationPlayer | 即將推出 | 即將推出 |

## 第 1 集：搭出第一片海

只用 Godot 內建功能，沒有任何程式碼。場景 `my_ocean.tscn` 裡有五個節點：

| 節點 | 用途 | 主要設定 |
| --- | --- | --- |
| WorldEnvironment | 天空、霧、色調 | ProceduralSkyMaterial；霧 Density 0.0012、Sky Affect 0；Tonemap Filmic |
| Sun（DirectionalLight3D） | 太陽 | Rotation X -30°、Y 150° |
| Sea（MeshInstance3D） | 海面 | PlaneMesh 2000 × 2000；StandardMaterial3D：顏色 #0b3954、Roughness 0.05、NoiseTexture2D 法線貼圖、UV1 Scale 100 |
| Camera3D | 相機 | 位置 Y 5、往下 4°、Far 10000 |
| AnimationPlayer | 讓波紋流動 | 動畫 `flow`：10 秒循環，材質 UV1 Offset 從 (0, 0, 0) 到 (1, 0, 0) |

## 授權

範例專案以 MIT 授權釋出，可以自由使用、修改，也可以用在你自己的遊戲裡。
