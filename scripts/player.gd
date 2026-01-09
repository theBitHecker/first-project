extends CharacterBody2D



# Stats (Weapon-Dynamic)
var move_speed = 1600
var speed_limit = 400
var drag = 0.9
var max_mana = 100
var mana_recharge = 10
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


enum weapon_states {
	IDLE,
	ATTACK,
	ATTACK_BEGIN,
	ATTACK_END,
	ABILITY,
	ABILITY_BEGIN,
	ABILITY_END
}

@export var weapons: Dictionary = {
}
var selected_weapon: WeaponData
func _ready():
	selected_weapon = weapons["Pencil"]

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
		if not(weapon_state == weapon_states.ABILITY and selected_weapon.name == "Pencil"):
			attack_control_vector = (get_global_mouse_position() - $"../Camera2D".position).normalized()
	
	# Abilities
	
	#if Input.is_action_just_pressed("Attack"):
		#attack(delta)
		#
	#if Input.is_action_just_pressed("Ability"):
		#ability(delta)
			#
	# Weapon Selecting
	if Input.is_action_just_pressed("Weapon 1") and not selected_weapon.name == "Pencil" and mana >= switch_mana_cost:
		mana -= switch_mana_cost
		selected_weapon = weapons["Pencil"]
		weapon_state = weapon_states.IDLE
	#if Input.is_action_just_pressed("Weapon 2") and not selected_weapon.name == "Ruler" and mana >= switch_mana_cost:
		#mana -= switch_mana_cost
		#selected_weapon = weapons["Ruler"]
		#weapon_state = weapon_states.IDLE
	#if Input.is_action_just_pressed("Weapon 3") and not selected_weapon.name == "Textbook" and mana >= switch_mana_cost:
		#mana -= switch_mana_cost
		#selected_weapon = weapons["Textbook"]
		#weapon_state = weapon_states.IDLE
	# Speed Limit
	
	if not (selected_weapon.name == "Pencil" and weapon_state == weapon_states.ABILITY):
		velocity = velocity.limit_length(speed_limit)
			
	# Dash Handling 
	selected_weapon.weapon_state_change(self)
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
	if cooldown <= 0 and mana >= selected_weapon.attack_mana_cost:
		cooldown = selected_weapon.attack_cooldown
		mana -= selected_weapon.attack_mana_cost
		selected_weapon.execute_attack(self)

func ability_script():
	if cooldown <= 0 and mana >= selected_weapon.ability_mana_cost:
		cooldown = selected_weapon.ability_cooldown
		mana -= selected_weapon.ability_mana_cost
		selected_weapon.execute_ability(self)

func collision_script(delta):
	if weapon_state == weapon_states.ABILITY and selected_weapon.name == "Pencil":
		var collision = move_and_collide(velocity*delta)
		if collision:
			var collider = collision.get_collider()
			if collider is CharacterBody2D:
				collider.velocity += velocity
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()

func weapon_animation():

	match [weapon_state]:
		[weapon_states.IDLE]:
			$Weapon/WeaponSprite.play(selected_weapon.animations["idle"])
		[weapon_states.ATTACK]:
			$Weapon/WeaponSprite.play(selected_weapon.animations["attack"])
		[weapon_states.ABILITY_BEGIN]:
			$Weapon/WeaponSprite.play(selected_weapon.animations["ability_begin"])
		[weapon_states.ABILITY]:
			$Weapon/WeaponSprite.play(selected_weapon.animations["ability"])
		[weapon_states.ABILITY_END]:
			$Weapon/WeaponSprite.play(selected_weapon.animations["ability_end"])


func _on_weapon_hitbox_entered(body: Node2D) -> void:
	selected_weapon.on_weapon_hit(self, body)
