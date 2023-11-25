extends Node2D
class_name Level

enum GAME_STATE {READY, WAITING, AIMING, LAUNCHED, TURN_ENDED, GAME_SUCCESSED, GAME_FAILING }
var game_state: GAME_STATE = GAME_STATE.READY:
	set(value):
		print("GameState:", GAME_STATE.keys()[game_state])
		game_state = value
		match game_state:
			GAME_STATE.WAITING:
				waiting()
			GAME_STATE.LAUNCHED:
				launch()
			GAME_STATE.TURN_ENDED:
				end_turn()
			GAME_STATE.GAME_SUCCESSED:
				successed.emit()
			GAME_STATE.GAME_FAILING:
				failing.emit()

@onready var slingshot: Node2D = $slingshot
#@onready var aliens: RigidBody2D = $aliens
#@onready var aliens_2: RigidBody2D = $aliens2
@onready var camera_2d: Camera2D = $Camera2D
@onready var bullets: Node2D = $bullets

@export var MIN_VELOCITY_THRESHOLD:float = 10
@export var COLLISION_WAIT_TIME: float = 3
var last_collision_time = 0

var bullet: DestructibleObject :
	set(value):
		slingshot.bullet = value
		bullet = value
var s_bullet : PackedScene = preload("res://src/entities/aliens.tscn")

signal successed
signal failing

func _ready() -> void:
	slingshot.aiming_started.connect(_on_slingshot_aiming_started)
	slingshot.aiming_canceled.connect(_on_slingshot_aiming_canceled)
	level_ready()

func _process(delta):
	if game_state == GAME_STATE.AIMING:
		aiming()
	elif game_state == GAME_STATE.LAUNCHED:
		update_camera_position()
		if _is_turn_end():
			game_state = GAME_STATE.TURN_ENDED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released() and self.game_state == GAME_STATE.AIMING:
			game_state = GAME_STATE.LAUNCHED

## 关卡初始化
func level_ready() -> void:
	if game_state != GAME_STATE.READY : return
	await get_tree().create_timer(0.5).timeout
	await reset_camera()
	game_state = GAME_STATE.WAITING

## 等待玩家输入
func waiting() -> void:
	bullet = s_bullet.instantiate()
	bullet.body_entered.connect(_on_bullet_body_entered)

## 瞄准
func aiming() -> void:
	slingshot.aim()

## 发射
func launch() -> void:
	slingshot.launch()

func end_turn():
	# 回合结束逻辑
	# 可能包括更新UI、准备下一个回合等
	bullet.body_entered.disconnect(_on_bullet_body_entered)
	bullet = null
	if not _has_enemy():
		game_state = GAME_STATE.GAME_SUCCESSED
	elif not _has_bullet():
		game_state = GAME_STATE.GAME_FAILING
	else:
		bullets.remove_child(bullets.get_child(0))
		await reset_camera()
		game_state = GAME_STATE.WAITING

## 复位摄像机
func reset_camera() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(camera_2d, "position:x", get_viewport_rect().size.x / 2, 2)
	await tween.finished

## 是否结束回合？
func _is_turn_end() -> bool:
	return _is_bullet_stopped() and _is_never_collis()

## 更新摄像机位置
func update_camera_position():
	if not bullet: return
	if not _is_bullet_stopped():  # 仅当小鸟移动时更新摄像机位置
		camera_2d.global_position = bullet.global_position

## 判断是否静止
func _is_bullet_stopped() -> bool:
	return bullet.linear_velocity.length() < MIN_VELOCITY_THRESHOLD

## 判断是否一段时间未产生新的碰撞
func _is_never_collis() -> bool:
	return (Time.get_ticks_msec() - last_collision_time) > COLLISION_WAIT_TIME

## 存在敌人
func _has_enemy() -> bool:
	return get_tree().get_nodes_in_group("enemy").size() > 0

## 存在子弹
func _has_bullet() -> bool:
	return bullets.get_child_count() > 0

func _on_bullet_body_entered(body: DestructibleObject):
	# 子弹开始与另一个物体碰撞
	last_collision_time = Time.get_ticks_msec()

func _on_slingshot_aiming_started() -> void:
	if game_state != GAME_STATE.WAITING : return
	game_state = GAME_STATE.AIMING

func _on_slingshot_aiming_canceled() -> void:
	if game_state != GAME_STATE.AIMING : return
	game_state = GAME_STATE.WAITING

