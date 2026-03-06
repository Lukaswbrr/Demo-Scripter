class_name DemoScripter_ButtonHandler
extends Control
## Module for handling buttons.
##
## Module for handling buttons to be used with [DemoScripter_VisualNovelScene].

## Emits when [method button_set_appear] has been triggered.
signal button_set_appeared(set_id: int)

## The main [DemoScripter_VisualNovelScene] node.
## Must be set, otherwise will throw a assert error.
@export var main_scene: DemoScripter_VisualNovelScene

## Custom theme skin to all buttons created by this button handler by default.
@export var buttons_skin: Theme

## How much X position offset will the buttons have inside a button group.
@export var button_container_position_x_offset: int = 10
## How much Y position offset will the buttons have inside a button group.
@export var button_container_position_y_offset: int = 25

## The current set ID used for [method button_container_create]
var current_create_set_id: String

func _ready() -> void:
	assert(type_string(typeof(main_scene)) == "Object", "The main scene variable hasn't been defined!")


# TODO: custom position parameter is not used.
# Rework on v1.0.0.
## Creates a button group.
## [br]
## [br]
## [param set_id] is the name of the button group. By default, uses the 
## [member current_create_set_id] target.
func button_container_create(set_id: String, _custom_position = null) -> void:
	var container = VBoxContainer.new()
	var dialogue_text_node = get_node("../Dialogue")
	container.name = set_id
	container.set_position(Vector2(dialogue_text_node.position.x + button_container_position_x_offset, dialogue_text_node.position.y + dialogue_text_node.size.y + button_container_position_y_offset))
	container.visible = false
	add_child(container)

## Makes a button group appear.
## [br]
## [br]
## [param set_id] is the button group created by [method button_container_create] that will appear.
## By default, it uses the [member current_create_set_id] target.
## [br]
## If [param wait_signal] is true, it awaits for 
## [signal DemoScripter_VisualNovelScene.text_animation_finished] from [member main_scene] to be 
## emitted.
func button_set_appear(set_id: String = current_create_set_id, wait_signal: bool = true) -> void:
	emit_signal("button_set_appeared", set_id)
	main_scene.fastskip_pause()
	update_container_pos(set_id)
	var container = get_container(set_id)
	
	for button in get_container(set_id).get_child_count():
		var button_found = get_container(set_id).get_child(button)
		
		if !button_found.has_meta("condition"):
			#print("Didn't find condition!")
			continue
		
		button_found.set_meta("condition_value", button_found.get_meta("condition").call())
		button_found.set_visible(button_found.get_meta("condition_value"))
		#print("Found condition!")
	
	if wait_signal:
		await(main_scene.text_animation_finished)
		main_scene.pause_dialogue(true)
		container.visible = true
	else:
		main_scene.pause_dialogue(true)
		container.set_visible(true)

## Creates a button.
## [br]
## [br]
## [param buttonname] is the name of the button.
## [br]
## Once the button has been clicked, [param function] will execute.
## [br]
## [param set_id] is what button group this button belongs. By default, uses the 
## [member current_create_set_id] target.
## [br]
## The [Theme] this button will have. By default, uses the [member buttons_skin] theme.
func create_button(buttonname: String, function: Callable = func(): return, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	if !function == null:
		button.pressed.connect(function)
	
	#print(current_set)
	#print(buttonname)

## Creates a button that only appears if [param condition] returns true.
## [br]
## [br]
## [param buttonname] is the name of the button.
## [br]
## If [param condition] returns true, the button appears.
## [br]
## Once the button has been clicked, [param function] will execute.
## [br]
## [param set_id] is what button group this button belongs. By default, uses the 
## [member current_create_set_id] target.
## [br]
## [param button_theme] sets the [Theme] this button will have. By default, uses the [member buttons_skin] theme.
func create_button_condition(buttonname: String, condition: Callable, function: Callable = func(): return, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.set_meta("condition", condition)
	button.set_meta("condition_value", condition.call())
	
	if !function == null:
		button.pressed.connect(function)
	
	#print(current_set)
	#print(buttonname)
## TODO: add verification if a set actually exists.
## work on this feature in v1.0.0.
func create_button_goto_set(buttonname: String, set: String, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
		
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		goto_set(set, set_id)
		)

func create_button_goto_set_condition(buttonname: String, condition: Callable, set: String, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.set_meta("condition", condition)
	button.set_meta("condition_value", condition.call())
	
	button.pressed.connect(func():
		goto_set(set, set_id)
		)

func create_button_goto_id(buttonname: String, id: int = 1, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
		
	
	var current_set = get_node(str(set_id))
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		goto_id(id, set_id)
		)

func create_button_goto_id_condition(buttonname: String, condition: Callable, id: int = 1, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
		
	
	var current_set = get_node(str(set_id))
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.set_meta("condition", condition)
	button.set_meta("condition_value", condition.call())
	
	button.pressed.connect(func():
		goto_id(id, set_id)
		)

func create_button_goto_scene_condition(buttonname: String, condition: Callable, scene, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
		
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.set_meta("condition", condition)
	button.set_meta("condition_value", condition.call())
	
	button.pressed.connect(func():
		get_tree().change_scene_to_file(scene)
		)

func create_button_goto_scene(buttonname: String, scene, set_id: String = current_create_set_id, button_theme: Theme = buttons_skin) -> void:
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
		_set_current_set_id(set_id)
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = button_theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		get_tree().change_scene_to_file(scene)
		)

func goto_set(dialogue_set: String, set_button: String) -> void:
	var set_button_found = get_container(set_button)
	main_scene.fastskip_unpause()
	main_scene.load_dialogue_set(dialogue_set, false)
	main_scene.pause_dialogue(!main_scene.forced_paused)
	set_button_found.visible = !set_button_found.visible

## @deprecated: Doesn't seem useful. Will be reworked in v1.0.0.
func goto_id(dialogue_id: int, set_button: String) -> void:
	var set_button_found = get_container(set_button)
	main_scene.fastskip_unpause()
	main_scene.load_dialogue_start(dialogue_id, "start", false, false, true)
	main_scene.pause_dialogue(!main_scene.forced_paused)
	set_button_found.visible = !set_button_found.visible

func set_button_visible(value: bool, name: String, id: String) -> void:
	get_button(name, id).set_visible(value)

func remove_button(name: String, id: String) -> void:
	get_button(name, id).queue_free()

func get_container(id: String):
	return get_node_or_null(id)

func get_button(name: String, id: String):
	return get_node_or_null(id + "/" + name)

func update_container_pos(container: String) -> void:
	var dialogue_text_node = get_node("../Dialogue")
	var found_container = get_container(container)
	
	found_container.set_position(Vector2(dialogue_text_node.position.x + button_container_position_x_offset, dialogue_text_node.position.y + dialogue_text_node.size.y + button_container_position_y_offset))

func _set_current_set_id(id: String) -> void:
	current_create_set_id = id
