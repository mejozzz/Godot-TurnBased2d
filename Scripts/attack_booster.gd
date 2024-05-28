class_name AttackBooster
extends Node

signal expired

@export var attack_bonus := 10
@export var duration := 4.0

var _target: Battler

func _init(target: Battler):
	_target = target
	
func _ready():
	var id: int = _target.stats.add_modifier("attack", attack_bonus)
	var timer := get_tree().create_timer(duration)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout").bind(id))
	
func _on_Timer_timeout(id: int) -> void:
	_target.stats.remove_modifier("attack", id)
	emit_signal("expired")
	queue_free()
