extends Node
class_name DemoScripter_BackgroundHandler

signal fade_in_finished
signal fade_out_finished
signal overlay_effect_added
signal overlay_effect_finished
signal background_transition_started
signal background_transition_finished

var _active_overlays: Array[Node]

# Makes it so instead of using Characters node, it uses a seperate node for overlay effects
@export var use_overlay_exclusive_node: bool 
@export var main_scene: DemoScripter_VisualNovelScene
@export var characters_node: Node
@export var overlay_node: Node # only use this if use_overlay_exclusive_node is enabled!


@onready var anim_player = $AnimationPlayer
@onready var background_color = $ColorRect
@onready var background_sprites = $Sprites
@onready var current_background = background_sprites.frame


func _ready() -> void:
	assert(type_string(typeof(main_scene)) == "Object", "The main scene variable hasn't been defined!")
	assert(type_string(typeof(characters_node)) == "Object", "The characters node variable hasn't been defined! Define a node that has all characters inside the characters node.")

#region NEW_FUNCS

func add_overlay_normal(shader_name: String, dict: Dictionary, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		add_overlay_normal_instant(shader_name, dict)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	add_overlay_normal_instant(shader_name, dict)
	
	await get_tree().create_timer(hold_in).timeout
	main_scene.dialogue_fade_in()

func add_overlay_normal_instant(shader_name: String, dict: Dictionary) -> void:
	var effect = load(shader_name)
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.set_material(effect)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	_add_active_overlay(color_overlay)
	
	for k in dict:
		color_overlay.get_material().set_shader_parameter(k, dict[k])

func add_overlay_persistant_instant(shader_name: String, dict: Dictionary) -> void:
	var effect = load(shader_name)
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.set_material(effect)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	color_overlay.set_meta("isPersistant", true)
	_add_active_overlay(color_overlay)
	
	for k in dict:
		color_overlay.get_material().set_shader_parameter(k, dict[k])

func set_active_overlay_normal_id(id: int, dict: Dictionary) -> void:
	for k in dict:
		_active_overlays[id].get_material().set_shader_parameter(k, dict[k])

func set_active_overlay_normal_tween_id(id: int, property: String, value, duration: float, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_active_overlay_normal_id(id, {property: value})
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	set_active_overlay_normal_tween_id_instant(id, property, value, duration)
	
	await get_tree().create_timer(duration + hold_in).timeout
	main_scene.dialogue_fade_in()

func set_active_overlay_normal_tween_id_instant(id: int, property: String, value, duration: float) -> void:
	var overlay = _active_overlays[id]
	
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "material:shader_parameter/" + property, value, duration)

func remove_overlay_normal_id(id: int, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		remove_overlay_normal_id_instant(id)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	remove_overlay_normal_id_instant(id)
	
	await get_tree().create_timer(hold_in).timeout
	main_scene.dialogue_fade_in()

func remove_overlay_normal_id_instant(id: int) -> void:
	_active_overlays[id].queue_free()
	_remove_active_overlay_id(id)

func remove_overlay_normal_id_instant_await(signalname, id: int):
	await signalname
	remove_overlay_normal_id_instant(id)
	print("yey")

func _add_active_overlay(node: Node) -> void:
	_active_overlays.append(node)

func _remove_active_overlay(node: Node) -> void:
	_active_overlays.erase(node)

func _remove_active_overlay_id(id: int) -> void:
	_active_overlays.remove_at(id)

func change_background_instant(index: int, group = null) -> void:
	if group is String:
		background_sprites.animation = group
	
	background_sprites.frame = index

func _check_persistant_amount_overlays() -> int:
	var amount: int
	
	for k in _active_overlays:
		if k.get_meta("isPersistant"):
			amount += 1
	
	return amount

func hide_characters() -> void:
	for k in characters_node.get_children():
		if k is DemoScripter_VisualNovelCharacter:
			main_scene.hide_character_instant(k, 0)

func show_characters() -> void:
	for k in characters_node.get_children():
		if k is DemoScripter_VisualNovelCharacter:
			main_scene.show_character_instant(k, 0)

func hide_background() -> void:
	background_sprites.set_visible(false)

func show_background() -> void:
	background_sprites.set_visible(true)

func change_background_transition_new_instant(index: int, group: String, duration: float, hold_signal: float = 0) -> void:
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var new_background = AnimatedSprite2D.new()
	new_background.sprite_frames = background_sprites.sprite_frames
	new_background.animation = group
	new_background.frame = index
	new_background.modulate = Color(new_background.modulate, 0)
	new_background.scale = background_sprites.scale
	new_background.transform = background_sprites.transform
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(new_background)
	else:
		characters_node.add_child(new_background)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(new_background, -persistant_overlays - 1)
		else:
			characters_node.move_child(new_background, -persistant_overlays - 1)
	
	var tween = get_tree().create_tween()
	tween.tween_property(new_background, "modulate", Color(new_background.modulate, 1), duration)
	tween.tween_callback(hide_characters)
	tween.tween_callback(background_sprites.set_frame.bind(index))
	tween.tween_callback(background_sprites.set_animation.bind(group))
	tween.tween_callback(new_background.queue_free)
	tween.tween_callback(emit_signal.bind("background_transition_finished")).set_delay(hold_signal)

func change_background_transition_new(index: int, group: String, duration: float, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0, hold_signal: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_transition_new_instant(index, group, 0)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	change_background_transition_new_instant(index, group, duration)
	
	await get_tree().create_timer(duration + hold_in).timeout
	
	main_scene.dialogue_fade_in()


func background_effect_in_instant(shader_name: String, property: String, value: float, duration: float, rotation: float, hold: float = 0) -> void:
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = Color(background_color.modulate)
	color_overlay.pivot_offset = Vector2(color_overlay.size.x / 2, color_overlay.size.y / 2)
	color_overlay.set_rotation(rotation)
	color_overlay.set_material(effect)
	#resize_rect_to_fullscreen(color_overlay)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	tween.tween_callback(hide_background)
	tween.tween_callback(hide_characters)
	tween.tween_callback(color_overlay.queue_free)
	if hold > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(hold)
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

func background_effect_in(shader_name: String, property: String, value: float, duration: float, rotation: float = 0, fast_skipable: bool = true, hold: float = 0, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		hide_background()
		hide_characters()
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	background_effect_in_instant(shader_name, property, value, duration, rotation, hold)
	
	await overlay_effect_finished
	main_scene.dialogue_fade_in()

func background_fade_in(duration: float, fast_skipable: bool = true, hold_in: float = 0, hold: float = 0, hold_out: float = 0, hide_character: bool = true, hide_background: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		#set_background_modulate_instant(newColor)
		hide_characters()
		hide_background()
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	background_fade_in_instant(duration, hold, hide_background, hide_character)
	
	if hold_in < 0:
		return
	else:
		await fade_in_finished
		main_scene.dialogue_fade_in()

func background_fade_out(duration: float, fast_skipable: bool = true, hold_in: float = 0, hold: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		#set_background_modulate_instant(newColor)
		show_background()
		return
		
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	background_fade_out_instant(duration, hold)
	
	if hold_in < 0:
		return
	else:
		await fade_out_finished
		main_scene.dialogue_fade_in()

func background_fade_in_instant(duration: float, hold: float = 0, _hide_background: bool = true, _hide_characters: bool = true) -> void:
	var persistant_overlays = _check_persistant_amount_overlays()
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = Color(background_color.modulate, 0)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
		
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "modulate", Color(color_overlay.modulate, 1), duration)
	if _hide_background:
		tween.tween_callback(hide_background)
	if _hide_characters:
		tween.tween_callback(hide_characters)
	tween.tween_callback(color_overlay.queue_free)
	if hold > 0:
		tween.tween_callback(emit_signal.bind("fade_in_finished")).set_delay(hold)
	else:
		tween.tween_callback(emit_signal.bind("fade_in_finished"))
	

func background_fade_out_instant(duration: float, hold: float = 0) -> void:
	 # BUG: Somehow, the fadeout tween doesnt work
	var persistant_overlays = _check_persistant_amount_overlays()
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = Color(background_color.modulate)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
		
	var tween = get_tree().create_tween()
	tween.tween_callback(show_background)
	tween.tween_property(color_overlay, "modulate", Color(color_overlay.modulate, 0), duration)
	tween.tween_callback(color_overlay.queue_free)
	if hold > 0:
		tween.tween_callback(emit_signal.bind("fade_out_finished")).set_delay(hold)
	else:
		tween.tween_callback(emit_signal.bind("fade_out_finished"))

func background_effect_out_instant(shader_name: String, property: String, value: float, duration: float, rotation: float = 0, hold: float = 0) -> void:
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = Color(background_color.modulate)
	color_overlay.set_rotation(rotation)
	color_overlay.set_material(effect)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
	
	show_background()
	#change_background_instant(3, "default")
	#show_characters()
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	tween.tween_callback(color_overlay.queue_free)
	if hold > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(hold)
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

func background_effect_out_change_instant(index: int, group: String, shader_name: String, property: String, value: float, duration: float, rotation: float = 0, hold: float = 0) -> void:
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = Color(background_color.modulate)
	color_overlay.set_rotation(rotation)
	color_overlay.set_material(effect)
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
	
	show_background()
	change_background_instant(index, group)
	#show_characters()
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	tween.tween_callback(color_overlay.queue_free)
	if hold > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(hold)
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

func background_effect_out(shader_name: String, property: String, value: float, duration: float, rotation: float = 0, fast_skipable: bool = true, hold: float = 0, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		show_background()
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	background_effect_out_instant(shader_name, property, value, duration, rotation, hold)
	await overlay_effect_finished
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	main_scene.dialogue_fade_in()

func background_effect_out_change(index: int, group: String, shader_name: String, property: String, value: float, duration: float, rotation: float, fast_skipable: bool = true, hold: float = 0, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		show_background()
		change_background_instant(index, group)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
	
	background_effect_out_change_instant(index, group, shader_name, property, value, duration, rotation, hold)
	await overlay_effect_finished
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	main_scene.dialogue_fade_in()

func change_background_effect(index: int, group: String, shader_name: String, property: String, value_in: float, value_out: float, duration_in: float, duration_out: float, fast_skipable: bool = true, hold: float = 0, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		hide_characters()
		change_background_instant(index, group)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	#background_effect_out_instant(shader_name, property, value, duration, hold)
	background_effect_in_instant(shader_name, property, value_in, duration_in, hold)
	await overlay_effect_finished
	
	background_effect_out_change_instant(index, group, shader_name, property, value_out, duration_out, hold_out)
	await overlay_effect_finished
	
	main_scene.dialogue_fade_in()

func change_background_fade_new(index: int, group, fadeout: float, hold_out: float, fadein: float, hold_in: float, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_instant(index, group)
		return
	
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = background_color.color
	color_overlay.modulate = background_color.modulate
	color_overlay.modulate.a = 0
	
	characters_node.add_child(color_overlay)
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "modulate", Color(color_overlay.modulate.r, color_overlay.modulate.g, color_overlay.modulate.b, 1), fadeout)
	tween.tween_callback(change_background_instant.bind(index, group)).set_delay(hold_out)
	tween.tween_property(color_overlay, "modulate", Color(color_overlay.modulate.r, color_overlay.modulate.g, color_overlay.modulate.b, 0), fadein)
	tween.tween_callback(main_scene.dialogue_fade_in).set_delay(hold_in)

func rect_blink(fadein: float, fadeout: float, fast_skipable: bool = true, hold_in: float = 0, hold_1: float = 0, hold_2: float = 0, hold_out: float = 0, hide_background_in: bool = true, hide_character_in: bool = false) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		return
	
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	background_fade_in_instant(fadein, hold_1, hide_background_in, hide_character_in)
	await fade_in_finished
	background_fade_out_instant(fadeout, hold_2)
	await fade_out_finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
		main_scene.dialogue_fade_in()
	elif hold_out < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_rect_color_instant(newColor: Color) -> void:
	background_color.color = newColor

func set_rect_color(newColor: Color, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_rect_color_instant(newColor)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	set_rect_color_instant(newColor)
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
		main_scene.dialogue_fade_in()
	elif hold_out < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_rect_color_transition(newColor: Color, duration: float, fast_skipable: bool = true, hold_in: float = 0, hold_out: float = 0 ) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_rect_color_instant(newColor)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if hold_in > 0:
		await get_tree().create_timer(hold_in).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_property(background_color, "color", newColor, duration)
	await tween.finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
		main_scene.dialogue_fade_in()
	elif hold_out < 0:
		return
	else:
		main_scene.dialogue_fade_in()

#endregion

#region OBSOLETE

# OLD STUFF BELOW

func change_background(index: int, group = null, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_instant(index, group)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	change_background_instant(index, group)
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func change_background_fade(index: int, group, fadeout: float, hold_out: float, fadein: float, hold_in: float, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_instant(index, group)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	background_fadeout_instant(fadeout)
	await get_tree().create_timer(fadeout + hold_out).timeout
	change_background_instant(index, group)
	background_fadein_instant(fadein)
	await get_tree().create_timer(fadein + hold_in).timeout
	main_scene.dialogue_fade_in()

func change_background_transition(index: int, group, duration: float, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_instant(index, group)
		return
	
	var old_background = background_sprites
	var new_background = AnimatedSprite2D.new()
	old_background.set_name("OldSprites")
	new_background.set_name("Sprites")
	new_background.sprite_frames = old_background.sprite_frames
	if group is String:
		new_background.animation = group
	
	new_background.frame = index
	new_background.position = old_background.position
	new_background.scale = old_background.scale
	new_background.set_modulate(Color(old_background.modulate.r, old_background.modulate.g, old_background.modulate.b, 0))
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	add_child(new_background)
	background_sprites = new_background
	var tween = get_tree().create_tween()
	#tween1.tween_property(old_background, "modulate", Color(old_background.modulate.r, old_background.modulate.g, old_background.modulate.b, 0), duration)
	tween.tween_property(new_background, "modulate", Color(new_background.modulate.r, new_background.modulate.g, new_background.modulate.b, 1), duration)
	
	await tween.finished
	old_background.queue_free()
	await get_tree().create_timer(0.15).timeout
	main_scene.dialogue_fade_in()

func set_background_modulate_instant(newColor: Color) -> void:
	background_sprites.set_modulate(newColor)

func resize_rect_to_fullscreen(node: Control) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var original_size = node.size
	
	# Calculate the scaling factor needed
	var max_dimension = max(viewport_size.x, viewport_size.y)
	var scale_factor = (max_dimension * sqrt(2)) / min(original_size.x, original_size.y)
	
	node.scale = Vector2.ONE * scale_factor
	node.pivot_offset = original_size / 2
	node.  position = (viewport_size - original_size * scale_factor) / 2

func set_background_modulate_instant_all(newColor: Color) -> void:
	var characters = []
	for k in main_scene.get_child_count():
		if main_scene.get_child(k) is DemoScripter_VisualNovelCharacter:
			characters.append(main_scene.get_child(k))
	
	background_sprites.set_modulate(newColor)
	for k in characters:
		k.set_modulate(newColor)

func set_background_modulate_transition(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_background_modulate_instant(newColor)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", newColor, duration)
	
	await tween.finished
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_background_modulate_transition_all(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_background_modulate_instant_all(newColor)
		return
	
	var characters = []
	for k in main_scene.get_child_count():
		if main_scene.get_child(k) is DemoScripter_VisualNovelCharacter:
			characters.append(main_scene.get_child(k))
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", newColor, duration)
	for k in characters:
		k.set_modulate_transition(newColor, duration)
	
	await tween.finished
	
	if hold > 0:
		await get_tree().create_timer(0.15).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_background_modulate(newColor: Color, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_background_modulate_instant(newColor)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	set_background_modulate_instant(newColor)
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func background_fadein_instant(duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration)

func background_fadein(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

func background_fadein_all(duration: float, hold: float = 0) -> void: 
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

func background_fadeout_instant(duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration)

func background_fadeout(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

func background_fadeout_all(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

func rect_blink_old(fadein: float, hold_in: float, fadeout: float, hold_out: float) -> void:
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(background_color, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), fadein)
	await tween.finished
	
	if hold_out > 0:
		await get_tree().create_timer(hold_out).timeout
		main_scene.dialogue_fade_in()
	elif hold_out < 0:
		return
	else:
		main_scene.dialogue_fade_in()



func set_overlay_modulate(newColor: Color, hold: float, overlay: ColorRect, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_overlay_modulate_instant(newColor, overlay)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	set_overlay_modulate_instant(newColor, overlay)
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_overlay_modulate_transition(newColor: Color, hold: float, duration: float, overlay: ColorRect, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_overlay_modulate_instant(newColor, overlay)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "color", newColor, duration)
	await tween.finished
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_overlay_modulate_instant(newColor: Color, overlay: ColorRect) -> void:
	overlay.set_modulate(newColor)

#endregion
