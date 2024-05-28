class_name Battler
extends Node2D

signal ready_to_act
signal readiness_changed(new_value)
signal selection_toggled(value)

signal damage_taken(amount)
signal hit_missed

# Emitted when the battler finished their action and arrived back at their rest
# position.
signal action_finished
signal animation_finished(anim_name)

@export var stats: BattlerStats
@export var ai_scene : PackedScene
@export var actions: Array[ActionData]

@export var is_party_member := false

@onready var battler_anim: BattlerAnim = $BattlerAnim

# The turn queue will change this property when another battler is acting.
var time_scale := 1.0 : set = set_timescale
# When this value reaches `100.0`, the battler is ready to take their turn.
var readiness := 0.0: set = set_readiness
var is_active := true: set = set_is_active
var is_selected := false: set = set_is_selected
var is_selectable := true: set = set_is_selectable

var ai_instance = null
var status_effect_container : StatusEffectContainer = StatusEffectContainer.new()

func set_is_active(value) -> void:
	is_active = value
	status_effect_container.is_active = value
	_process(true)

func set_readiness(value) -> void:
	readiness = value
	emit_signal("readiness_changed", readiness)
	
	if readiness >= 100:
		emit_signal("ready_to_act")
		set_process(false)

func set_timescale(value) -> void:
	time_scale = value

func set_is_selected(value) -> void:
	if value:
		assert(is_selectable)
	
	if is_selected:
		battler_anim.move_forward()
	is_selected = value
	emit_signal("selection_toggled", is_selected)

func set_is_selectable(value) -> void:
	is_selectable = value
	if not is_selectable:
		set_is_selected(false)

func set_time_scale(value) -> void:
	status_effect_container.time_scale = time_scale

func get_ai() -> Node:
	return ai_instance

func setup(battlers: Array) -> void:
	if ai_scene:
		ai_instance = ai_scene.instantiate()
		ai_instance.setup(self, battlers)
		add_child(ai_instance)

func _ready():
	add_child(status_effect_container)
	assert(stats is BattlerStats)
	stats = stats.duplicate()
	stats.reinitialize()
	stats.health_depleted.connect(func(): _on_BattlerStats_health_depleted())

func _process(delta) -> void:
	set_readiness(readiness + stats.speed * delta * time_scale)

func is_player_controlled() -> bool:
	return ai_scene == null

func take_hit(hit: Hit) -> void:
	if hit.does_hit():
		if hit.effect:
			_apply_status_effect(hit.effect)
		take_damage(hit.damage)
		emit_signal("damage_taken", hit.damage)
	else:
		emit_signal("hit_missed")

func take_damage(amount: int) -> void:
	stats.health -= amount 
	if stats.health > 0:
		battler_anim.play("take_damage")
	print("%s took %s damage. Health is now %s." % [name, amount, stats.health])
	print("%s took %s damage" % [name, amount])

func act(action: Action) -> void:
	stats.energy -= action.get_energy_cost()
	await action.apply_async()
	battler_anim.move_back()
	
	set_readiness(action.get_readiness_saved())
	if is_active:
		set_process(true)
	emit_signal("action_finished")

func is_fallen() -> bool:
	return stats.health == 0

func _apply_status_effect(effect: StatusEffect):
	status_effect_container.add(effect)
	print("Applying effect %s to %s" % [effect.id, name])


func _on_BattlerStats_health_depleted() -> void:
	set_is_active(false)
	if not is_party_member:
		set_is_selectable(false)
		battler_anim.queue_animation("die")

func _on_BattlerAnim_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)
