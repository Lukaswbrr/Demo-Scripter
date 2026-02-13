extends DemoScripter_MenuModule
## A menu made using [DemoScripter_MenuModule] inspired by Tsukihime (2000).

## How much [member DemoScripter_VisualNovelScene.dark_backgroundnode]'s alpha will be subtracted
## when the menu is active. 
@export var alpha_subtraction_darkbackground: int = 30
## The icon node of [DemoScripter_VisualNovelScene].
## Can be any Node or [DemoScripter_IconModule].
@export var icon: Node
## The [DemoScripter_RecollectionModule].
## If empty, the recollection button does not appear.
@export var recollection: DemoScripter_RecollectionModule

## The [member DemoScripter_VisualNovelScene.dark_backgroundnode]. Only gets it when
## [method DemoScripter_MenoModule.connect_signal].
@onready var darkbackground_node: ColorRect
## Gets the [member DemoScripter_VisualNovelScene.dark_backgroundnode]'s modulate the moment
## [method DemoScripter_MenuModule.connect_module] has been ran.
## This does not change in case [member DemoScripter_VisualNovelScene.dark_backgroundnode] gets
## changed afterwards!
@onready var darkbackground_old_color: Color

## State of the menu.
## If true, the menu is open.
## If false, the menu is closed.
var active: bool
## Checks if the [member DemoScripter_VisualNovelScene.dark_backgroundnode] is hidden or not.
## True if invisible, false if visible.
var darkbackground_hidden: bool

func _ready() -> void:
	# Runs the _ready() function frmo [DemoScripter_MenuModule]
	
	super()
	
	# if recollection hasnt been found, sets the button of recollection to invisible.
	if !recollection:
		$VBoxContainer/Recollection.set_visible(false)

## Shows the recollection button.
func show_recollection() -> void:
	if !recollection:
		return
	
	recollection.show()

## Hides the recollection button.
func hide_recollection() -> void:
	if !recollection:
		return
	
	recollection.hide()

## Show menu functionality.
func _show_menu() -> void:
	if icon:
		icon.set_visible(false)
	
	recollection.disabled = true
	_dialogue_node.set_visible(false)
	darkbackground_node.set_color(darkbackground_old_color - Color8(0, 0, 0, alpha_subtraction_darkbackground))
	
	self.visible = true

## Show hide functionality.
func _hide_menu() -> void:
	if icon:
		icon.set_visible(true)
	
	recollection.disabled = false
	_dialogue_node.set_visible(true)
	darkbackground_node.set_color(darkbackground_old_color + Color8(0, 0, 0, alpha_subtraction_darkbackground))
	
	self.visible = false

## Connects module
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	darkbackground_node = _main_visualnovel_scene.darkbackground_node
	darkbackground_old_color = darkbackground_node.color

## The menu process that will be during _process.
func _menu_process() -> void:
	if Input.is_action_just_pressed("right_click"):
		if darkbackground_hidden:
			darkbackground_hidden = false
			_main_visualnovel_scene.hud_node.visible = !darkbackground_hidden
			_hide_menu()
			return
		
		if recollection.on_recollection:
			recollection.hide()
			recollection.on_recollection = false
			_main_visualnovel_scene.pause_dialogue(false)
			return
		
		active = !active
		
		if active:
			_show_menu()
			return
		
		_hide_menu()

## Gets executed when DisplayImage button gets pressed.
func _on_display_image_pressed() -> void:
	active = false
	darkbackground_hidden = true
	_main_visualnovel_scene.hud_node.visible = !darkbackground_hidden

## Gets executed when Recollection button gets pressed.
func _on_recollection_pressed() -> void:
	if recollection.is_empty():
		active = false
		hide_menu()
		return
	
	show_recollection()
	active = false
	hide_menu()
	recollection.previous()
	recollection.disabled = false
