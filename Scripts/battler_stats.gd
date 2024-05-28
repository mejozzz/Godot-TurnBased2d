class_name BattlerStats
extends Resource

# Emitted when a character has no `health` left.
signal health_depleted
# Emitted every time the value of `health`and 'energy' changes.
signal health_changed(old_value, new_value)
signal energy_changed(old_value, new_value)

const UPGRADABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

@export var max_health := 100.0
@export var max_energy := 6

@export var base_attack: float = 10.0: set = set_base_attack
@export var base_defense: float = 10.0: set = set_base_defense
@export var base_speed: float = 70.0: set = set_base_speed
@export var base_hit_chance: float = 100.0: set = set_base_hit_chance
@export var base_evasion: float = 0.0: set = set_base_evasion

@export var weaksness := []
@export var affinity: Types.Elements = Types.Elements.NONE

var health: float = max_health: set = set_health
var energy: int = max_energy: set = set_energy

# The values below are meant to be read-only.
var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

# The value of a modifier can be any floating-point value, positive or negative.
var _modifiers := {}

func set_health(value: float):
	var health_previous = health
	health = clamp(value, 0.0, max_health)
	emit_signal("health_changed", health_previous, health)
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")

func set_energy(value: int):
	var energy_previous := energy
	energy = int(clamp(value, 0.0, max_energy))
	emit_signal("energy_changed", energy_previous, energy)

func set_base_attack(value: float) -> void:
	base_attack = value
	_recalculate_and_update("attack")

func set_base_defense(value: float) -> void:
	base_defense = value
	_recalculate_and_update("defense")

func set_base_speed(value: float) -> void:
	base_speed = value
	_recalculate_and_update("speed")

func set_base_hit_chance(value: float) -> void:
	base_hit_chance = value
	_recalculate_and_update("hit_chance")

func set_base_evasion(value: float) -> void:
	base_attack = value
	_recalculate_and_update("evasion")

# Initializes keys in the modifiers dict, ensuring they all exist.
func _init() -> void:
	for stat in UPGRADABLE_STATS:
		_modifiers[stat] = {}

# Calculates the final value of a single stat. That is, its based value
# with all modifiers applied.
func _recalculate_and_update(stat: String) -> void:
	# All our property names follow a pattern: the base stat has the
	# same identifier as the final stat with the "base_" prefix.
	var value: float = get("base_" + stat)
	# We get the array of modifiers corresponding to a stat.
	var modifiers: Array = _modifiers[stat].values()
	for modifier in modifiers:
		value += modifier
	value = max(value, 0.0)
	set(stat, value)

# Adds a modifier that affects the stat with the given `stat_name` and returns
# its unique key.
func add_modifier(stat_name: String, value: float) -> int:
	assert(stat_name in UPGRADABLE_STATS,\
		 "Trying to add a modifier to a nonexistent stat.")
	var id := _generate_unique_id(stat_name)
	_modifiers[stat_name][id] = value
	_recalculate_and_update(stat_name)
	return id

# Removes a modifier associated with the given `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(id in _modifiers[stat_name], \
		"Id %s not found in %s" % [id, _modifiers[stat_name]])
	# Here's why we use dictionaries in `_modifiers`: we can arbitrarily erase
	# keys without affecting others, ensuring our unique IDs always work.
	_modifiers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


# Find the first unused integer in a stat's modifiers keys.
func _generate_unique_id(stat_name: String) -> int:
	var keys: Array = _modifiers[stat_name].keys()
	# If there are no keys, we return `0`, which is our first valid unique id.
	# Without existing keys, calling methods like `Array.back()` will trigger an
	# error.
	if keys.is_empty():
		return 0
	else:
		# We always start from the last key, which will always be the highest
		# number, even if we remove modifiers.
		return keys.back() + 1

func reinitialize() -> void:
	set_health(max_health)


