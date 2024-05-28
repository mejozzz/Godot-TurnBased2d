class_name AttackAction
extends Action

var _hits := []

func _init(data: AttackActionData, actor: Battler, targets: Array) -> void:
	super(data, actor, targets)

func apply_async() -> bool:
	var anim = _actor.battler_anim
	# We apply the action to each target so attacks work both for single and multiple targets.
	for target in _targets:
		var status: StatusEffect = StatusEffectBuilder.create_status_effect(target, _data.status_effect)
		var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
		var damage := calculate_potential_damage_for(target)
		var hit := Hit.new(damage, hit_chance, status)
		anim.triggered.connect(func(): _on_BattlerAnim_triggered(target, hit))
		anim.play("attack")
		_actor.animation_finished.connect(func(): _on_Battler_animation_finished())
	return true

func calculate_potential_damage_for(target) -> int:
	return Formulas.calculate_base_damage(_data, _actor, target)

func _on_Battler_animation_finished():
	Engine.get_main_loop().process_frame

func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	target.take_hit(hit)
