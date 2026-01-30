extends CharacterBody2D
var drag = 0.9
var speed = 1000
var speed_limit = 500
var max_health = 50
var health = max_health
var cooldown = 0
var chase_target = null
func _physics_process(delta: float) -> void:
	if chase_target:
		var chase_direction = (chase_target.global_position - global_position).normalized()
		rotation = chase_direction.angle()
		velocity += chase_direction * speed * delta
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	
	for body in $"Attack Hitbox".get_overlapping_bodies():
		if body.is_in_group("Player"):
			if cooldown <= 0:
				body.health -= 10
				cooldown = 1
	if cooldown > 0:
		cooldown -= delta
		
	if health <= 0:
		self.queue_free()
	
	velocity.limit_length(speed_limit)
	velocity *= drag
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
	move_and_slide()
	
	


func _on_aggression(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chase_target = body


func _on_aggression_stop(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chase_target = null
