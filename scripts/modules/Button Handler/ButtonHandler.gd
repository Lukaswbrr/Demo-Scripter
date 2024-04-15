extends Control
class_name ButtonHandler

@export var main_scene: Node

## Custom Theme skin to all buttons created by this button handler by default
@export var buttons_skin: Theme

func _ready():
	assert(type_string(typeof(main_scene)) == "Object", "The main scene variable hasn't been defined!")

func button_container_create(set_id, custom_position = null):
	var container = VBoxContainer.new()
	var dialogue_text_node = get_node("../Dialogue")
	container.name = str(set_id)
	container.position = Vector2(dialogue_text_node.position.x + 10, dialogue_text_node.position.y + dialogue_text_node.size.y + 25)
	container.visible = false
	add_child(container)
	print("created set")

func button_set_appear(set_id, wait_signal = true):
	main_scene.fastskip_pause()
	update_container_pos(set_id)
	var container = get_container(set_id)
	
	if wait_signal:
		await(main_scene.text_animation_finished)
		main_scene.pause_dialogue(!main_scene.forced_paused)
		container.visible = !container.visible
	else:
		main_scene.pause_dialogue(!main_scene.forced_paused)
		container.visible = !container.visible

func create_button(buttonname, set_id = 1, function = null, theme: Theme = buttons_skin):
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
	
	assert(!main_scene == null, "The main scene variable hasn't been defined!!")
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = theme
	button.alignment = 0
	current_set.add_child(button)
	
	if !function == null:
		button.pressed.connect(function)
	
	print(current_set)
	print(buttonname)

func create_button_goto_set(buttonname, set = 1, set_id = 1, theme: Theme = buttons_skin):
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
	
	print(main_scene)
	
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		main_scene.fastskip_unpause()
		main_scene.load_dialogue_set(set, false)
		main_scene.pause_dialogue(!main_scene.forced_paused)
		current_set.visible = !current_set.visible
		)

func create_button_goto_id(buttonname, id = 1, set_id = 1, theme: Theme = buttons_skin ):
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
	
	var current_set = get_node(str(set_id))
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		main_scene.fastskip_unpause()
		main_scene.load_dialogue_start(id, 1, false, false, true)
		main_scene.pause_dialogue(!main_scene.forced_paused)
		current_set.visible = !current_set.visible
		)

func create_button_goto_scene(buttonname, scene, set_id = 1, theme: Theme = buttons_skin):
	if !get_container(set_id): # create container if it doesnt exist
		button_container_create(set_id)
	
	var current_set = get_container(set_id)
	
	# add buttons
	var button = Button.new()
	button.name = buttonname
	button.text = buttonname
	button.theme = theme
	button.alignment = 0
	current_set.add_child(button)
	
	button.pressed.connect(func():
		get_tree().change_scene_to_file(scene)
		)

func get_container(id):
	return get_node_or_null(str(id))

func get_button(name, id):
	return get_node_or_null(str(id) + "/" + name)

func update_container_pos(container):
	var dialogue_text_node = get_node("../Dialogue")
	var found_container = get_container(container)
	
	found_container.position = Vector2(dialogue_text_node.position.x + 10, dialogue_text_node.position.y + dialogue_text_node.size.y + 25)
