# 下落状态
extends State

# 落地缓冲时的移动速度（通常比正常走跑慢）
@export var landing_drift_speed: float = 50.0

# 用来标记是否进入了“落地缓冲”阶段
var is_landing: bool = false

# 进入下落状态
func enter():
	is_landing = false
	character.play_animation("fall")
	
	# --- 核心 1: 暂停在第一帧 ---
	anim_sprite.pause()
	anim_sprite.frame = 0

# 物理更新：处理重力、位移、落地
func physics_update(delta: float):
	# 1. 记得施加重力 (无论是否在 landing 状态都需要重力，防止悬空)
	character.velocity.y += 980.0 * delta

	# --- 修改重点: 落地缓冲期间的位移控制 ---
	if is_landing:
		var direction = character.get_move_input()
		
		# 获取当前面朝向 (假设 flip_h = true 为向左)
		var is_facing_left = anim_sprite.flip_h
		var can_move = false
		
		# 判断输入方向是否与面朝向一致
		if direction != 0:
			if (direction < 0 and is_facing_left) or (direction > 0 and not is_facing_left):
				can_move = true
		
		if can_move:
			# 如果方向一致，允许缓慢位移
			character.velocity.x = direction * landing_drift_speed
		else:
			# 如果没输入，或者输入了反方向（为了禁止转身），则施加摩擦力减速
			character.velocity.x = move_toward(character.velocity.x, 0, character.speed * 0.1)
			
		return # 落地阶段结束，不再执行下面的空中逻辑

	# --- 正常的空中逻辑 (未落地时) ---

	if Input.is_action_just_pressed("sprint"):
		transition_requested.emit("sprintstate")
		return

	# 2. 空中控制
	var direction = character.get_move_input()
	if direction != 0:
		character.velocity.x = direction * character.speed
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, character.speed)
	
	# 3. 落地检测
	if character.is_on_floor():
		start_landing_sequence() # 触发落地逻辑
		return

	# 4. 攻击检测
	if character.is_attack_input():
		character.consume_attack_input()
		transition_requested.emit("attackstate")

# 触发落地序列
func start_landing_sequence():
	is_landing = true
	
	var total_frames = anim_sprite.sprite_frames.get_frame_count("fall")

	if total_frames >= 2:
		# 跳转到倒数第2帧
		anim_sprite.frame = total_frames - 2

	# 恢复播放
	anim_sprite.play()

# 动画结束时切换状态
func on_animation_finished():
	if is_landing:
		# 落地动画播完了，根据此时的按键决定是切 Walk 还是 Idle
		var direction = character.get_move_input()
		if direction != 0:
			transition_requested.emit("walkstate")
		else:
			transition_requested.emit("idlestate")