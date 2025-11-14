extends CharacterBody2D



# Stats (Weapon-Dynamic)
var move_speed = 1600
var speed_limit = 400
var drag = 0.9
var max_mana = 100
var mana_recharge = 20
var pencil_attack_mana_cost = 0
var pencil_attack_cooldown = 0.25
var pencil_ability_mana_cost = 25
var pencil_ability_speed = 2500
var pencil_ability_cooldown = 0.5
var ruler_attack_mana_cost = 0
var ruler_attack_cooldown = 0.25
var ruler_ability_mana_cost = 25
var ruler_ability_cooldown = 0.5




var mana = max_mana
var cooldown = 0
var selected_weapon = 0
# 0 is Pencil, 1 is Ruler, 2 is Textbook, 3 is Stapler, 4 is Pen, 5 is Sharpener

var penciling = false
var attack_control_vector = Vector2(1,0)

@onready var mana_bar = $ManaBar
#@onready var camera = $Camera2D
func _physics_process(delta: float) -> void:
	# Movement
	var movement_control_vector = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity += movement_control_vector*move_speed*delta
	if not (get_global_mouse_position() - position).is_zero_approx():
		attack_control_vector = (get_global_mouse_position() - position).normalized()
	
	# Abilities
	
	if Input.is_action_pressed("Attack"):
		if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_attack_mana_cost:
			cooldown = pencil_attack_cooldown
			mana -= pencil_attack_mana_cost
			# code actual stab
		
	if Input.is_action_just_pressed("Ability"):
		if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_ability_mana_cost:
			cooldown = pencil_ability_cooldown
			mana -= pencil_ability_mana_cost
			mana_recharge = 0
			velocity -= 0.1*pencil_ability_speed*attack_control_vector
			await get_tree().create_timer(0.1).timeout
			velocity += 1.1*pencil_ability_speed*attack_control_vector
			mana_recharge = 20
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
	
	if cooldown > 0:
		cooldown -= delta
		
		
	# Collision
	if penciling:
		var collision = move_and_collide(velocity*delta)
		if not collision == null:
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
		
	
	$Weapon.rotation = attack_control_vector.angle()
	print(attack_control_vector)
	
