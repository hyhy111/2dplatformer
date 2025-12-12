# 状态管理类
class_name StateMachine
extends Node

@export var initial_state: State # 初始状态

var current_state: State # 当前状态
var states: Dictionary = {} # 状态字典

# 准备函数
func _ready():
	# 等待所有者（玩家）准备就绪
	await get_tree().process_frame
	
	var character = get_parent() as CharacterBody2D
	if not character:
		push_warning("StateMachine: Parent is not a CharacterBody2D")
		return
		
	var anim_sprite = character.get_node_or_null("AnimatedSprite2D")
	if not anim_sprite:
		push_warning("StateMachine: AnimatedSprite2D not found on parent")

	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition_requested.connect(on_child_transition)
			child.initialize(character, anim_sprite)
	
	if initial_state:
		change_state(initial_state.name.to_lower())
	elif not states.is_empty():
		# 如果未设置初始状态，则回退到找到的第一个状态
		change_state(states.keys()[0])

# 处理更新
func _process(delta):
	if current_state:
		current_state.process_update(delta)

# 物理处理
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

# 子状态转换处理
func on_child_transition(new_state_name: String):
	change_state(new_state_name)

# 改变状态
func change_state(new_state_name: String):
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_warning("StateMachine: State not found - " + new_state_name)
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

# 动画结束处理
func on_animation_finished():
	if current_state:
		current_state.on_animation_finished()
