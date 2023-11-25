extends Node2D

@onready var sprite_2d_3: Sprite2D = %Sprite2D3
@onready var sling_band_left: Line2D = %sling_band_left
@onready var sling_band_right: Line2D = %sling_band_right
@onready var area_2d: Area2D = %Area2D
@onready var marker_2d: Marker2D = %Marker2D
## 速度因子，根据需要调整
@export var initial_velocity_factor = 10  

var start_position : Vector2
var drag_position := Vector2.ZERO
# 最大拉伸距离，根据需要调整
@export var max_stretch_distance = 100.0  
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

## "点"场景路径
@onready var point_texture = preload("res://assets/textures/point.png")
var points = []
## 要显示的点的数量
@export var max_points = 20 

var bullet : DestructibleObject :
	set(value):
		if bullet:
			marker_2d.remove_child(bullet)
		if value:
			marker_2d.add_child(value)
		bullet = value

signal aiming_started
signal aiming_canceled

func _ready() -> void:
	area_2d.input_event.connect(_on_area_2d_input_event)
	start_position = marker_2d.position
	_setup_trajectory_points()

## 瞄准
func aim() -> void:
	sprite_2d_3.visible = true
	sling_band_left.visible	 = true
	sling_band_right.visible = true
	_update_sling_band()
	_update_trajectory()

## 发射
func launch() -> void:
	bullet.linear_velocity = self._get_launch_velocity()
	bullet.gravity_scale = 1
	drag_position = start_position
	sprite_2d_3.visible = false
	sling_band_left.visible	 = false
	sling_band_right.visible = false

## 初始化抛物线的点
func _setup_trajectory_points() -> void:
	for i in range(max_points):
		var point = Sprite2D.new()
		point.texture = point_texture
		points.append(point)
		add_child(point)
		point.visible = false  # 初始时不可见

## 更新橡皮筋
func _update_sling_band() -> void:
	var local_mouse_pos = get_local_mouse_position()
	var stretch_vector = local_mouse_pos - start_position
	# 限制向左（后方）拉伸
	if stretch_vector.x > -50:
		stretch_vector.x = -50
	# 限制拉伸距离
	stretch_vector = _clamp_vector_to_length(stretch_vector, max_stretch_distance)
	drag_position = start_position + stretch_vector
	sling_band_left.points[1] = drag_position + Vector2(-20, 10)
	sling_band_right.points[1] = drag_position + Vector2(-20, 10)
	sprite_2d_3.position = drag_position + Vector2(-20, 10)
	bullet.position = drag_position - marker_2d.position

## 更新抛物线
func _update_trajectory() -> void:
	var initial_velocity = _get_launch_velocity()
	var time_step = 0.1  # 时间步长
	var total_time = 2.0  # 总模拟时间
	var current_time = 0.0
	var index = 0
	while current_time <= total_time and index < max_points:
		points[index].global_position = to_global(
			Vector2(
				start_position.x + initial_velocity.x * current_time,
				start_position.y + initial_velocity.y * current_time + 0.5 * gravity * current_time * current_time
			)
		)
		points[index].visible = true
		current_time += time_step
		index += 1
	# 隐藏多余的点
	for i in range(index, max_points):
		points[i].visible = false


func _clamp_vector_to_length(v: Vector2, max_length: float) -> Vector2:
	return v.normalized() * max_length if v.length() > max_length else v

## 获取初始速度
func _get_launch_velocity() -> Vector2:
	var stretch_vector = start_position - drag_position  # 拉伸向量
	return stretch_vector * initial_velocity_factor

## 玩家拉动弹弓（输入控制）
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			aiming_started.emit()
		else :
			aiming_canceled.emit()
			drag_position = start_position  # 释放时重置位置
			for p in points:
				p.visible = false
