class_name DemoScripter_IconModule
extends Node

## Module for icon functionality

@export var icon_node: Node

var _main_visualnovel_scene
var _dialogue_node

signal show_icon_signal
signal hide_icon_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(icon_node != null, "The icon node must be setted!")

func show_icon() -> void:
	emit_signal("show_icon_signal")
	_show_icon()

func hide_icon() -> void:
	emit_signal("hide_icon_signal")
	_hide_icon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func connect_module(node: DemoScripter_VisualNovelScene) -> void:
	_main_visualnovel_scene = node
	_dialogue_node = node.dialogue_node
	_connect_module(node)

func _show_icon() -> void:
	pass

func _hide_icon() -> void:
	pass

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	pass
