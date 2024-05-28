class_name StatusEffectBug
extends StatusEffect

var damage: int = 3

func _init(target: Battler, data: StatusEffectData) -> void:
	super(target, data)
	damage = data.ticking_damage
	_can_stack = true

func _apply() -> void:
	_target.take_hit(Hit.new(damage))
