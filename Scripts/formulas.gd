class_name Formulas
extends RefCounted

# Returns the product of the attacker's attack and the action's multiplier.
static func calculate_potential_damage(action_data: ActionData, attacker: Battler) -> float:
	return attacker.stats.attack * action_data.damage_multiplier

# The base damage is "attacker.attack * action.multiplier - defender.defense".
# The function multiplies it by a weakness multiplier, calculated by
# `_calculate_weakness_multiplier` below. Finally, we ensure the value is an
# integer in the [1, 999] range.
static func calculate_base_damage(action_data: ActionData, attacker: Battler, defender: Battler) -> int:
	var damage: float = calculate_potential_damage(action_data, attacker)
	damage -= defender.stats.defense
	damage *= calculate_weakness_multiplier(action_data, defender)
	return int(clamp(damage, 1.0, 999.0))

# Calculates a multiplier based on the action and the defender's elements.
static func calculate_weakness_multiplier(action_data: ActionData, defender: Battler) -> float:
	var multiplier := 1.0
	var element: int = action_data.element
	if element != Types.Elements.NONE:
		if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
			multiplier = 0.75
		elif Types.WEAKNESS_MAPPING[element] in defender.stats.weaksness:
			multiplier = 1.5
	return multiplier

# The formula in pseudo-code:
# (attacker.hit_chance - defender.evasion) 
# * action.hit_chance + affinity_bonus + element_triad_bonus - defender_affinity_bonus
static func calculate_hit_chance(action_data: ActionData, attacker: Battler, defender: Battler) -> float:
	var chance: float = attacker.stats.hit_chance - defender.stats.evasion
	chance *= action_data.hit_chance / 100.0
	
	var element: int = action_data.element
	# If the action's element matches the attacker's affinity, we increase the
	# hit rating by 5.
	if element == attacker.stats.affinity:
		chance += 5.0
	if element != Types.Elements.NONE:
		# If the action's element is part of the defender's weaknesses, we
		# increase the hit rating by 10.
		if Types.WEAKNESS_MAPPING[element] in defender.stats.weakness:
			chance += 10.0
		# However, if the defender has an affinity with the action's element, we
		# decrease the hit rating by 10.
		if Types.WEAKNESS_MAPPING[element] == element:
			chance -= 10.0
	return clamp(chance, 0.0, 100.0)
