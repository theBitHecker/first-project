extends Camera2D

@onready var player = $"../Player"

func _physics_process(_delta: float) -> void:
	position = player.position
