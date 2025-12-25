# 2D Platformer Demo / 2D 平台跳跃游戏演示

[English](#english) | [中文](#中文)

---

<a id="english"></a>

## English

### Project Overview

This is a 2D platformer game project developed with **Godot 4.4**. It serves as a demo showcasing a robust character controller and game architecture.

**Key Features:**

* **State Machine**: A flexible state machine implementation handling various character states (Idle, Walk, Jump, Fall, Attack, Death).
* **Visual Effects**: Includes Afterimage effects and Dissolve shaders.
* **Combat System**: Basic attack combos and damage handling.

### Getting Started

1. Open the project in Godot Engine (version 4.4 or higher).
2. Locate the main scene file: `Scenes/main.tscn`.
3. Run the scene (F6) or set it as the main scene and run the project (F5).

### Controls (Input Map)

| Action | Key / Button | Description |
| :--- | :--- | :--- |
| **Move Left** | `A` / `Left Arrow` | Move the character to the left. |
| **Move Right** | `D` / `Right Arrow` | Move the character to the right. |
| **Jump** | `K` | Make the character jump. |
| **Attack** | `J` | Perform an attack. |
| **Sprint** | `L` | Perform a sprint/dash. |
| **Debug Kill** | `Space` | Instantly kill the character (for testing death state/animation). |

---

<a id="中文"></a>

## 中文

### 项目概况

这是一个使用 **Godot 4.4** 开发的 2D 平台跳跃游戏项目。它展示了一个功能完善的角色控制器和游戏架构。

**主要特性：**

* **状态机 (State Machine)**: 灵活的状态机实现，处理各种角色状态（待机、行走、跳跃、下落、攻击、死亡）。
* **视觉效果**: 包含残影（Afterimage）效果和溶解（Dissolve）Shader。
* **战斗系统**: 基础的攻击连招和伤害处理。

### 如何启动

1. 使用 Godot 引擎（版本 4.4 或更高）打开本项目。
2. 找到主场景文件：`Scenes/main.tscn`。
3. 运行该场景 (F6)，或将其设为主场景并运行项目 (F5)。

### 操作说明 (Input Map)

| 动作 | 按键 / 按钮 | 说明 |
| :--- | :--- | :--- |
| **向左移动** | `A` / `左方向键` | 控制角色向左移动。 |
| **向右移动** | `D` / `右方向键` | 控制角色向右移动。 |
| **跳跃** | `K` | 控制角色跳跃。 |
| **攻击** | `J` | 执行攻击动作。 |
| **冲刺** | `L` | 执行冲刺/突进动作。 |
| **调试死亡** | `Space` (空格键) | 立即杀死角色（用于测试死亡状态/动画）。 |
