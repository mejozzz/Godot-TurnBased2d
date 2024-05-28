class_name StatusEffectData
extends Resource

@export var effect : String= ""
@export var duration_seconds : float = 20.0
@export var effect_power : int = 20
@export var effect_rate : float = 0.5

@export var is_ticking : bool = false
@export var ticking_interval : float = 4.0
@export var ticking_damage : int = 3

# Returns the total theoretical damage the effect will inflict over time. For ticking effects.
func calculate_damage() -> int:
	var damage := 0
	if is_ticking:
		damage += int(duration_seconds / ticking_interval * ticking_damage)
	return damage
