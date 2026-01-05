# afterimag.gd
class_name Afterimage
extends Sprite2D

signal repool_me(instance: Afterimage)

var _tween: Tween

# 初始化函数：接收所有视觉参数
func setup(
	p_texture: Texture2D,
	p_transform: Transform2D,
	p_hframes: int,
	p_vframes: int,
	p_frame: int,
	p_offset: Vector2,
	p_centered: bool,
	p_flip_h: bool,
	p_flip_v: bool,
	p_color: Color,
	p_duration: float,
	p_final_scale: float
) -> void:
	# 1. 清理旧状态 (防止对象池复用时的残留 Tween)
	if _tween and _tween.is_valid():
		_tween.kill()
	
	# 2. 应用视觉属性
	texture = p_texture
	global_transform = p_transform
	hframes = p_hframes
	vframes = p_vframes
	frame = p_frame
	offset = p_offset
	centered = p_centered
	flip_h = p_flip_h
	flip_v = p_flip_v
	modulate = p_color # 重置颜色和透明度
	
	visible = true
	
	# 3. 创建动画 (并行执行透明度和缩放)
	_tween = create_tween()
	_tween.set_parallel(true)
	
	# 透明度归零
	_tween.tween_property(self, "modulate:a", 0.0, p_duration)
	# 缩放变化
	_tween.tween_property(self, "scale", scale * p_final_scale, p_duration)
	
	# 4. 结束回调
	_tween.set_parallel(false)
	_tween.finished.connect(_on_finished)

func _on_finished() -> void:
	visible = false
	repool_me.emit(self)