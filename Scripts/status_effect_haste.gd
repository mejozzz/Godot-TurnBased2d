class_name StatusEffectHaste
extends StatusEffect

var speed_bonus: int = 0
var _stat_modifier_id: int = -1

func _init(target: Battler, data: StatusEffectData) -> void:
	super(target, data)
	id = "haste"
	speed_bonus = data.effect_power

func _start() -> void:
	_stat_modifier_id = _target.stats.add_modifier("speed", speed_bonus)

func _expire() -> void:
	_target.stats.remove_modifier("speed", _stat_modifier_id)
	queue_free()
