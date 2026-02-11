class_name DemoScripter_RecollectionModule_ExtraModule
extends DemoScripter_ExtraModule

## If true, hides the recollection's dialogue node.
## Disable this in case you're using a [DemoScripter_MenuModule].
@export var default_right_click_menu: bool = true
## If true, uses a global class for storing recollection_readed_ids.
## Useful for level persistant.
@export var use_global_recollection: bool
## Once the [member recollection_readed_ids]'s size overpasses this value, it deletes
## the oldest item for freeing up space in memory.
## Set to -1 if you don't have a maximum limit.
@export var max_recollecion_items: int = -1
@onready var recollection_dialogue: RichTextLabel = $Dialogue
@onready var globals: DemoScripter_RecollectionModule_ExtraModule_Globals = get_node_or_null("/root/RecollectionGlobal")

var disabled: bool
var on_recollection: bool

var recollection_readed_ids: Array[String]
var recollection_current_id: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if default_right_click_menu and Input.is_action_just_pressed("right_click"):
		if not on_recollection:
			return
		
		recollection_dialogue.set_visible(!recollection_dialogue.visible)
	
	if disabled:
		return   
	
	if default_right_click_menu and !_main_visualnovel_scene.hud_node.visible:
		return
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("mouse_scroll_down"):
		# If it's on recollection and player presses left, it goes to the previous page
		if use_global_recollection:
			if ( globals.recollection_current_id - 1) >= 0 and on_recollection:
				print("decreased")
				globals.recollection_current_id -= 1
		else:
			if ( recollection_current_id - 1) >= 0 and on_recollection:
				print("decreased")
				recollection_current_id -= 1
		
		on_recollection = true
		
		if not recollection_dialogue.visible:
			show()
		
		print("hey?")
		
		if use_global_recollection:
			recollection_load_id(globals.recollection_current_id)
		else:
			recollection_load_id(recollection_current_id)
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("mouse_scroll_up"):
		if not on_recollection:
			return
		
		if use_global_recollection:
			if ( globals.recollection_current_id + 1 ) > globals.recollection_readed_ids.size() - 1:
				#recollection_current_id = recollection_readed_ids.size() - 1
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

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	await _main_visualnovel_scene.load_dialogue_finished
	_main_visualnovel_scene.connect("dialogue_next_page", _on_main_scene_load_dialogue_finished)

func recollection_append():
	if use_global_recollection:
		globals.recollection_readed_ids.append(_dialogue_node.text)
		print("From recollection:" + globals.recollection_readed_ids[globals.recollection_readed_ids.size() - 1])
		
		if (globals.recollection_current_id + 1) >= max_recollecion_items:
			return
		
		globals.recollection_current_id += 1
	else:
		recollection_readed_ids.append(_dialogue_node.text)
		print("From recollection:" + recollection_readed_ids[recollection_readed_ids.size() - 1])
		
		if (recollection_current_id + 1) >= max_recollecion_items:
			return
		
		recollection_current_id += 1

func recollection_delete_oldest():
	if max_recollecion_items == -1:
		return
	
	if use_global_recollection:
		if globals.recollection_readed_ids.size() >= max_recollecion_items:
			globals.recollection_readed_ids.remove_at(0)
	else:
		if recollection_readed_ids.size() >= max_recollecion_items:
			recollection_readed_ids.remove_at(0)

func _on_main_scene_load_dialogue_finished(id: int) -> void:
	recollection_delete_oldest()
	recollection_append()

func recollection_load_id(id: int):
	if use_global_recollection:
		if globals.recollection_readed_ids.is_empty():
			return
	else:
		if recollection_readed_ids.is_empty():
			return
	
	on_recollection = true
	_main_visualnovel_scene.pause_dialogue(true)
	
	if use_global_recollection:
		recollection_dialogue.text = globals.recollection_readed_ids[id]
	else:	
		recollection_dialogue.text = recollection_readed_ids[id]
	show()

func show():
	recollection_dialogue.set_visible(true)
	_dialogue_node.set_visible(false)

func hide():
	recollection_dialogue.set_visible(false)
	_dialogue_node.set_visible(true)
