# afterimage.gd
class_name Afterimage
extends AnimatedSprite2D

# 当拖影完成生命周期时，发出此信号，通知Player脚本回收自己
signal repool_me(afterimage_instance)

# 接收所有必要的参数来初始化自己
func initialize(
    p_sprite_frames: SpriteFrames,
    p_animation: StringName,
    p_frame: int,
    p_transform: Transform2D,
    p_flip_h: bool,
    p_color: Color,
    p_duration: float,
    p_final_scale: float
    ):
    # 1. 立即应用所有视觉状态
    self.sprite_frames = p_sprite_frames
    self.animation = p_animation
    self.frame = p_frame
    self.global_transform = p_transform
    self.flip_h = p_flip_h
    self.modulate = p_color
    
    # 2. 激活并显示自己
    visible = true
    
    # 3. 创建并启动淡出和缩小动画
    var tween = create_tween().set_parallel()
    tween.tween_property(self, "modulate:a", 0.0, p_duration)
    tween.tween_property(self, "scale", self.scale * p_final_scale, p_duration)
    
    # 4. 动画完成后，隐藏自己并发出回收信号
    tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
    visible = false
    repool_me.emit(self)