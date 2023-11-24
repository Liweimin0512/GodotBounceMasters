extends Node2D

@onready var menu: Node2D = %menu
var s_game: PackedScene = preload("res://src/scene/game.tscn")
var game : Node2D

func _ready() -> void:
	menu.game_pressed.connect(
		func() -> void:
			self.remove_child(menu)
			game = s_game.instantiate()
			self.add_child(game)
	)
