extends State

func enter():
	# 1. 立即行动：停止移动
	character.velocity = Vector2.ZERO

	# 2. 播放角色死亡动画
	character.play_animation("death")
	
	# 3. 等待“死亡”动画结束
	await anim_sprite.animation_finished
	
	# 4. 播放溶解效果（使用角色上的AnimationPlayer）
	# 假设角色有一个AnimationPlayer节点用于效果
	var animation_player = character.get_node_or_null("AnimationPlayer")
	if animation_player:
		print("play dissolve_animation")
		animation_player.play("dissolve_animation")
	
func physics_update(_delta: float):
	# 在死亡状态下什么都不做
	pass