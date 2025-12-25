# 跳跃状态
extends State

# 进入跳跃状态
func enter():
	character.play_animation("jump")
	character.velocity.y = character.jump_velocity

# 物理更新：空中控制，检查下落和攻击
func physics_update(_delta: float):
	# 空中控制
	var direction = character.get_move_input()
	if direction != 0:
		character.velocity.x = direction * character.speed
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, character.speed)

	if Input.is_action_just_pressed("sprint"):
		transition_requested.emit("sprintstate")
		return

	# 当速度变为正值（下落）时转换到下落状态
	if character.velocity.y > 0:
		transition_requested.emit("fallstate")
		return

	# 检查攻击输入
	if character.is_attack_input():
		character.consume_attack_input()
		transition_requested.emit("attackstate")
