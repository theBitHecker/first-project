extends CharacterBody2D



# Stats (Constants)
const MOVE_SPEED = 1600
const SPEED_LIMIT = 400
const DRAG = 0.9
const MAX_MANA = 100
const MANA_RECHARGE = 20
const DASH_COST = 25
const DASH_POWER = 2500
const MAX_DASH_COOLDOWN = 0.5

# Stats (Dynamic)
var move_speed = MOVE_SPEED
var speed_limit = SPEED_LIMIT
var drag = DRAG
var max_mana = MAX_MANA
var mana_recharge = MANA_RECHARGE
var dash_cost = DASH_COST
var dash_power = DASH_POWER
var max_dash_cooldown = MAX_DASH_COOLDOWN


var mana = max_mana
var dash_cooldown = max_dash_cooldown

var dashing = false
var dash_direction = Vector2(1,0)
@onready var mana_bar = $ManaBar
#@onready var camera = $Camera2D
func _physics_process(delta: float) -> void:
	# Movement
	if Input.is_action_pressed("Move Up"):
		velocity.y -= move_speed*delta
	if Input.is_action_pressed("Move Down"):
		velocity.y += move_speed*delta
	if Input.is_action_pressed("Move Left"):
		velocity.x -= move_speed*delta
	if Input.is_action_pressed("Move Right"):
		velocity.x += move_speed*delta
	# Abilitiesd

	if Input.is_action_just_pressed("Dash"):
		if dash_cooldown == 0:
			if mana >= dash_cost:
				dash_cooldown = max_dash_cooldown
				mana -= dash_cost
				if velocity.length() > 0.01:
					dash_direction = velocity.normalized()
				mana_recharge = 0
				velocity -= 0.1*dash_power*dash_direction
				await get_tree().create_timer(0.1).timeout
				velocity += 1.1*dash_power*dash_direction
				mana_recharge = MANA_RECHARGE
				dashing = true
	# Speed Limit
	if velocity.x > speed_limit:
		if not dashing:
			velocity.x = speed_limit
	if velocity.x < -speed_limit:
		if not dashing:
			velocity.x = -speed_limit
	if velocity.y > speed_limit:
		if not dashing:
			velocity.y = speed_limit
	if velocity.y < -speed_limit:
		if not dashing:
			velocity.y = -speed_limit
			
	# Dash Handling 
	if velocity.length() < speed_limit:
		dashing = false
		
	# Slowing Down
	velocity *= drag
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
		
	# Mana and Cooldown Handling
	if mana < max_mana:
		mana += mana_recharge * delta
	mana_bar.value = (mana/max_mana)*100
	
	if dash_cooldown > 0:
		dash_cooldown -= delta
	else:
		dash_cooldown = 0
		
	# Collision
	if dashing:
		var collision = move_and_collide(velocity*delta)
		if not collision == null:
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
