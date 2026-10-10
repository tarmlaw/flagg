extends BaseClass
class_name Goblin

## CAMERA & UI
#@export_category("Camera & UI")

## HEALTH
#@export_category("Health")
#@export_group("Health")

## STATUS EFFECTS

## STATES
#@export_category("States")

## INTERACTION
#@export_category("Interaction")
#@export_group("Interaction")

## MOVEMENT
#@export_category("Movement")

## NAVIGATION
#@export_category("Navigation")

## ANIMATION, AUDIO, & VISUAL
#@export_category("AAV")

## MISCELLANEOUS
#@export_category("Miscellaneous")

@onready var hp_label: Label3D = $Label3D


func display_debug():
	#display hp for other players
	if !is_multiplayer_authority():
		hp_label.text = str("HP: ", hp, " SHIELD: ", shield)
	else:
		hp_label.text = ""
	
	super()
