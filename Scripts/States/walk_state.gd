# 行走状态
extends State

# 进入行走状态
func enter():
	character.play_animation("walk")
	character.start_afterimage_effect()

# 物理更新：处理移动和状态转换
func physics_update(_delta: float):
	if not character.is_on_floor():
		transition_requested.emit("fallstate")
		return

	if character.is_jump_input():
		transition_requested.emit("jumpstate")
		return

	var direction = character.get_move_input()
	
	if direction != 0:
		# 设置移动速度
		character.velocity.x = direction * character.speed
	else:
		# 无输入，切换到空闲
		transition_requested.emit("idlestate")
		return

	# 检查攻击输入
	if character.is_attack_input():
		character.consume_attack_input()
		transition_requested.emit("attackstate")

# 退出行走状态
func exit():
	# 退出行走状态时停止残影效果
	character.stop_afterimage_effect()