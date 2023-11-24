extends Node2D

@onready var btn_game: Button = %btn_game
@onready var btn_setting: Button = %btn_setting
@onready var btn_credits: Button = %btn_credits
@onready var btn_quit: Button = %btn_quit
@onready var btn_credits_quit: Button = %btn_credits_quit
@onready var credits: Control = %credits

signal game_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	credits.hide()
	btn_game.pressed.connect(
		func() -> void:
			game_pressed.emit()
	)
	btn_setting.pressed.connect(
		func() -> void:
			pass
	)
	btn_credits.pressed.connect(
		func() -> void:
			credits.show()
	)
	btn_quit.pressed.connect(
		func() -> void:
			get_tree().quit()
	)
	btn_credits_quit.pressed.connect(
		func() -> void:
			credits.hide()
	)
