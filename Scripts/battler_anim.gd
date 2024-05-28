@tool
class_name BattlerAnim
extends Marker2D

signal animation_finished(anim_name)
signal triggered

enum Direction{LEFT, RIGHT}

@onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
@onready var anim_player_damage: AnimationPlayer = $Pivot/AnimationPlayerDamage

@export var direction: Direction = Direction.RIGHT: set = set_direction

var position_start := Vector2.ZERO

func set_direction(value) -> void:
	direction = value
	scale.x = -1.0 if direction == Direction.RIGHT else 1.0

func _ready():
	position_start = position

func play(anim_name: String) -> void:
	if anim_name == "take_damage":
		anim_player_damage.play(anim_name)
		anim_player_damage.seek(0.0)
	else:
		anim_player.play(anim_name)

# Queues the animation and plays it if the animation player is stopped.
func is_playing() -> bool:
	return anim_player.is_playing()

func queue_animation(anim_name: String) -> void:
	anim_player.queue(anim_name)
	if not anim_player.is_playing():
		anim_player.play()

#move the character forward and back.
func move_forward() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position",
		(position + Vector2.LEFT * scale.x * 40.0), 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.play()

# Moves the node to `_position_start`
func move_back() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position",
		position_start, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("animation_finished", anim_name)

func _on_AnimationPlayerDamage_animation_finished(anim_name):
	emit_signal("animation_finished", anim_name)
