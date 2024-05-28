class_name BattlerAI
extends Node

enum HealthStatus{CRITICAL, LOW, MEDIUM, HIGH, FULL}

var _actor : Battler
var _party : Array[Battler]
var _opponents : Array[Battler]

var weakness_dict : Dictionary
var next_actions : Array

var rng := RandomNumberGenerator.new()

func setup(actor: Battler, battlers: Array):
	_actor = actor
	for battler in battlers:
		var is_opponent: bool = battler.is_party_member != actor.is_party_member
		if is_opponent:
			_opponents.append(battler)
		else :
			_party.append(battler) 
	calculate_weakness()

# Finds key information about the state of the battle so the agent can take a decision.
func gather_infomation() -> Dictionary:
	var actions := get_available_actions()
	var attack_actions := get_attack_actions_from(actions)
	var defensive_actions := get_defensive_actions_from(actions)
	
	var info: Dictionary = {
		weakest_target = get_battler_with_lowest_health(_opponents),
		weakest_ally = get_battler_with_lowest_health(_party),
		health_status = get_health_status(_actor),
		fallen_party_count = count_fallen_party(),
		fallen_opponents_count = count_fallen_opponents(),
		available_actions = actions,
		attack_actions = attack_actions,
		defensive_actions = defensive_actions,
		strongest_action = find_most_damaging_action_from(attack_actions)
	}
	return info

# Returns an array of actions the agent can use this turn.
func get_available_actions() -> Array[ActionData]:
	var actions : Array[ActionData]
	for action in _actor.actions:
		if action.can_be_used_by(_actor):
			actions.append(action)
	return actions

# Returns actions of type `AttackActionData` in `available_actions`.
func get_attack_actions_from(available_actions: Array[ActionData]) -> Array[ActionData]:
	var attack_actions : Array[ActionData]
	for action in available_actions:
		if action is AttackActionData:
			attack_actions.append(action)
	return attack_actions

# Returns actions that are *not* of type `AttackActionData` in `available_actions`.
func get_defensive_actions_from(available_actions: Array[ActionData]) -> Array[ActionData]:
	var defensive_actions : Array[ActionData]
	for action in available_actions:
		if not action is AttackActionData:
			defensive_actions.append(action)
	return defensive_actions

# Returns the battler with the lowest health in the `battlers` array.
func get_battler_with_lowest_health(battlers: Array) -> Battler:
	var weakest: Battler = battlers[0]
	for battler in battlers:
		if battler.stats.health < weakest.stats.health:
			weakest = battler
	return weakest

# Returns `true` if the `battler`'s health is below a given ratio.
func is_health_below(battler: Battler, ratio: float) -> bool:
	ratio = clamp(ratio, 0.0, 1.0)
	return battler.stats.health < battler.stats.max_health * ratio

# Returns a member of the `HealthStatus` enum depending of the agent's current health ratio.
func get_health_status(battler: Battler) -> int:
	if is_health_below(battler, 0.1):
		return HealthStatus.CRITICAL
	elif is_health_below(battler, 0.3):
		return HealthStatus.LOW
	elif is_health_below(battler, 0.6):
		return HealthStatus.MEDIUM
	elif is_health_below(battler, 1.0):
		return HealthStatus.HIGH
	else:
		return HealthStatus.FULL

# Returns the count of fallen party members.
func count_fallen_party() -> int:
	var count := 0
	for ally in _party:
		if ally.is_fallen():
			count += 1
	return count

# Returns the count of fallen opponents.
func count_fallen_opponents() -> int:
	var count := 0
	for opponent in _opponents:
		if opponent.is_fallen():
			count += 1
	return count

func find_most_damaging_action_from(attack_actions: Array[ActionData]) -> ActionData:
	var strongest_action: ActionData
	var highest_damage := 0
	for action in attack_actions:
		var total_damage = action.calculate_potential_damage_for(_actor)
		if total_damage > highest_damage:
			strongest_action = action
			highest_damage = total_damage
	return strongest_action

# Returns true if the `battler`'s health ratio is above `ratio`.
func is_health_above(battler: Battler, ratio: float) -> bool:
	ratio = clamp(ratio, 0.0, 1.0)
	return battler.stats.health > battler.stats.max_health * ratio

# Returns `true` if the `battler` is weak to the `action`'s element.
func is_weak_to(battler: Battler, action: ActionData) -> bool:
	return action.element in battler.stats.weaksness

func calculate_weakness() -> void:
	for action in _actor.actions:
		weakness_dict[action] = []
		for opponent in _opponents:
			if is_weak_to(_actor, action):
				weakness_dict[action].append(opponent)

# Returns a dictionary representing an action and its targets.
func choose() -> Dictionary:
	assert( not _opponents.is_empty(),
			"You must call setup() on the AI and give it opponents for it to work.")
	return _choose()

func _choose() -> Dictionary:
	var battler_info: Dictionary = gather_infomation()
	var action : ActionData
	var targets := []
	
	if not next_actions.is_empty():
		action = next_actions.pop_front()
	else:
		action = _choose_action(battler_info)
	
	if action.is_targeting_self:
		targets = [_actor]
	else :
		targets = _choose_targets(action, battler_info)
	
	return {action = action, targets = targets}

# Virtual method. Returns the action the agent is choosing to use this turn.
func _choose_action(battler_info : Dictionary) -> ActionData:
	print(battler_info)
	return _actor.actions[0]

# Virtual method. Returns the agent's targets this turn.
func _choose_targets(_action: ActionData, _info : Dictionary) -> Array:
	return [_info.weakest_target]

