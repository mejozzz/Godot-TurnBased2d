class_name Hit
extends RefCounted

var damage: int 
var hit_chance: float
var effect: StatusEffect

func _init(_damage: int, _hit_chance: float = 100.0, _effect: StatusEffect = null):
	damage = _damage
	hit_chance = _hit_chance
	effect = _effect

func does_hit() -> bool:
	return randf() * 100.0 < hit_chance
