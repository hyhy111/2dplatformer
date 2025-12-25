# afterimage_component.gd
# 拖影效果组件 - 可复用的自包含组件
class_name AfterimageComponent
extends Node2D

#region --- 导出参数 ---
@export_group("Afterimage Effect")

## 全局启用或禁用拖影效果
@export var enabled: bool = true

## 目标 AnimatedSprite2D 的路径（相对于父节点）
@export var sprite_path: NodePath

## 拖影的颜色和初始透明度
@export var color: Color = Color(1, 1, 1, 0.7)

## 生成每个拖影之间的时间间隔（秒）。数值越小，拖影越密集
@export var interval: float = 0.05

## 单个拖影从出现到完全消失所需的时间（秒）
@export var duration: float = 0.4

## 拖影消失时最终缩放的大小倍率
## 1.0 = 不缩放, 0.5 = 缩小到一半, 0.0 = 完全缩小至消失
@export var final_scale: float = 0.5

## 对象池大小，预创建的拖影对象数量
@export var pool_size: int = 25

## 拖影容器的 Z Index，用于控制渲染顺序。默认为 -1，确保在角色后面。
@export var z_index_value: int = -1

# 添加纹理过滤选项，默认为 Nearest (适合像素游戏)
@export var texture_filter_mode: CanvasItem.TextureFilter = TEXTURE_FILTER_NEAREST
#endregion

# --- 内部节点引用 ---
var _timer: Timer
var _container: Node2D

# --- 缓存的外部引用 ---
var _target_sprite: AnimatedSprite2D
var _owner_node: Node2D # 用于获取 global_transform

# --- 内部状态变量 ---
var _is_active: bool = false
var _pool: Array[Afterimage] = []


func _ready():
	# 创建内部节点
	_setup_internal_nodes()
	
	# 获取目标精灵引用
	_cache_target_sprite()
	
	# 初始化对象池
	_setup_pool()


func _setup_internal_nodes():
	# 创建计时器
	_timer = Timer.new()
	_timer.name = "AfterimageTimer"
	_timer.one_shot = true
	_timer.wait_time = interval
	_timer.timeout.connect(_create_afterimage)
	add_child(_timer)
	
	# 创建容器
	_container = Node2D.new()
	_container.name = "Container"
	# 将容器设为顶层，这样拖影不会跟随角色移动
	_container.top_level = true
	_container.z_index = z_index_value
	_container.texture_filter = texture_filter_mode
	add_child(_container)


func _cache_target_sprite():
	if sprite_path.is_empty():
		push_warning("AfterimageComponent: sprite_path is not set!")
		return
	
	# 获取父节点作为位置参考（用于获取 global_transform）
	_owner_node = get_parent() as Node2D
	if not _owner_node:
		push_warning("AfterimageComponent: Parent node must be Node2D or derived type!")
		return
	
	# 从组件自身出发获取目标精灵（sprite_path 是相对于组件的路径）
	_target_sprite = get_node_or_null(sprite_path) as AnimatedSprite2D
	if not _target_sprite:
		push_warning("AfterimageComponent: Cannot find AnimatedSprite2D at path: " + str(sprite_path))


func _setup_pool():
	if not _container:
		return
	
	for i in pool_size:
		var afterimage = Afterimage.new()

		afterimage.texture_filter = texture_filter_mode
		
		afterimage.name = "Afterimage_%d" % i # 为了调试方便给个名字
		afterimage.visible = false
		
		# 连接回收信号
		afterimage.repool_me.connect(_on_afterimage_repooled)
		
		# 预先添加到容器中
		_container.add_child(afterimage)
		
		# 添加到池中备用
		_pool.append(afterimage)


#region --- 公共方法 ---

## 开始生成拖影效果
func start():
	if not enabled or _is_active:
		return
	
	if not _target_sprite:
		push_warning("AfterimageComponent: Cannot start - target sprite not found!")
		return
	
	_is_active = true
	_create_afterimage() # 立即创建一个，避免延迟
	_timer.start()


## 停止生成拖影效果
func stop():
	_is_active = false
	_timer.stop()


## 检查是否正在生成拖影
func is_active() -> bool:
	return _is_active

#endregion


#region --- 内部方法 ---

func _create_afterimage():
	if not _is_active:
		return
	
	# 从对象池中取出一个拖影
	if _pool.is_empty():
		return # 如果池已用完，则不创建
	
	var afterimage: Afterimage = _pool.pop_front()
	
	# 收集当前状态并调用拖影的初始化函数
	afterimage.initialize(
		_target_sprite.sprite_frames,
		_target_sprite.animation,
		_target_sprite.frame,
		_owner_node.global_transform, # 使用父节点的全局变换
		_target_sprite.flip_h,
		color,
		duration,
		final_scale
	)
	
	# 如果效果仍在持续，再次启动计时器
	if _is_active:
		_timer.start()


func _on_afterimage_repooled(afterimage_instance: Afterimage):
	_pool.append(afterimage_instance)

#endregion
