# 空闲状态
extends State

# 进入空闲状态
func enter():
	character.play_animation("idle")

# 物理更新：应用摩擦力，检查状态转换
func physics_update(_delta: float):
	# 应用摩擦力
	character.velocity.x = move_toward(character.velocity.x, 0, character.speed)

	# 检查状态转换
	if not character.is_on_floor():
		transition_requested.emit("fallstate")
		return

	if character.is_jump_input():
		transition_requested.emit("jumpstate")
	elif character.get_move_input() != 0:
		transition_requested.emit("walkstate")
	elif character.is_attack_input():
		character.consume_attack_input()
		transition_requested.emit("attackstate")