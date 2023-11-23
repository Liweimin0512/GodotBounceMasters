extends RigidBody2D
class_name DestructibleObject

# 冲击阈值
@export var impact_threshold : int = 500
# 需要的冲击次数才能破坏
@export var required_impacts: int = 1 
var impact_count: int = 0  # 冲击次数

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var contact_count = state.get_contact_count()
	for i in range(contact_count):
		var collider = state.get_contact_collider(i)
		var impact_force = state.get_contact_impulse(i).length()  # 获取冲击力
		# 基于冲击力处理伤害逻辑
		if impact_force >= impact_threshold:
			impact_count += 1
		if impact_count >= required_impacts:
			break_obstacle()

## 冲击效果
func break_obstacle():
	# 显示破坏效果，例如播放动画或粒子效果
	# 移除节点
	self.queue_free()
