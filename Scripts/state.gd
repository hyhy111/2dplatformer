# 状态基类
class_name State
extends Node

var character: CharacterBody2D # 角色引用
var anim_sprite: AnimatedSprite2D # 动画精灵引用

signal transition_requested(new_state_name: String) # 状态转换请求信号

# 准备函数
func _ready() -> void:
	await get_tree().physics_frame

# 初始化函数
func initialize(character: CharacterBody2D, anim_sprite: AnimatedSprite2D):
	self.character = character
	self.anim_sprite = anim_sprite

# 进入状态
func enter() -> void:
	pass

# 退出状态
func exit() -> void:
	pass

# 处理更新
func process_update(_delta: float) -> void:
	pass

# 物理更新
func physics_update(_delta: float) -> void:
	pass

# 动画结束处理
func on_animation_finished() -> void:
	pass