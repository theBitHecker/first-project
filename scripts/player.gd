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


enum weapons {
	PENCIL, 
	RULER,
	TEXTBOOK,
	PEN
} 
enum weapon_states {
	IDLE,
	ATTACK,
	ATTACK_START,
	ATTACK_END,
	ABILITY,
	ABILITY_START,
	ABILITY_END
}


var selected_weapon = weapons.PENCIL
var weapon_state = weapon_states.IDLE

var mana = max_mana
var cooldown = 0

# 0 is Pencil, 1 is Ruler, 2 is Textbook, 3 is Stapler, 4 is Pen, 5 is Sharpener

var attack_control_vector = Vector2(1,0)

@export var mana_bar: TextureProgressBar


func _physics_process(delta: float) -> void:
	# Movement
	var movement_control_vector = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity += movement_control_vector*move_speed*delta
	if not (get_global_mouse_position() - $"../Camera2D".position).is_zero_approx():
		if not(weapon_state == weapon_states.ABILITY and selected_weapon == 0):
			attack_control_vector = (get_global_mouse_position() - $"../Camera2D".position).normalized()
	
	# Abilities
	
	#if Input.is_action_just_pressed("Attack"):
		#attack(delta)
		#
	#if Input.is_action_just_pressed("Ability"):
		#ability(delta)
			#
	# Weapon Selecting
	if Input.is_action_just_pressed("Weapon 1") and not selected_weapon == weapons.PENCIL and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = weapons.PENCIL
		weapon_state = weapon_states.IDLE
	if Input.is_action_just_pressed("Weapon 2") and not selected_weapon == weapons.RULER and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = weapons.RULER
		weapon_state = weapon_states.IDLE
	if Input.is_action_just_pressed("Weapon 3") and not selected_weapon == weapons.TEXTBOOK and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = weapons.TEXTBOOK
		weapon_state = weapon_states.IDLE
	# Speed Limit
	
	if not (selected_weapon == 0 and weapon_state == weapon_states.ABILITY):
		velocity = velocity.limit_length(speed_limit)
			
	# Dash Handling 
	if velocity.length() < speed_limit:
		weapon_state = weapon_states.ABILITY_END
		
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
	#if selected_weapon == 0:
		#if using_ability:
			#$Weapon/WeaponSprite.play("pencil_ability")
		#else:
			#$Weapon/WeaponSprite.play("pencil_idle")
	#if selected_weapon == 1:
		#if using_ability:
			#$Weapon/WeaponSprite.play("ruler_ability")
		#else:
			#$Weapon/WeaponSprite.play("ruler_idle")
	#if selected_weapon == 2:
		#if using_ability:
			#$Weapon/WeaponSprite.play("textbook_ability")
		#else:
			#$Weapon/WeaponSprite.play("textbook_idle")
	weapon_animation()
	

	# Mana and Cooldown Handling
	if mana < max_mana:
		mana += mana_recharge * delta
		
	
	mana_bar.value = remap(mana, 0, max_mana, mana_bar.min_value, mana_bar.max_value)
	
	if cooldown > 0:
		cooldown -= delta
	# Collision
	collision_script(delta)

func _input(event):
	if event.is_action_pressed("Attack"):
		attack_script()
		
	if event.is_action_pressed("Ability"):
		ability_script()
		
func attack_script():
	if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_attack_mana_cost:
		cooldown = pencil_attack_cooldown
		mana -= pencil_attack_mana_cost
		# code actual stab

func ability_script():
	if selected_weapon == 0 and cooldown <= 0 and mana >= pencil_ability_mana_cost:
		weapon_state = weapon_states.ABILITY_START
		cooldown = pencil_ability_cooldown
		mana -= pencil_ability_mana_cost
		mana_recharge = 0
		velocity -= 0.1*pencil_ability_speed*attack_control_vector
		await get_tree().create_timer(0.2).timeout
		velocity += 1.1*pencil_ability_speed*attack_control_vector
		mana_recharge = 20
		weapon_state = weapon_states.ABILITY

func collision_script(delta):
	if weapon_state == weapon_states.ABILITY and selected_weapon == weapons.PENCIL:
		var collision = move_and_collide(velocity*delta)
		if collision:
			var collider = collision.get_collider()
			if collider is CharacterBody2D:
				collider.velocity += velocity
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()

func weapon_animation():
	match [selected_weapon, weapon_state]:
		[weapons.PENCIL, weapon_states.IDLE]:
			$Weapon/WeaponSprite.play("pencil_idle")
		[weapons.PENCIL, weapon_states.ATTACK]:
			$Weapon/WeaponSprite.play("pencil_idle")
		[weapons.PENCIL, weapon_states.ABILITY_START]:
			$Weapon/WeaponSprite.play("pencil_ability_begin")
		[weapons.PENCIL, weapon_states.ABILITY]:
			$Weapon/WeaponSprite.play("pencil_ability")
		[weapons.PENCIL, weapon_states.ABILITY_END]:
			$Weapon/WeaponSprite.play("pencil_idle")
		[weapons.RULER, weapon_states.IDLE]:
			$Weapon/WeaponSprite.play("pencil_idle")

		
		
