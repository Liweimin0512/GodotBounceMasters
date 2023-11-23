extends DestructibleObject

var test_d : Dictionary = {
	
}


func _ready() -> void:
	for key in test_d:
		var item = test_d[key]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
