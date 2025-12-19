extends CharacterBody2D



# Stats (Weapon-Dynamic)
var move_speed = 1600
var speed_limit = 400
var drag = 0.9
var max_mana = 100
var mana_recharge = 20
var switch_mana_cost = 10
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

var using_ability = false
var attack_control_vector = Vector2(1,0)

@export var mana_bar: TextureProgressBar


func _physics_process(delta: float) -> void:
	# Movement
	var movement_control_vector = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity += movement_control_vector*move_speed*delta
	if not (get_global_mouse_position() - $"../Camera2D".position).is_zero_approx():
		if not(using_ability and selected_weapon == 0):
			attack_control_vector = (get_global_mouse_position() - $"../Camera2D".position).normalized()
	
	# Abilities
	
	#if Input.is_action_just_pressed("Attack"):
		#attack(delta)
		#
	#if Input.is_action_just_pressed("Ability"):
		#ability(delta)
			#
	# Weapon Selecting
	if Input.is_action_just_pressed("Weapon 1") and not selected_weapon == 0 and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = 0
		using_ability = false
	if Input.is_action_just_pressed("Weapon 2") and not selected_weapon == 1 and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = 1
		using_ability = false
	if Input.is_action_just_pressed("Weapon 3") and not selected_weapon == 2 and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = 2
		using_ability = false
	# Speed Limit
	
	if not (using_ability and selected_weapon == 0):
		velocity = velocity.limit_length(speed_limit)
			
	# Dash Handling 
	if velocity.length() < speed_limit:
		using_ability = false
		
	# Slowing Down
	velocity *= drag
	if velocity.is_zero_approx():
		velocity = Vector2(0, 0)
	# Animation
	if not movement_control_vector.is_zero_approx():
		$PlayerSprite.rotation = lerp_angle($PlayerSprite.rotation, movement_control_vector.angle(), 20*delta)
	if velocity.length() < 100:
		$PlayerSprite.play("idle")
	else:
		$PlayerSprite.play("walk")
		
	$Weapon.rotation = attack_control_vector.angle()
	if selected_weapon == 0:
		if using_ability:
			$Weapon/WeaponSprite.play("pencil_ability")
		else:
			$Weapon/WeaponSprite.play("pencil_idle")
	if selected_weapon == 1:
		if using_ability:
			$Weapon/WeaponSprite.play("ruler_ability")
		else:
			$Weapon/WeaponSprite.play("ruler_idle")
	if selected_weapon == 2:
		if using_ability:
			$Weapon/WeaponSprite.play("textbook_ability")
		else:
			$Weapon/WeaponSprite.play("textbook_idle")
	

	# Mana and Cooldown Handling
	if mana < max_mana:
		mana += mana_recharge * delta
		
	
	mana_bar.value = (mana/max_mana)*100
	
	if cooldown > 0:
		cooldown -= delta
		
		
	# Collision
	if using_ability and selected_weapon == 0:
		var collision = move_and_collide(velocity*delta)
		if collision:
			var collider = collision.get_collider()
			if collider is CharacterBody2D:
				collider.velocity += velocity
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
	print(using_ability)
	
func attack():
	if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_attack_mana_cost:
		cooldown = pencil_attack_cooldown
		mana -= pencil_attack_mana_cost
		# code actual stab

func ability():
	if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_ability_mana_cost:
		cooldown = pencil_ability_cooldown
		mana -= pencil_ability_mana_cost
		mana_recharge = 0
		velocity -= 0.1*pencil_ability_speed*attack_control_vector
		await get_tree().create_timer(0.2).timeout
		velocity += 1.1*pencil_ability_speed*attack_control_vector
		mana_recharge = 20
		using_ability = true
		
func _input(event):
	if event.is_action_pressed("Attack"):
		attack()
		
	if event.is_action_pressed("Ability"):
		ability()
			
	
	

	


	
