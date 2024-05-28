class_name ActionData
extends Resource

# We will define this enum several times in our codebase.
# Having it in the file allows us to use it as an export hint and to have a
# drop-down menu in the inspector. See `element` below.
enum Elements{NONE, CODE, DESIGN, ART, BUG}

@export var icon: Texture
@export var label := "Base Combat Action"

@export var energy_cost: int = 0
# Elemental type of the action. We'll use it later to add bonus damage if
# the action's target is weak to the element.
@export var element: Elements = Elements.NONE
# The following properties help us filter potential targets on a battler's turn.
@export var is_targeting_self: bool = false
@export var is_targeting_all: bool = false
# The amount of readiness left to the battler after acting.
# You can use it to design weak attacks that allow you to take turn fast.
@export var readiness_saved: float = 0.0

func can_be_used_by(battler: Battler) -> bool:
	return energy_cost <= battler.stats.energy
