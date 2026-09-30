extends Area3D
class_name Hitbox

@onready var coll: CollisionShape3D = $CollisionShape3D
@export var dmg: int = 0
@export var kb: float = 0

#health
@export var bleed: int = 0
@export var decay: int = 0
#movement
@export var speed: int = 0
@export var slow: int = 0
#visual
@export var beacon: int = 0
#beacon displays a beacon in the sky
#highlight highlights players through walls
#compound
@export var plague: int = 0


signal hit_something
