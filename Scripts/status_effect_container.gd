class_name StatusEffectContainer
extends Node

const MAX_STACKS: int = 5
const STACKING_EFFECTS: Array = ["bug"]
const NON_STACKING_EFFECTS: Array = ["haste", "slow"]

var time_scale: float = 1.0: set = set_time_scale
var is_active: bool = true: set = set_is_active

func set_time_scale(value) -> void:
	time_scale = value
	for effect in get_children():
		effect.is_active = is_active

func set_is_active(value) -> void:
	is_active = value
	for effect in get_children():
		effect.is_active = is_active

func add(effect: StatusEffect) -> void:
	if effect.can_stack():
		if _has_maximum_stacks_of(effect.id):
			_remove_effect_expiring_the_soonest(effect.id)
	elif has_node(NodePath(effect.id)):
		get_node(NodePath(effect.id)).expire()
	add_child(effect)

func remove_type(id: String) -> void:
	for effect in get_children():
		if effect.id == id:
			effect.expire()

func remove_all() -> void:
	for effect in get_children():
		effect.expire()

func _has_maximum_stacks_of(id: String) -> bool:
	var count := 0
	for effect in get_children():
		if effect.id == id:
			count += 1
	return count == MAX_STACKS

func _remove_effect_expiring_the_soonest(id: String) -> void:
	var to_remove: StatusEffect
	var smallest_time: float = INF
	for effect in get_children():
		if effect.id != id:
			continue
			
		var time_left = effect.get_time_left()
		if time_left < smallest_time:
			to_remove = effect
			smallest_time = time_left
	to_remove.expire()
