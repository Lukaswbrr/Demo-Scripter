class_name DemoScripter_MultipleIcon_IconModule
extends DemoScripter_IconModule
## A [DemoScripter_IconModule] for multiple icons.
## Contains a line icon and a page icon. (when the is the last text of a dialogue's group)

## The icon's [AnimationPlayer].
var icon_anim: AnimationPlayer

## The current icon's texture.
var icon_texture: TextureRect
## The texture to be used for lines.
@export var line_icon: Texture2D
## The texture to be used at the end of a dialogue's group.
@export var page_icon: Texture2D
@export var reset_icon_anim_on_load: bool = true
 
## Resets the icon.
func reset_icon_anim():
	icon_anim.stop()
	icon_anim.play("reset_manual")

## Shows the icon.
func _show_icon() -> void:
	if _main_visualnovel_scene.dialogue_dictionary.has(_main_visualnovel_scene.dialogue_index + 1) and _main_visualnovel_scene.dialogue_dictionary[_main_visualnovel_scene.dialogue_index + 1][2] == _main_visualnovel_scene.dialogue_current_id:
		icon_texture.set_texture(line_icon)
		icon_anim.play("line_icon")
	else:
		icon_texture.set_texture(page_icon)
		icon_anim.play("page_icon")
	
	icon_node.set_visible(true)

## Hides the icon.
func _hide_icon() -> void:
	icon_node.set_visible(false)
	reset_icon_anim()

## Connects the module to a [DemoScripter_VisualNovelScene] node.
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	icon_anim = icon_node.get_node("AnimationPlayer")
	icon_texture = icon_node.get_node("TextureRect")
	
	if reset_icon_anim_on_load:
		reset_icon_anim()
