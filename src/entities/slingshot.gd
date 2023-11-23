extends Node2D

@onready var sprite_2d_3: Sprite2D = %Sprite2D3
@onready var sling_band_left: Line2D = %sling_band_left
@onready var sling_band_right: Line2D = %sling_band_right
@onready var area_2d: Area2D = %Area2D
@onready var marker_2d: Marker2D = %Marker2D

@export var initial_velocity_factor = 10  # 速度因子，根据需要调整

var start_position : Vector2
var drag_position := Vector2.ZERO
var can_drag : bool = false:
	set(value):
		can_drag = value
		sprite_2d_3.visible = can_drag
		sling_band_left.visible	 = can_drag
		sling_band_right.visible = can_drag
# 最大拉伸距离，根据需要调整
@export var max_stretch_distance = 100.0  
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

## "点"场景路径
@onready var point_texture = preload("res://assets/textures/point.png")
var points = []
## 要显示的点的数量
@export var max_points = 20 

@onready var s_bird :PackedScene = preload("res://src/entities/aliens.tscn")
var bird : RigidBody2D
#@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	area_2d.input_event.connect(_on_area_2d_input_event)
	start_position = marker_2d.position
	setup_trajectory_points()
	bird = s_bird.instantiate()
	marker_2d.add_child(bird)
	bird.gravity_scale = 0

func _process(delta: float) -> void:
#	update_camera_position()
	if can_drag:
		update_sling_band()
		update_trajectory()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if can_drag:
			launch_bird()
			can_drag = false
			drag_position = start_position  # 释放时重置位置
			for p in points:
				p.visible = false

## 初始化抛物线的点
func setup_trajectory_points():
	for i in range(max_points):
		var point = Sprite2D.new()
		point.texture = point_texture
		points.append(point)
		add_child(point)
		point.visible = false  # 初始时不可见

## 更新弹簧
func update_sling_band() -> void:
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
	bird.position = drag_position - marker_2d.position

## 更新抛物线
func update_trajectory():
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

## 发射小鸟
func launch_bird():
	bird.linear_velocity = _get_launch_velocity()
	bird.gravity_scale = 1

## 更新摄像机位置
#func update_camera_position():
#	if not bird: return
#	if bird.linear_velocity.length() > 10:  # 仅当小鸟移动时更新摄像机位置
#		camera_2d.global_position = bird.global_position

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
			can_drag = true
		else :
			can_drag = false
			drag_position = start_position  # 释放时重置位置
			for p in points:
				p.visible = false
