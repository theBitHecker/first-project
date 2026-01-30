extends WeaponData
class_name PencilData

@export_group("Pencil Attack")
@export var attack_shape: Shape2D
@export var attack_offset: Vector2
@export var attack_damage: float
@export var attack_knockback: float

@export_group("Pencil Ability")
@export var ability_shape: Shape2D
@export var ability_offset: Vector2
@export var ability_damage: float
@export var dash_speed: float
@export var knockback_multiplier: float
@export var minimum_knockback: float

var hit_list: Array[Node2D]


func execute_attack(player: CharacterBody2D):
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", attack_shape)
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("position", attack_offset)
	hit_list = []
	player.weapon_state = player.weapon_states.ATTACK
	
func execute_ability(player: CharacterBody2D):
	player.weapon_state = player.weapon_states.ABILITY_BEGIN
	player.mana_recharge = 0
	player.velocity -= 0.1*dash_speed*player.attack_control_vector
	await player.get_tree().create_timer(0.5).timeout
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", ability_shape)
	player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("position", ability_offset)
	player.velocity += 1.1*dash_speed*player.attack_control_vector
	player.mana_recharge = 10
	hit_list = []
	player.weapon_state = player.weapon_states.ABILITY

func weapon_state_change(player: CharacterBody2D):
	if (player.cooldown <= 0.5) and player.weapon_state == player.weapon_states.ABILITY:
		player.weapon_state = player.weapon_states.ABILITY_END
	if player.cooldown <= 0.25 and player.weapon_state == player.weapon_states.ABILITY_END:
		player.weapon_state = player.weapon_states.IDLE
		player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", null)
	if player.cooldown <= 0.01 and player.weapon_state == player.weapon_states.ATTACK:
		player.weapon_state = player.weapon_states.IDLE
		player.get_node("Weapon/Area2D/CollisionShape2D").set_deferred("shape", null)
func weapon_collision(player: CharacterBody2D, bodies: Array[Node2D]):
	for body in bodies:
		if player.weapon_state == player.weapon_states.ATTACK:
			if body.is_in_group("Enemy"):
				if not(body in hit_list):
					body.velocity += player.attack_control_vector * attack_knockback
					hit_list.append(body)
					body.health -= attack_damage
		if player.weapon_state == player.weapon_states.ABILITY:
			if body.is_in_group("Enemy"):
				if not(body in hit_list):
					body.health -= ability_damage
					
					if (player.velocity * knockback_multiplier).length() >= (player.attack_control_vector * minimum_knockback).length():
						body.velocity += (player.velocity * knockback_multiplier)
					else:
						body.velocity += (player.attack_control_vector * minimum_knockback)
						
					if len(hit_list) >= 3:
						player.velocity = player.velocity.bounce((player.global_position - body.global_position).normalized())
						player.weapon_state = player.weapon_states.IDLE
					else:
						hit_list.append(body)
						
	
