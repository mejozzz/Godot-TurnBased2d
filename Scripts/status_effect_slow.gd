class_name StatusEffectSlow
extends StatusEffect

var speed_reduction: float = 0.0: set = set_speed_rate
var _stat_modifier_id : int = -1

func set_speed_rate(value) -> void:
	speed_reduction = clamp(value, 0.01, 0.99)

func _init(target: Battler, data: StatusEffectData) -> void:
	super(target, data)
	id = "slow"
	speed_reduction = data.effect_rate

func _start() -> void:
	_stat_modifier_id = _target.stats.add_modifier(
		"speed", -1.0 * speed_reduction * _target.stats.speed
	)

func _expire() -> void:
	_target.stats.remove_modifier("speed", _stat_modifier_id)
	queue_free()
