# 攻击状态类
class_name AttackState
extends State

@export var ground_attack_state: State # 地面攻击子状态
@export var air_attack_state: State # 空中攻击子状态

var current_sub_state: State # 当前活跃的子状态

func initialize(character: CharacterBody2D, anim_sprite: AnimatedSprite2D) -> void:
	super.initialize(character, anim_sprite)
	# 初始化子状态
	if ground_attack_state:
		ground_attack_state.initialize(character, anim_sprite)
		ground_attack_state.transition_requested.connect(_on_sub_state_transition)
	if air_attack_state:
		air_attack_state.initialize(character, anim_sprite)
		air_attack_state.transition_requested.connect(_on_sub_state_transition)

# 进入攻击状态，根据位置选择子状态
func enter() -> void:
	if character.is_on_floor():
		_change_sub_state(ground_attack_state)
	else:
		_change_sub_state(air_attack_state)

# 退出攻击状态
func exit() -> void:
	if current_sub_state:
		current_sub_state.exit()
	current_sub_state = null

# 处理更新，委托给子状态
func process_update(delta: float) -> void:
	if current_sub_state:
		current_sub_state.process_update(delta)

# 物理更新，委托给子状态
func physics_update(delta: float) -> void:
	if current_sub_state:
		current_sub_state.physics_update(delta)

# 动画结束，委托给子状态
func on_animation_finished() -> void:
	if current_sub_state:
		current_sub_state.on_animation_finished()

# 切换到新的子状态
func _change_sub_state(new_state: State) -> void:
	if current_sub_state:
		current_sub_state.exit()
	
	current_sub_state = new_state
	
	if current_sub_state:
		current_sub_state.enter()

# 处理子状态的转换请求
func _on_sub_state_transition(new_state_name: String) -> void:
	# 将子状态的转换请求转发给主状态机
	transition_requested.emit(new_state_name)