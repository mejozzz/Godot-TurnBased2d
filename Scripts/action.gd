class_name Action
extends RefCounted

signal finished

var _data: ActionData
var _actor : Battler
var _targets := []

# The constructor allows you to create actions from code like so:
# var action := Action.new(data, battler, targets)
func _init(data: ActionData, actor: Battler, targets: Array) -> void:
	_data = data
	_actor = actor
	_targets = targets

func apply_async() -> bool:
	await Engine.get_main_loop().process_frame
	emit_signal("finished")
	return true

func targets_opponents() -> bool:
	return true

func get_readiness_saved() -> float:
	return _data.readiness_saved

func get_energy_cost() -> int:
	return _data.energy_cost
