class_name StatusEffectBuilder
extends RefCounted

const STATUS_EFFECTS := {
	"haste" = preload("res://Scripts/status_effect_haste.gd"),
	"slow" = preload("res://Scripts/status_effect_slow.gd"),
	"bug" =preload("res://Scripts/status_effect_bug.gd")
}

static func create_status_effect(target: Battler, data: StatusEffectData):
	if not data:
		return null
	
	var effect_class = STATUS_EFFECTS[data.effect]
	var effect: StatusEffect = effect_class.new(target, data)
	return effect
