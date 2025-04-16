class_name DemoScripter_ExtraModular
extends Node

var _main_visualnovel_scene
var _dialogue_node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func connect_module(node: DemoScripter_VisualNovelScene) -> void:
	_main_visualnovel_scene = node
	_dialogue_node = node.dialogue_node
	_connect_module(node)

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	pass
