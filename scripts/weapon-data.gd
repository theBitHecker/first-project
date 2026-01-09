extends Resource
class_name WeaponData

@export_group("Visuals")
@export var name: String
@export var animations: Dictionary = {
	"idle": null
}

@export_group("Stats")
@export var attack_mana_cost: int
@export var ability_mana_cost: int
@export var attack_cooldown: float
@export var ability_cooldown: float

@export_group("Attack Hitbox")
@export var attack_shape: Shape2D
@export var attack_offset: Vector2


func execute_attack(_player: CharacterBody2D):
	pass

func execute_ability(_player: CharacterBody2D):
	pass

func weapon_state_change(_player: CharacterBody2D):
	pass

func on_weapon_hit(_player: CharacterBody2D, _body: Node2D):
	pass
	
	
