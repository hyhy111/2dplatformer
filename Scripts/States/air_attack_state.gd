class_name AirAttackState
extends State

# 复用第一段攻击动画
@export var attack_animation: String = "attack1"
# 空中攻击时的漂移速度 (如果玩家按住前方)
@export var drift_speed: float = 100.0

# 进入空中攻击状态
func enter() -> void:
	# 进入状态时清除水平惯性，垂直速度清零实现瞬间悬停感
	character.velocity = Vector2.ZERO
	character.play_animation(attack_animation)

# 物理更新：处理滞空、位移、落地检测
func physics_update(delta: float) -> void:
	# -----------------------------
	# 1. 滞空逻辑
	# -----------------------------
	# 假设 Player.gd 的 _physics_process 中已经有一行: velocity.y += gravity * delta
	# 为了实现“重力减半”的滞空效果，我们需要在这里施加一个向上的力来抵消一半重力。
	# 公式: (Player重力) - (0.5 * Player重力) = 0.5 * Player重力 (最终效果)
	character.velocity.y -= (character.gravity * 0.5) * delta
	
	# -----------------------------
	# 2. 空中位移逻辑
	# -----------------------------
	var input_axis = Input.get_axis("ui_left", "ui_right")
	
	# 获取当前面朝向 (假设 AnimatedSprite2D.flip_h 为 true 时向左，false 时向右)
	# 注意：如果你的人物逻辑是 scale.x = -1 表示向左，请根据实际情况调整
	var is_facing_left = character.animated_sprite.flip_h
	
	var can_move = false
	
	if input_axis != 0:
		# 判断输入方向是否与面朝向一致
		# 向左输入 (-1) 且 面向左 (true) -> 一致
		# 向右输入 (1)  且 面向右 (false) -> 一致
		if (input_axis < 0 and is_facing_left) or (input_axis > 0 and not is_facing_left):
			can_move = true
	
	if can_move:
		# 如果方向一致，允许缓慢向前漂移
		character.velocity.x = input_axis * drift_speed
	else:
		# 否则（没输入 或 输入反方向），保持水平静止，且绝对禁止转身
		# 在 Player.gd 中通常是根据 velocity.x 来更新 flip_h 的，
		# 只要 velocity.x 为 0，通常就不会触发转身逻辑。
		character.velocity.x = 0
	
	# -----------------------------
	# 3. 落地检测
	# -----------------------------
	# 如果动作没做完就落地了，强制切换到 Idle (或者 LandState)
	if character.is_on_floor():
		transition_requested.emit("idlestate")
		return

# 动画结束时处理状态转换
func on_animation_finished() -> void:
	# 动画结束时的分支判断
	if character.is_on_floor():
		transition_requested.emit("idlestate")
	else:
		transition_requested.emit("fallstate")