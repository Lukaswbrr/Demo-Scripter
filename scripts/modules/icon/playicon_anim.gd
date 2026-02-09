class_name DemoScripter_IconModule_PlayAnim
extends DemoScripter_IconModule
## A [DemoScripter_IconModule] for playing a animation when
## [method DemoScripter_IconModule.show_icon] is executed.

## The animation that will play when [method DemoScripter_IconModule.show_icon] is executed.
@export var anim: String
## The [AnimationPlayer] node from [member icon_node].
@onready var anim_node: AnimationPlayer = icon_node.get_node("AnimationPlayer")

## Shows the icon.
func _show_icon() -> void:
	anim_node.play(anim)

## Hides the icon.
func _hide_icon() -> void:
	anim_node.play("RESET")
