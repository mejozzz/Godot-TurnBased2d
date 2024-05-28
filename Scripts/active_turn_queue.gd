class_name ActiveTurnQueue
extends Node2D

# Emitted when a player-controlled battler finished playing a turn
signal player_turn_finished

@onready var battlers := get_children()

var _party_members := []
var _opponents := []
var _queue_player := []

var is_active := true: set = set_is_active
var time_scale: float = 1.0: set = set_time_scale
var is_player_playing := false

func set_is_active(value):
	is_active = value
	for battler in battlers:
		battler.is_active = is_active

func set_time_scale(value):
	time_scale = value
	for battler in battlers:
		battler.time_scale = time_scale

func _ready() -> void:
	player_turn_finished.connect(func(): _on_player_turn_finished())
	for battler in battlers:
		battler.setup(battlers)
		battler.ready_to_act.connect(func(): _on_Battler_ready_to_act(battler))
		if battler.is_party_member:
			_party_members.append(battler)
		else:
			_opponents.append(battler)

func _on_Battler_ready_to_act(battler: Battler) -> void:
	if battler.is_player_controlled() and is_player_playing:
	# If the battler is controlled by the player but another player-controlled battler is in the middle of a turn, we add this one to the stack.
		_queue_player.append(battler)
	else :
	# Otherwise, it's an AI-controlled battler or the player is waiting for a turn, and we can call `_play_turn()`.
		_play_turn(battler)

func _play_turn(battler: Battler) -> void:
	var action_data: ActionData
	var targets := []
	
	battler.stats.energy += 1
	
	# The code below makes a list of selectable targets using `Battler.is_selectable`
	var potential_target := []
	var opponents := _opponents if battler.is_party_member else _party_members
	for opponent in opponents:
		if opponent.is_selectable:
			potential_target.append(opponent)
	
	# We'll use the selection to move playable battlers forward. 
	# This value will also make the Heads-Up Display (HUD) for this
	# battler move forward.
	if battler.is_player_controlled():
		battler.is_selected = true
		set_time_scale(0.5)
		is_player_playing = true
	
		# Here is the meat of the player's turn. We use a while loop to wait for
		# the player to select a valid action and target(s).
		var is_selection_complete := false
		while not is_selection_complete:
			action_data = await _player_select_action_async(battler)
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action_data, potential_target)
			# If the player selected a correct action and target, we can break
			# out of the loop.
			is_selection_complete = action_data != null && targets != []
		# The player-controlled battler is ready to act. We reset the time scale
		# and deselect the battler.
		set_time_scale(1.0)
		battler.is_selected = false
	else:
		var result: Dictionary = battler.get_ai().choose()
		action_data = result.action
		targets = result.targets
		print("%s attacks %s with action %s" % [battler.name, targets[0].name, action_data.label])


	var action = AttackAction.new(action_data, battler, targets)
	battler.act(action)
	await battler.action_finished
	
	if battler.is_player_controlled():
		emit_signal("player_turn_finished")

func _player_select_action_async(battler: Battler) -> ActionData:
	await get_tree().process_frame
	return battler.actions[0]

func _player_select_targets_async(action: ActionData, opponents: Array) -> Array:
	await get_tree().process_frame
	return [opponents[0]]

func _on_player_turn_finished():
	if _queue_player.is_empty():
		is_player_playing = false
	else:
		_play_turn(_queue_player.pop_front())
