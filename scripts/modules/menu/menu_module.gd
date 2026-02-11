class_name DemoScripter_MenuModule
extends Node
## A menu module base used for when the player presses right click on [DemoScripter_VisualNovelScene].

## The main [DemoScripter_VisualNovelScene] node.
var _main_visualnovel_scene: DemoScripter_VisualNovelScene
## The main dialogue node from [member _main_visualnovel_scene].
var _dialogue_node

## Emitted when [method show_menu] runs.
signal show_menu_signal
## Emitted when [method hide_menu] runs.
signal hide_menu_signal

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

## TODO: check if mode always is the correct process for enabled nodes
func _process(delta: float) -> void:
	_menu_process()

func show_menu() -> void:
	emit_signal("show_menu_signal")
	_show_menu()

func hide_menu() -> void:
	emit_signal("hide_menu_signal")
	_hide_menu()

func _menu_process() -> void:
	pass

## Connects the module to a [DemoScripter_VisualNovelScene] node.
func connect_module(node: DemoScripter_VisualNovelScene) -> void:
	_main_visualnovel_scene = node
	_dialogue_node = node.dialogue_node
	process_mode = PROCESS_MODE_ALWAYS
	_connect_module(node)

## Virtual method of [method show_menu].
## Overwrite this function for what should happen when the icon shows.
func _show_menu() -> void:
	pass

## Virtual method of [method hide_menu].
## Overwrite this function for what should happen when the icon hides.
func _hide_menu() -> void:
	pass

## Virtual method of [method _connect_module].
## Overwrite this function for what should happen when the module has been connected.
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	pass
