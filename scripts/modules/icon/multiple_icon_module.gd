class_name DemoScripter_MultipleIcon_IconModule
extends DemoScripter_IconModule

var icon_anim: AnimationPlayer

var icon_texture: TextureRect
@export var line_icon: Texture2D
@export var page_icon: Texture2D
@export var reset_icon_anim_on_load: bool = true
 
func reset_icon_anim():
	icon_anim.stop()
	icon_anim.play("reset_manual")

func _show_icon() -> void:
	if _main_visualnovel_scene.dialogue_dictionary.has(_main_visualnovel_scene.dialogue_index + 1) and _main_visualnovel_scene.dialogue_dictionary[_main_visualnovel_scene.dialogue_index + 1][2] == _main_visualnovel_scene.dialogue_current_id:
		icon_texture.set_texture(line_icon)
		icon_anim.play("line_icon")
	else:
		icon_texture.set_texture(page_icon)
		icon_anim.play("page_icon")
	
	icon_node.set_visible(true)

func _hide_icon() -> void:
	icon_node.set_visible(false)
	reset_icon_anim()

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	icon_anim = icon_node.get_node("AnimationPlayer")
	icon_texture = icon_node.get_node("TextureRect")
	
	if reset_icon_anim_on_load:
		reset_icon_anim()
