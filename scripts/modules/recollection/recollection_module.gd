class_name DemoScripter_RecollectionModule_ExtraModule
extends DemoScripter_ExtraModule

## If true, hides the recollection's dialogue node.
## Disable this in case you're using a [DemoScripter_MenuModule].
@export var default_right_click_menu: bool = true

@onready var recollection_dialogue: RichTextLabel = $Dialogue

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
	
	if Input.is_action_just_pressed("ui_left"):
		# If it's on recollection and player presses left, it goes to the previous page
		if ( recollection_current_id - 1) >= 0 and on_recollection:
			print("decreased")
			recollection_current_id -= 1
		
		on_recollection = true
		
		if not recollection_dialogue.visible:
			show()
		
		print("hey?")
		
		recollection_load_id()
	
	if Input.is_action_just_pressed("ui_right"):
		if not on_recollection:
			return
		
		if ( recollection_current_id + 1 ) > recollection_readed_ids.size() - 1:
			#recollection_current_id = recollection_readed_ids.size() - 1
			on_recollection = false
			_main_visualnovel_scene.pause_dialogue(false)
			hide()
			return
		
		recollection_current_id += 1
		recollection_load_id()

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	await _main_visualnovel_scene.load_dialogue_finished
	_main_visualnovel_scene.connect("dialogue_next_page", _on_main_scene_load_dialogue_finished)

func recollection_append():
	recollection_readed_ids.append(_dialogue_node.text)
	print("From recollection:" + recollection_readed_ids[recollection_readed_ids.size() - 1])
	recollection_current_id += 1

func _on_main_scene_load_dialogue_finished(id: int) -> void:
	recollection_append()
	var text = recollection_readed_ids[recollection_readed_ids.size() - 1] 
	
	#$Dialogue.set_text(text)

func recollection_load_id(id: int = recollection_current_id):
	if recollection_readed_ids.is_empty():
		return
	
	on_recollection = true
	_main_visualnovel_scene.pause_dialogue(true)
	
	recollection_dialogue.text = recollection_readed_ids[id]
	show()

func show():
	recollection_dialogue.set_visible(true)
	_dialogue_node.set_visible(false)

func hide():
	recollection_dialogue.set_visible(false)
	_dialogue_node.set_visible(true)
#
#func recollection_next():
	#if recollection_current_id + 1 > recollection_readed_ids.size():
		#print("ignore")
		#open_rightclick_menu()
	#else:
		#recollection_current_id += 1
		#recollection_dialogue.text = recollection_readed_ids[recollection_current_id]
		#print("next")
#
#func recollection_previous():
	#print("pressed")
	#if recollection_current_id - 1 <= 0:
		#print("ignore")
	#else:
		#recollection_current_id -= 1
		#recollection_dialogue.text = recollection_readed_ids[recollection_current_id]
		#print("previous")
#
#func recollection_clear(test = true):
	#if test:
		#await get_tree().create_timer(0.1).timeout
		#recollection_readed_ids.clear()
	#else:
		#recollection_readed_ids.clear()
	#recollection_current_id = 0
	#print(recollection_readed_ids)
