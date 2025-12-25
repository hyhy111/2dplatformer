# afterimage.gd
class_name Afterimage
extends AnimatedSprite2D

# 这里的逻辑不需要任何改动，因为它是纯逻辑
signal repool_me(instance: Afterimage)

func initialize(
	p_sprite_frames: SpriteFrames,
	p_animation: StringName,
	p_frame: int,
	p_transform: Transform2D,
	p_flip_h: bool,
	p_color: Color,
	p_duration: float,
	p_final_scale: float
) -> void:
	# 1. 应用视觉状态
	self.sprite_frames = p_sprite_frames
	self.animation = p_animation
	self.frame = p_frame
	self.global_transform = p_transform
	self.flip_h = p_flip_h
	self.modulate = p_color
	
	# 2. 激活显示
	visible = true
	
	# 3. 创建 Tween 动画
	# 注意：对于对象池对象，每次都要新建 Tween，因为之前的可能已经被 kill 或 finish
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, p_duration)
	tween.tween_property(self, "scale", self.scale * p_final_scale, p_duration)
	
	# 4. 完成后回收
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	visible = false
	# 通知组件回收我
	repool_me.emit(self)
