extends CharacterBody2D
var drag = 0.9
func _physics_process(_delta: float) -> void:
	velocity *= drag
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
	move_and_slide()
	
	
