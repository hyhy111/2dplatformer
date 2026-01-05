# character.gd
class_name Character
extends CharacterBody2D

@export var death_anim_name: String = "death"

# --- 节点引用 ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var afterimage_component = $AfterimageComponent # AfterimageComponent

# --- 内部变量 ---
var is_dead: bool = false

# 导出参数
@export_group("Movement")
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

# 物理相关
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 状态机相关
@onready var state_machine: StateMachine = $StateMachine

# 输入缓冲系统
var input_buffer_time: float = 0.2
var buffered_attack: bool = false
var buffer_timer: float = 0.0

func _ready():
	# 连接动画完成信号
	animated_sprite.animation_finished.connect(_on_animated_sprite_animation_finished)

func _physics_process(delta: float):
	# 更新输入缓冲计时器
	if buffer_timer > 0:
		buffer_timer -= delta
		if buffer_timer <= 0:
			buffered_attack = false
	
	# 应用物理
	apply_physics(delta)
	
	# 状态机的更新由 StateMachine 自己的 _process/_physics_process 处理
	# 只要 StateMachine 节点在场景树中且未暂停，它就会自动运行

func _unhandled_input(event):
	# 攻击输入缓冲
	if event.is_action_pressed("attack"):
		buffered_attack = true
		buffer_timer = input_buffer_time
	
	if event.is_action_pressed("dev_kill"):
		die()

func apply_physics(delta: float):
	# 应用重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 移动和碰撞检测
	move_and_slide()
	
	# 精灵翻转逻辑
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false

func get_move_input() -> float:
	"""获取移动输入"""
	return Input.get_axis("ui_left", "ui_right")

func is_jump_input() -> bool:
	"""检查是否有跳跃输入"""
	return Input.is_action_just_pressed("jump")

func is_attack_input() -> bool:
	"""检查是否有攻击输入"""
	return buffered_attack

func consume_attack_input():
	"""消耗攻击输入"""
	buffered_attack = false
	buffer_timer = 0

func play_animation(anim_name: String):
	"""播放对应状态的动画"""
	animated_sprite.play(anim_name)

func _on_animated_sprite_animation_finished():
	"""动画完成回调"""
	if state_machine:
		state_machine.on_animation_finished()

# 角色死亡处理函数
func die():
	# 如果已经死了，就不要再执行了
	if is_dead:
		return
	is_dead = true
	
	# 切换到死亡状态
	if state_machine:
		state_machine.change_state("deathstate")

#region --- 拖影效果代理方法 ---

## 开始生成拖影效果
func start_afterimage_effect():
	if afterimage_component:
		afterimage_component.start()

## 停止生成拖影效果
func stop_afterimage_effect():
	if afterimage_component:
		afterimage_component.stop()

#endregion
