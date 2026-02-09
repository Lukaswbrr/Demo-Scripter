class_name DemoScripter_IconModule
extends Node

## Module for icon functionality

## The icon node that this module will target.
## Must be set, otherwise it will throw a assert error!
@export var icon_node: Node

## The main [DemoScripter_VisualNovelScene].
var _main_visualnovel_scene
## The main dialogue node.
var _dialogue_node

## Emitted when [method show_icon] runs.
signal show_icon_signal
## Emitted when [method hide_icon] runs.
signal hide_icon_signal

func _ready() -> void:
	assert(icon_node != null, "The icon node must be setted!")

## Shows the icon.
func show_icon() -> void:
	emit_signal("show_icon_signal")
	_show_icon()

## Hides the icon.
func hide_icon() -> void:
	emit_signal("hide_icon_signal")
	_hide_icon()

## Connects this module to a [DemoScripter_VisualNovelScene] node.
func connect_module(node: DemoScripter_VisualNovelScene) -> void:
	_main_visualnovel_scene = node
	_dialogue_node = node.dialogue_node
	_connect_module(node)

## Virtual method of [method _show_icon].
## Overwrite this function for what should happen when the icon shows.
func _show_icon() -> void:
	pass

## Virtual method of [method _hide_icon].
## Overwrite this function for what should happen when the icon hides.
func _hide_icon() -> void:
	pass

## Virtual method of [method _connect_module].
## Overwrite this function for what should happen when the module has been connected.
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	pass
