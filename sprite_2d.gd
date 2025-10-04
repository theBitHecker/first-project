extends CharacterBody2D

var mana = 100
var dashing = false
var dash_length = Vector2(1,0)
@onready var mana_bar = $ManaBar
#@onready var camera = $Camera2D
func _physics_process(delta: float) -> void:
	# Movement
	if Input.is_action_pressed("Move Up"):
		velocity.y -= 1600*delta
	if Input.is_action_pressed("Move Down"):
		velocity.y += 1600*delta
	if Input.is_action_pressed("Move Left"):
		velocity.x -= 1600*delta
	if Input.is_action_pressed("Move Right"):
		velocity.x += 1600*delta
	# Abilities
	if velocity.length() > 0.01:
		dash_length = velocity.normalized()
	if Input.is_action_just_pressed("Dash"):
		if mana >= 25:
			mana -= 25
			velocity += 2500*dash_length
			dashing = true
	# Speed Limit
	if velocity.x > 400:
		if not dashing:
			velocity.x = 400
	if velocity.x < -400:
		if not dashing:
			velocity.x = -400
	if velocity.y > 400:
		if not dashing:
			velocity.y = 400
	if velocity.y < -400:
		if not dashing:
			velocity.y = -400
	# Dash Handling 
	if velocity.length() < 400:
		dashing = false
	#if dashing:
		#if dash_length.x > 0:
			#if dash_length.y > 0:
				#camera.offset = 0.1*Vector2(max(0, velocity.x-200), max(0, velocity.x+200))
			#else:
				#camera.offset = 0.1*Vector2(max(0, velocity.x-200), min(0, velocity.x-200))
		#else:
			#if dash_length.y > 0:
				#camera.offset = 0.1*Vector2(min(0, velocity.x+200), max(0, velocity.x+200))
			#else:
				#camera.offset = 0.1*Vector2(min(0, velocity.x+200), min(0, velocity.x-200))
	#else:
		#camera.offset = Vector2.ZERO
		#print(velocity)
	# Slowing Down
	velocity *= 0.9
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
	# Mana Handling
	if mana  < 100:
		mana += 20 * delta
	mana_bar.value = (mana/100)*100
	if dashing:
		var collision = move_and_collide(velocity*delta)
		if not collision == null:
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
