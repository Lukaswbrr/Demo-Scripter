class_name DemoScripter_ExtraModular
extends Node
## A general purpose module to be used for [DemoScripter_VisualNovelScene].

## The main [DemoScripter_VisualNovelScene] node.
var _main_visualnovel_scene
## The main dialogue node from [member _main_visualnovel_scene].
var _dialogue_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Connects the module to a [DemoScripter_VisualNovelScene] node.
func connect_module(node: DemoScripter_VisualNovelScene) -> void:
	_main_visualnovel_scene = node
	_dialogue_node = node.dialogue_node
	_connect_module(node)

## Virtual method of [method _connect_module].
## Overwrite this function for what should happen when the module has been connected.
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	pass
