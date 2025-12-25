extends State
class_name SprintState

@export var max_sprint_speed: float = 500.0
@export var duration_in: float = 0.2
@export var duration_hold: float = 0.3
@export var duration_out: float = 0.2

# 开关：是否使用匀速冲刺
@export var use_constant_speed: bool = false

var current_speed: float = 0.0
var direction: float = 0.0
var tween: Tween
var default_gravity: float

func enter() -> void:
	super.enter()
	character.start_afterimage_effect()
	
	# 记录并禁用重力
	default_gravity = character.gravity
	character.gravity = 0
	character.velocity.y = 0 # 消除垂直速度
	
	# 确定冲刺方向 (优先输入，其次当前速度，最后朝向)
	var input = character.get_move_input()
	if input != 0:
		direction = sign(input)
	elif character.velocity.x != 0:
		direction = sign(character.velocity.x)
	else:
		direction = -1.0 if anim_sprite.flip_h else 1.0
	
	# 强制朝向
	anim_sprite.flip_h = (direction < 0)
	
	# 动画设置
	anim_sprite.play("sprint")
	anim_sprite.pause() # 暂停动画，由 Tween 控制帧
	anim_sprite.frame = 0
	
	# 根据开关选择模式
	if use_constant_speed:
		start_constant_sprint()
	else:
		start_variable_sprint()

func physics_update(_delta: float) -> void:
	# 应用速度
	character.velocity.x = current_speed * direction

func exit() -> void:
	character.stop_afterimage_effect()
	# 恢复重力
	character.gravity = default_gravity
	
	if tween:
		tween.kill()
	# 恢复动画播放，以免影响后续状态
	anim_sprite.play()

func _on_tween_finished() -> void:
	if character.is_on_floor():
		transition_requested.emit("idlestate")
	else:
		transition_requested.emit("fallstate")

# --- 模式 1: 变速冲刺 (Ease In - Hold - Ease Out) ---
func start_variable_sprint() -> void:
	current_speed = 0.0
	tween = create_tween()
	
	# Phase 1: Ease In (0 -> max)
	tween.tween_property(self, "current_speed", max_sprint_speed, duration_in) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	# Phase 2: Hold (保持 max)
	tween.tween_interval(duration_hold)
	
	# Phase 3: Ease Out (max -> 0) & 视觉同步 (Frame 1 -> 2)
	if character.is_on_floor():
		# 地面冲刺：执行减速和播放最后两帧
		tween.tween_callback(func(): anim_sprite.frame = 1)
		
		# 并行执行减速和帧变化
		tween.parallel().tween_property(self, "current_speed", 0.0, duration_out) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
		tween.parallel().tween_property(anim_sprite, "frame", 2, duration_out)
	
	# 空中冲刺：不需要 Ease Out，直接结束 (保持 Hold 结束时的速度)
	
	tween.finished.connect(_on_tween_finished)

# --- 模式 2: 匀速冲刺 (Constant Speed) ---
func start_constant_sprint() -> void:
	# 速度全程保持最大
	current_speed = max_sprint_speed
	
	tween = create_tween()
	
	# Phase 1 & 2: 等待前两个阶段的时间
	tween.tween_interval(duration_in + duration_hold)
	
	# Phase 3: 仅处理视觉同步 (Frame 1 -> 2)，速度保持不变
	if character.is_on_floor():
		# 地面冲刺：播放最后两帧
		tween.tween_callback(func(): anim_sprite.frame = 1)
		# 播放最后两帧的动画
		tween.tween_property(anim_sprite, "frame", 2, duration_out)
	
	# 空中冲刺：不需要 Ease Out 阶段，直接结束
	
	tween.finished.connect(_on_tween_finished)
