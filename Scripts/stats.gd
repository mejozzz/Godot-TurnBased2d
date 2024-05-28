class_name Stats
extends Resource

signal stat_changed(stat, old_value, new_value)

var _stats_list: Dictionary = _gets_stats_list()
var _modifiers: Dictionary
var _cache: Dictionary

# Initializes the keys in the modifiers dict, ensuring they all exist, without going through the
# property's setter.
func _init() -> void:
	for stat in _stats_list:
		_modifiers[stat] = []
		_cache[stat] = 0.0

func initialize() -> void:
	_update_all()

# Get the final value of a stat, with all modifiers applied to it.
func get_stat(stat_name: String = "") -> float:
	assert(stat_name in _stats_list)
	return _cache[stat_name]

# Adds a modifier to the stat corresponding to `stat_name` and returns the new modifier's id.
func add_modifier(stat_name: String, modifier: float) -> int:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].append(modifier)
	_update(stat_name)
	return len(_modifiers)

# Removes a modifier from the stat corresponding to `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].erase(id)
	_update(stat_name)

# Remove all modifiers and recalculate stats.
func reset() -> void:
	_modifiers = {}
	_update_all()

# Calculates the final value of a single stat, its based value with all modifiers applied.
func _update(stat_name: String = "") -> void:
	var value_start: float = self.get(_stats_list[stat_name])
	var value = value_start
	for modifier in _modifiers[stat_name]:
		value += modifier
	_cache[stat_name] = value
	emit_signal("stat_changed", stat_name, value_start, value)

# Recalculates every stat from the base stat, with modifiers.
func _update_all():
	for stat in _stats_list:
		_update(stat)

# Returns a list of stat properties as strings.
func _gets_stats_list() -> Dictionary:
	var ignore: Array = [
		"resource_local_to_scene",
		"resource_name",
		"resource_path",
		"script",
		"_stats_list",
		"_modifiers",
		"_cache"
	]
	
	var stats: Dictionary = {}
	for p in get_property_list():
		if p.name[0].capitalize() == p.name[0]:
			continue
		if p.name in ignore:
			continue
		stats[p.name.lstrip("_")] = p.name
	return stats
