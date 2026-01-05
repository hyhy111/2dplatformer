# afterimage_component.gd
@tool
class_name AfterimageComponent
extends Node2D

#region --- 依赖注入 (Dependency Injection) ---
# 这一部分展示了“组合”的精髓：组件不猜测父节点，而是请求外部赋值。

## 物理目标：拖影跟随哪个物体的位置生成？(通常是 character 根节点)
@export var target_node: Node2D:
	set(value):
		target_node = value
		update_configuration_warnings() # 刷新编辑器警告

## 视觉目标：要复制哪个 Sprite 的样子？(支持 Sprite2D 或 AnimatedSprite2D)
@export var visual_node: Node2D:
	set(value):
		visual_node = value
		update_configuration_warnings()
#endregion

#region --- 参数配置 (Configuration) ---
@export_group("Afterimage Settings")
@export var enabled: bool = true
@export var color: Color = Color(1, 1, 1, 0.7)
@export var interval: float = 0.05
@export var duration: float = 0.4
@export var final_scale: float = 0.5
@export var pool_size: int = 25
@export var z_index_value: int = -1
@export var texture_filter_mode: CanvasItem.TextureFilter = TEXTURE_FILTER_NEAREST
#endregion

# --- 内部变量 ---
var _timer: Timer
var _container: Node2D
var _is_active: bool = false
var _pool: Array[Afterimage] = []

func _ready() -> void:
	# 编辑器模式下不运行逻辑，只做检查
	if Engine.is_editor_hint():
		return
	
	_setup_internal_nodes()
	_setup_pool()

# --- 编辑器配置警告 ---
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if target_node == null:
		warnings.append("⚠️ 缺失 Target Node：请拖入要跟随的父物体 (如 Player)。")
	
	if visual_node == null:
		warnings.append("⚠️ 缺失 Visual Node：请拖入要复制的 Sprite。")
	elif not (visual_node is Sprite2D or visual_node is AnimatedSprite2D):
		warnings.append("⚠️ 类型错误：Visual Node 必须是 Sprite2D 或 AnimatedSprite2D。")
		
	return warnings

# --- 初始化逻辑 ---
func _setup_internal_nodes() -> void:
	# 创建计时器
	_timer = Timer.new()
	_timer.name = "Timer"
	_timer.one_shot = true
	_timer.wait_time = interval
	_timer.timeout.connect(_create_afterimage)
	add_child(_timer)
	
	# 创建容器 (Top Level 确保不随父节点旋转/缩放)
	_container = Node2D.new()
	_container.name = "AfterimageContainer"
	_container.top_level = true
	_container.z_index = z_index_value
	_container.texture_filter = texture_filter_mode
	add_child(_container)

func _setup_pool() -> void:
	for i in pool_size:
		var afterimage = Afterimage.new()
		afterimage.name = "Afterimage_%d" % i
		afterimage.texture_filter = texture_filter_mode # 确保像素清晰
		afterimage.visible = false
		afterimage.repool_me.connect(_on_afterimage_repooled)
		_container.add_child(afterimage)
		_pool.append(afterimage)

# --- 公共 API ---
func start() -> void:
	if not enabled or _is_active: return
	# 运行时再次检查依赖，防止崩溃
	if not target_node or not visual_node: return
	
	_is_active = true
	_create_afterimage() # 立即生成一个
	_timer.start()

func stop() -> void:
	_is_active = false
	_timer.stop()

# --- 核心生成逻辑 ---
func _create_afterimage() -> void:
	if not _is_active or _pool.is_empty(): return
	
	var afterimage = _pool.pop_front()
	
	# [多态处理]：根据不同节点类型提取数据
	var tex: Texture2D
	var h_frames: int = 1
	var v_frames: int = 1
	var current_frame: int = 0
	var offset_val: Vector2 = Vector2.ZERO
	var centered_val: bool = true
	var flip_h_val: bool = false
	var flip_v_val: bool = false
	
	if visual_node is Sprite2D:
		var s = visual_node as Sprite2D
		tex = s.texture
		h_frames = s.hframes
		v_frames = s.vframes
		current_frame = s.frame
		offset_val = s.offset
		centered_val = s.centered
		flip_h_val = s.flip_h
		flip_v_val = s.flip_v
		
	elif visual_node is AnimatedSprite2D:
		var anim = visual_node as AnimatedSprite2D
		# 提取 AnimatedSprite 当前帧的纹理
		if anim.sprite_frames and anim.sprite_frames.has_animation(anim.animation):
			tex = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
		offset_val = anim.offset
		centered_val = anim.centered
		flip_h_val = anim.flip_h
		flip_v_val = anim.flip_v
	
	# 初始化拖影
	afterimage.setup(
		tex,
		target_node.global_transform, # 使用 target_node 的位置
		h_frames, v_frames, current_frame,
		offset_val, centered_val, flip_h_val, flip_v_val,
		color, duration, final_scale
	)
	
	if _is_active:
		_timer.start()

func _on_afterimage_repooled(instance: Afterimage) -> void:
	_pool.append(instance)