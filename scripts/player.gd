extends CharacterBody2D



# Stats (Weapon-Dynamic)
const MOVE_SPEED = 1600
const SPEED_LIMIT = 400
const DRAG = 0.9
const MAX_MANA = 100
const MANA_RECHARGE = 20
const PENCIL_COST = 0
const MAX_PENCIL_COOLDOWN = 0.25
const PENCIL_SPECIAL_COST = 25
const PENCIL_SPECIAL_POWER = 2500
const MAX_PENCIL_SPECIAL_COOLDOWN = 0.5
const RULER_COST = 0
const MAX_RULER_COOLDOWN = 0.25
const RULER_SPECIAL_COST = 25
const RULER_SPECIAL_POWER = 2500
const MAX_RULER_SPECIAL_COOLDOWN = 0.5

# Stats (Used-Dynamic)
var move_speed = MOVE_SPEED
var speed_limit = SPEED_LIMIT
var drag = DRAG
var max_mana = MAX_MANA
var mana_recharge = MANA_RECHARGE
var pencil_cost = PENCIL_COST
var max_pencil_cooldown = MAX_PENCIL_COOLDOWN
var pencil_special_cost = PENCIL_SPECIAL_COST
var pencil_special_power = PENCIL_SPECIAL_POWER
var max_pencil_special_cooldown = MAX_PENCIL_SPECIAL_COOLDOWN
var ruler_special_cost = RULER_SPECIAL_COST
var ruler_special_power = RULER_SPECIAL_POWER
var max_ruler_special_cooldown = MAX_RULER_SPECIAL_COOLDOWN


var mana = max_mana
var pencil_cooldown = max_pencil_cooldown
var pencil_special_cooldown = max_pencil_special_cooldown
var ruler_special_cooldown = max_ruler_special_cooldown
var selected_weapon = 0
# 0 is Pencil, 1 is Ruler, 2 is Textbook ,3 is Stapler, 4 is Pen, 5 is Sharpener

var penciling = false
var dash_direction = Vector2(1,0)
@onready var mana_bar = $ManaBar
#@onready var camera = $Camera2D
func _physics_process(delta: float) -> void:
	# Movement
	var movement_control_vector = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity += movement_control_vector*move_speed*delta
	
	# Abilities
	
	if Input.is_action_pressed("Attack"):
		if selected_weapon == 0 and pencil_cooldown == 0 and mana >= pencil_cost:
			pencil_cooldown = max_pencil_cooldown
			mana -= pencil_cost
			# code actual stab
		
	if Input.is_action_just_pressed("Ability"):
		if pencil_special_cooldown == 0 and selected_weapon == 0 and mana >= pencil_special_cost:
			pencil_special_cooldown = max_pencil_special_cooldown
			mana -= pencil_special_cost
			if velocity.length() > 0.01:
				dash_direction = velocity.normalized()
			mana_recharge = 0
			velocity -= 0.1*pencil_special_power*dash_direction
			await get_tree().create_timer(0.1).timeout
			velocity += 1.1*pencil_special_power*dash_direction
			mana_recharge = MANA_RECHARGE
			penciling = true
	# Speed Limit
	
	if not penciling:
		velocity = velocity.limit_length(speed_limit)
			
	# Dash Handling 
	if velocity.length() < speed_limit:
		penciling = false
		
	# Slowing Down
	velocity *= drag
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
	# Animation
	if not movement_control_vector.is_zero_approx():
		$PlayerSprite.rotation = lerp_angle($PlayerSprite.rotation, movement_control_vector.angle(), 20*delta)
	if velocity.length() < 100:
		$PlayerSprite.play("Idle")
	else:
		$PlayerSprite.play("Walking")
		
	# Mana and Cooldown Handling
	if mana < max_mana:
		mana += mana_recharge * delta
	mana_bar.value = (mana/max_mana)*100
	
	if pencil_cooldown > 0:
		pencil_cooldown -= delta
	else:
		pencil_cooldown = 0
	if pencil_special_cooldown > 0:
		pencil_special_cooldown -= delta
	else:
		pencil_special_cooldown = 0
		
	# Collision
	if penciling:
		var collision = move_and_collide(velocity*delta)
		if not collision == null:
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
