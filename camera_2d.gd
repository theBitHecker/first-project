extends Camera2D

@onready var player = $"../Player"
var speed = 10
func _physics_process(delta: float) -> void:
	position = player.position
	#position = position.lerp(player.position, speed*delta)
	#if player.dashing:
		#speed = 10
	#else:
		#speed = lerp(speed, 5.0, delta)
