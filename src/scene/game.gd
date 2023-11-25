extends Node

## 关卡队列，按顺序加载
@export var levels : Array[PackedScene] = [
	preload("res://src/levels/level_01.tscn"), 
	preload("res://src/levels/level_02.tscn"), 
	preload("res://src/levels/level_03.tscn")
]
## 当前关卡索引
var current_level_index: int = 0
## 当前关卡
var current_level: Level:
	set(value):
		if current_level:
			current_level.successed.disconnect(_on_current_level_successed)
			current_level.failing.disconnect(_on_current_level_failing)
			remove_child(current_level)
		current_level = value
		if current_level:
			current_level.successed.connect(_on_current_level_successed)
			current_level.failing.connect(_on_current_level_failing)
			add_child(current_level)

@onready var panel_container: PanelContainer = %PanelContainer
@onready var label: Label = %Label
@onready var btn_quit: Button = %btn_quit
@onready var btn_confirm: Button = %btn_confirm
## 关卡结束时是否成功
var is_success: bool = false

func _ready() -> void:
	panel_container.hide()
	btn_quit.pressed.connect(func() -> void:
			get_tree().quit()
	)
	btn_confirm.pressed.connect(func() -> void:
			if is_success:
				next_level()
			else:
				load_level()
			panel_container.hide()
	)
	load_level()

## 加载下一关
func next_level() -> void:
	if levels.size() - 1 > current_level_index:
		current_level_index += 1
	load_level()

## 加载当前关卡
func load_level() -> void:
	current_level = levels[current_level_index].instantiate()

func show_panel() -> void:
	label.text = "恭喜过关！" if is_success else "遗憾落败！"
	btn_confirm.text = "下一关" if is_success else "重试"
	panel_container.show()

func _on_current_level_successed() -> void:
	is_success = true
	show_panel()

func _on_current_level_failing() -> void:
	is_success = false
	show_panel()
