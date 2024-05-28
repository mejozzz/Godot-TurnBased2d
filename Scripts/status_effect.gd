class_name StatusEffect
extends Node

var time_scale : float = 1.0
var duration_seconds : float = 0.0: set = set_duration_seconds
var ticking_interval :float = 1.0
var is_ticking : bool = false

var is_active : bool = true: set = set_is_active

var id : String = "base_effect"

var _time_left: float = -INF
var _ticking_clock : float = 0.0
var _can_stack : bool = false
var _target: Battler

func set_duration_seconds(value: float) -> void:
	duration_seconds = value
	_time_left = duration_seconds

func set_is_active(value) -> void:
	is_active = value
	set_process(is_active)

func _init(target: Battler, data: StatusEffectData):
	_target = target
	set_duration_seconds(data.duration_seconds)
	
	is_ticking = data.is_ticking
	ticking_interval = data.ticking_interval
	_ticking_clock = ticking_interval

func _ready() -> void:
	_start()

func _process(delta) -> void:
	_time_left -= delta * time_scale
	# If the effect is ticking, we want to know when we have to apply it. For example, for poison,
	# you want to inflict damage every `ticking_interval` seconds.
	if is_ticking:
		var old_clock = _ticking_clock
		_ticking_clock = wrapf(_ticking_clock - delta * time_scale, 0.0, ticking_interval)
		if _ticking_clock > old_clock:
			_apply()
	
	if _time_left < 0.0:
		set_process(false)
		_expire()

func can_stack() -> bool:
	return _can_stack

func get_time_left() -> float:
	return _time_left

func _expire() -> void:
	queue_free()

func _apply() -> void:
	pass

func _start() -> void:
	pass

func expire() -> void:
	_expire()
