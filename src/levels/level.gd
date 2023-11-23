extends Node2D

@export var MIN_VELOCITY_THRESHOLD:float = 10
@export var COLLISION_WAIT_TIME: float = 3
var bird: DestructibleObject
var last_collision_time = 0
var s_bird : PackedScene = preload("res://src/entities/aliens.tscn")

enum GAME_STATE { WAITING, AIMING, LAUNCHED, TURN_ENDED }
var game_state: GAME_STATE = GAME_STATE.WAITING

func _process(delta):
	if game_state == GAME_STATE.WAITING:
		pass
	elif game_state == GAME_STATE.AIMING:
		pass
	elif  game_state == GAME_STATE.LAUNCHED:
		if check_for_turn_end():
			end_turn()
	elif game_state == GAME_STATE.TURN_ENDED:
		pass

func waiting() -> void:
	pass
	
func aiming() -> void:
	pass

func launch() -> void:
	pass

func end_turn():
	# 回合结束逻辑
	# 可能包括更新UI、准备下一个回合等
	game_state = GAME_STATE.TURN_ENDED

func check_for_turn_end() -> bool:
	return _is_bird_stopped() and _is_never_collis()

func spawn_bird() -> void:
	bird = s_bird.instantiate()
	bird.body_entered.connect(_on_bird_body_entered)
	self.add_child(bird)

## 判断小鸟是否静止
func _is_bird_stopped() -> bool:
	return bird.linear_velocity.length() < MIN_VELOCITY_THRESHOLD

## 判断小鸟是否一段时间未产生新的碰撞
func _is_never_collis() -> bool:
	return (Time.get_ticks_msec() - last_collision_time) > COLLISION_WAIT_TIME

func _on_bird_body_entered(body: DestructibleObject):
	# 鸟开始与另一个物体碰撞
	last_collision_time = Time.get_ticks_msec()
