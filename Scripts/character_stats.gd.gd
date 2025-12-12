## 角色属性配置资源
##
## 用于统一管理角色的基础数值配置。
## 可以在编辑器中创建不同的 .tres 文件（如 BaseStats.tres, HeavyStats.tres）来实现不同的角色手感。
class_name CharacterStats
extends Resource

# --- 基础移动 ---
@export_group("Movement")

## 地面最大移动速度（像素/秒）。
@export var move_speed: float = 200.0

## 地面加速度（像素/秒²）。
## 数值越大，起步越快，达到最大速度的时间越短。
@export var acceleration: float = 800.0

## 地面摩擦力（像素/秒²）。
## 数值越大，松开按键后停下来的速度越快。
@export var friction: float = 1000.0

## 全局重力倍率。
## 1.0 = 标准重力，2.0 = 两倍重力（下落更快）。
@export var gravity_scale: float = 1.0

# --- 跳跃与空中 ---
@export_group("Air")

## 跳跃初始冲量速度。
## 注意：Godot 中 Y 轴向下为正，因此向上跳跃必须是负值（例如 -450.0）。
@export var jump_force: float = -450.0

## 空中左右移动的最大速度（像素/秒）。
## 通常比地面移动速度稍慢，以体现空中变向的惯性。
@export var air_control_speed: float = 150.0

## 空中攻击时的水平漂移速度。
## 允许玩家在空中攻击时微调位置。
@export var air_attack_drift: float = 100.0

## 落地缓冲期间（Fall 动画最后几帧）允许的水平滑行速度。
@export var fall_drift_speed: float = 50.0

## 空中攻击时的重力倍率。
## 设置为小于 1.0 的值（如 0.5）可以产生“滞空感” (Hang Time)。
@export var air_attack_gravity_scale: float = 0.5

# --- 战斗 ---
@export_group("Combat")

## 地面三连击每一段的向前突进速度。
## 数组索引对应连招段数：[0]=第一段, [1]=第二段, [2]=第三段。
@export var ground_lunge_speeds: Array[float] = [60.0, 30.0, 80.0]

## 击退抗性 (0.0 - 1.0)。
## 0.0 = 完全受击退影响，1.0 = 霸体（不被击退）。
@export var knockback_resistance: float = 0.0