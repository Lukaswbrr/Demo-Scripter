class_name DemoScripter_RecollectionModule
extends DemoScripter_ExtraModule
## A [DemoScripter_ExtraModule] used for reading previous readed dialogue.

## If true, hides the recollection's dialogue node.
## Disable this in case you're using a [DemoScripter_MenuModule].
@export var default_right_click_menu: bool = true
## If true, uses a global class for storing recollection_readed_ids.
## Useful for level persistant.
@export var use_global_recollection: bool
## Once the [member recollection_readed_ids]'s size overpasses this value, it deletes
## the oldest item for freeing up space in memory.
## Set to -1 if you don't want a maximum limit.
@export var max_recollecion_items: int = -1

## The [RichTextLabel] dialogue node that will be used to display previous dialogue.
@onready var recollection_dialogue: RichTextLabel = $Dialogue
## If [member use_global_recollection] is true, uses [DemoScripter_RecollectionModule_Globals]'s
## [member DemoScripter_RecollectionModule_Globals.recollection_readed_ids] and
## [member DemoScripter_RecollectionModule_Globals.recollection_current_ids] instead.
## Used for persistance when changing scenes.
@onready var globals: DemoScripter_RecollectionModule_Globals = get_node_or_null("/root/RecollectionGlobal")

## If true, the recollection functionality for going to previous and next pages gets disabled.
var disabled: bool
## Checks if the player is currently on the recollection menu.
var on_recollection: bool

## Array of all readed dialogue's text.
var recollection_readed_ids: Array[String]
## The current id of [member recollection_readed_ids].
var recollection_current_id: int = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if default_right_click_menu and Input.is_action_just_pressed("right_click"):
		if not on_recollection:
			return
		
		recollection_dialogue.set_visible(!recollection_dialogue.visible)
	
	if disabled:
		return   
	
	if _main_visualnovel_scene == null:
		return
	
	if default_right_click_menu and !_main_visualnovel_scene.hud_node.visible:
		return
	
	# If it's on recollection and player presses left or scrolls down, it goes to the previous page
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("mouse_scroll_down"):
		if use_global_recollection:
			if ( globals.recollection_current_id - 1) >= 0 and on_recollection:
				globals.recollection_current_id -= 1
		else:
			if ( recollection_current_id - 1) >= 0 and on_recollection:
				recollection_current_id -= 1
		
		on_recollection = true
		
		if not recollection_dialogue.visible:
			show()
		
		if use_global_recollection:
			recollection_load_id(globals.recollection_current_id)
		else:
			recollection_load_id(recollection_current_id)
	
	# If it's on recollection and player presses next or scroll up, it goes to the next page
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("mouse_scroll_up"):
		if not on_recollection:
			return
		
		if use_global_recollection:
			if ( globals.recollection_current_id + 1 ) > globals.recollection_readed_ids.size() - 1:
				on_recollection = false
				_main_visualnovel_scene.pause_dialogue(false)
				hide()
				return
		else:
			if ( recollection_current_id + 1 ) > recollection_readed_ids.size() - 1:
				on_recollection = false
				_main_visualnovel_scene.pause_dialogue(false)
				hide()
				return
		
		if use_global_recollection:
			globals.recollection_current_id += 1
			recollection_load_id(globals.recollection_current_id)
			
		else:
			recollection_current_id += 1
			recollection_load_id(recollection_current_id)

## Connects the module.
## It awaits for [signal DemoScripter_VisualNovelScene.load_dialogue_finished] to be emitted and
## connects [signal DemoScripter_VisualNovelScene.dialogue_next_page] to 
## [method _on_main_scene_load_dialogue_finished].
func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	await _main_visualnovel_scene.load_dialogue_finished
	_main_visualnovel_scene.connect("dialogue_next_page", _on_main_scene_load_dialogue_finished)

## Appends the current readed dialogue to [member recollection_readed_ids].
func recollection_append() -> void:
	if use_global_recollection:
		globals.recollection_readed_ids.append(_dialogue_node.text)
		
		if (globals.recollection_current_id + 1) >= max_recollecion_items:
			return
		
		globals.recollection_current_id += 1
	else:
		recollection_readed_ids.append(_dialogue_node.text)
		
		if (recollection_current_id + 1) >= max_recollecion_items:
			return
		
		recollection_current_id += 1

## Deletes the oldest item in [member recollection_readed_ids].
## Used when [member recollection_readed_ids]'s size is equal or higher than
## [member max_recollection_items].
func recollection_delete_oldest() -> void:
	if max_recollecion_items == -1:
		return
	
	if use_global_recollection:
		if globals.recollection_readed_ids.size() >= max_recollecion_items:
			globals.recollection_readed_ids.remove_at(0)
	else:
		if recollection_readed_ids.size() >= max_recollecion_items:
			recollection_readed_ids.remove_at(0)

## Used when [signal DemoScripter_VisualNovelScene.load_dialogue_finished] is emitted.
func _on_main_scene_load_dialogue_finished(id: int) -> void:
	recollection_delete_oldest()
	recollection_append()

## Loads a recollection page via id.
## Returns true if successfully loaded.
func recollection_load_id(id: int) -> bool:
	if use_global_recollection:
		if globals.recollection_readed_ids.is_empty():
			return false
	else:
		if recollection_readed_ids.is_empty():
			return false
	
	on_recollection = true
	_main_visualnovel_scene.pause_dialogue(true)
	
	if use_global_recollection:
		recollection_dialogue.text = globals.recollection_readed_ids[id]
	else:	
		recollection_dialogue.text = recollection_readed_ids[id]
	show()
	
	return true

## Shows [member recollection_dialogue] and hides [member _dialogue_node].
func show() -> void:
	recollection_dialogue.set_visible(true)
	_dialogue_node.set_visible(false)

## Hides [member recollection_dialogue] and shows [member _dialogue_node].
func hide() -> void:
	recollection_dialogue.set_visible(false)
	_dialogue_node.set_visible(true)
