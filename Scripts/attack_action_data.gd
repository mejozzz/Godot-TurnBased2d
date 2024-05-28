class_name AttackActionData
extends ActionData

@export var damage_multiplier: float = 1.0
# Hit chance rating for this attack. Works as a rate: a value of 90 means the
# action has a 90% chance to hit.
@export var hit_chance: float = 100.0
@export var status_effect: StatusEffectData

# Returns the total damage for the action, factoring in damage dealt by a status effect.
func calculate_potential_damage_for(battler: Battler) -> int:
	var total_damage: int = int(Formulas.calculate_potential_damage(self, battler))
	if status_effect:
		total_damage += status_effect.calculate_damage()
	return total_damage
