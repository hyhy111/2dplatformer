# 地面攻击状态类
class_name GroundAttackState
extends State

@export var combo_animations: Array[String] = ["attack1", "attack2", "attack3"] # 连招动画列表
@export var lunge_speeds: Array[float] = [50.0, 30.0, 80.0] # 冲刺速度列表

var current_combo_index: int = 0 # 当前连招索引
var input_buffered: bool = false # 是否缓冲输入

# 进入地面攻击状态
func enter() -> void:
	current_combo_index = 0
	input_buffered = false
	_play_attack(current_combo_index)

# 物理更新：处理冲刺和输入缓冲
func physics_update(_delta: float) -> void:
	# 允许微量移动 (Lunge)
	if current_combo_index < lunge_speeds.size():
		var direction = -1 if character.animated_sprite.flip_h else 1
		character.velocity.x = lunge_speeds[current_combo_index] * direction
	else:
		character.velocity.x = 0
	
	# 输入缓冲检测
	if character.is_attack_input():
		input_buffered = true
		character.consume_attack_input()

# 动画结束时处理连招或结束
func on_animation_finished() -> void:
	if input_buffered and current_combo_index < combo_animations.size() - 1:
		# 连招逻辑：有缓冲且未到最后一段 -> 播放下一段
		current_combo_index += 1
		input_buffered = false
		_play_attack(current_combo_index)
	else:
		# 结束逻辑：无缓冲或已是最后一段 -> 回到 Idle
		transition_requested.emit("idlestate")

# 播放指定索引的攻击动画
func _play_attack(index: int) -> void:
	if index >= 0 and index < combo_animations.size():
		character.play_animation(combo_animations[index])
