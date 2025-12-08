class_name DemoScripter_IconModule_PlayAnim
extends DemoScripter_IconModule

@export var anim: String
@onready var anim_node: AnimationPlayer = icon_node.get_node("AnimationPlayer")

func _show_icon() -> void:
	anim_node.play(anim)

func _hide_icon() -> void:
	anim_node.play("RESET")
