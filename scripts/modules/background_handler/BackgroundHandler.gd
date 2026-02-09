extends Node
class_name DemoScripter_BackgroundHandler
## Module for handling backgrounds.
##
## Module for handling backgrounds to be used with [DemoScripter_VisualNovelScene].

## Emits when the background finishes fading in. Used in [method background_fade_in].
signal fade_in_finished
## Emits when the background finishes fading out. Used in [method background_fade_out].
signal fade_out_finished
## Emits when an overlay effect has been added.
## @experimental: This never gets emitted. Will be worked in v1.0.0.
signal overlay_effect_added
## Emits when an overlay effect has been finished.
## @experimental: This seems inconsistent because it only gets emitted on [method background_effect_in] instead of overlay functions. Will be reworked in v1.0.0.
signal overlay_effect_finished
## Emits when a background transitions has been started.
## @experimental: This never gets emitted. Will be worked in v1.0.0.
signal background_transition_started
## Emits when a background transitions has been finished.
## [change_background_transition] emits this when background transition is finished.
signal background_transition_finished

## The current active overlays added by [method _add_active_overlay].
var _active_overlays: Array[Node]

## If this is true, it uses [member overlay_node] instead of background node for handling with
## overlay effects.
@export var use_overlay_exclusive_node: bool
## The [DemoScripter_VisualNovelScene] scene. Must be set otherwise it will throw a error!
@export var main_scene: DemoScripter_VisualNovelScene
## The node where all the [DemoScripter_VisualNovelCharacter] is on.
## Must be set otherwise it will throw a error!
@export var characters_node: Node
## The node where the overlay effects created by overlay functions will be. 
## [member use_overlay_exclusive_node] must be true!
@export var overlay_node: Node # only use this if use_overlay_exclusive_node is enabled!

## The [AnimationPlayer] of the background node.
## @experimental: This never gets used. May be reworked or removed in v1.0.0.
@onready var anim_player = $AnimationPlayer
## The [ColorRect] used before the [member background_sprites] which is used for plain colors.
@onready var background_color = $ColorRect
## The background sprites.
@onready var background_sprites = $Sprites
## The current background of [member background_sprites]
## @experimental: This never gets used. Will be reworked in v1.0.0.
@onready var current_background = background_sprites.frame

func _ready() -> void:
	assert(type_string(typeof(main_scene)) == "Object", "The main scene variable hasn't been defined!")
	assert(type_string(typeof(characters_node)) == "Object", "The characters node variable hasn't been defined! Define a node that has all characters inside the characters node.")

#region OVERLAYS

## Adds a overlay effect.
## [br]
## [br]
## [param shader_name] is the [Shader] file path.
## [br]
## [param shader_arg] is the [Dictionary] configuration for the shader. (sets the shader parameters)
## [br]
## [param config_arg] is the [Dictionary] configuration for the function.
## [br]
## [br]
## Parameters for [param config_arg]
## [br]
## If [param fast_skipable] is true, allows the player to fast skip this function, running
## [memthod add_overlay_normal_instant] instead.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets called.
## [br]
## [param hold_out] is how long before it executes [method add_overlay_normal_instant].
## @experimental: I don't really like how the hold out and hold in is defined. In v1.0.0, I'll probably add a hold_middle argument.
func add_overlay_normal(shader_name: String, shader_arg: Dictionary = {}, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold_out: float
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold_out": 0
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		add_overlay_normal_instant(shader_name, shader_arg)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	add_overlay_normal_instant(shader_name, shader_arg)
	
	await get_tree().create_timer(config["hold_in"]).timeout
	main_scene.dialogue_fade_in()

## Instant version of [method add_overlay_normal].
func add_overlay_normal_instant(shader_name: String, shader_arg: Dictionary) -> void:
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
	
	for k in shader_arg:
		color_overlay.get_material().set_shader_parameter(k, shader_arg[k])

## Adds a overlay effect that is persistant on background transitions.
## This means that a overlay that is considered persistant will be on top of background transitions.
## [br]
## [br]
## [param shader_name] is the [Shader] file path.
## [br]
## [param shader_arg] is the [Dictionary] configuration for the shader. (sets the shader parameters)
## [br]
## [param config_arg] is the [Dictionary] configuration for the function.
## [br]
## [br]
## Parameters for [param config_arg]
## [br]
## If [param fast_skipable] is true, allows the player to fast skip this function, running
## [memthod add_overlay_normal_instant] instead.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets called.
## [br]
## [param hold_out] is how long before it executes [method add_overlay_persistant_instant].
func add_overlay_persistant(shader_name: String, shader_arg: Dictionary = {}, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold_out: float
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold_out": 0
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		add_overlay_persistant_instant(shader_name, shader_arg)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	add_overlay_persistant_instant(shader_name, shader_arg)
	
	await get_tree().create_timer(config["hold_in"]).timeout
	main_scene.dialogue_fade_in()

## Instant version of [method add_overlay_persistant].
func add_overlay_persistant_instant(shader_name: String, shader_arg: Dictionary = {}) -> void:
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
	
	for k in shader_arg:
		color_overlay.get_material().set_shader_parameter(k, shader_arg[k])

## Sets shader parameters on a active overlay from [member _active_overlays].
## This does not trigger [DemoScripter_VisualNovelScene.dialogue_fade_in] and
## [DemoScripter_VisualNovelScene.dialogue_fade_out].
## [br]
## [br]
## [member id] is the shader id from [member _active_overlays].
## [br]
## [param shader_arg] is the [Dictionary] configuration for the shader. (sets the shader parameters)
func set_active_overlay_normal_id(id: int, shader_arg: Dictionary = {}) -> void:
	for k in shader_arg:
		_active_overlays[id].get_material().set_shader_parameter(k, shader_arg[k])

## Sets shader parameters on a active overlay from [member _active_overlays] using a Tween transition.
## This triggers [DemoScripter_VisualNovelScene.dialogue_fade_in] and
## [DemoScripter_VisualNovelScene.dialogue_fade_out].
func set_active_overlay_normal_tween_id(id: int, property: String, value, duration: float, config_arg: Dictionary = {}) -> void:
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold_out": 0
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		set_active_overlay_normal_id(id, {property: value})
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	set_active_overlay_normal_tween_id_instant(id, property, value, duration)
	
	await get_tree().create_timer(duration + config["hold_in"]).timeout
	main_scene.dialogue_fade_in()

## Instant version of [method set_actiev_overlay_normal_tween_id].
func set_active_overlay_normal_tween_id_instant(id: int, property: String, value, duration: float) -> void:
	var overlay = _active_overlays[id]
	
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "material:shader_parameter/" + property, value, duration)

## Removes a overlay using a id.
## [br]
## [br]
## [param id] is the overlay id target to be removed.
## [br]
## [param config_arg] is the [Dictionary] configuration for the function.
## [br]
## [br]
## Parameters for [param config_arg]
## [br]
## If [param fast_skipable] is true, allows the player to fast skip this function, running
## [memthod add_overlay_normal_instant] instead.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets called.
## [br]
## [param hold_out] is how long before it executes [method add_overlay_persistant_instant].
func remove_overlay_normal_id(id: int, config_arg: Dictionary) -> void:
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold_out": 0
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		remove_overlay_normal_id_instant(id)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	remove_overlay_normal_id_instant(id)
	
	await get_tree().create_timer(config["hold_in"]).timeout
	main_scene.dialogue_fade_in()

## Instant version of [method remove_overlay_normal_id_instant].
func remove_overlay_normal_id_instant(id: int) -> void:
	_active_overlays[id].queue_free()
	_remove_active_overlay_id(id)

## Wrapper for [method remove_overlay_normal_id_instant] where it awaits a [Signal] before
## executing [method remove_overlay_normal_id_instant].
func remove_overlay_normal_id_instant_await(signalname: Signal, id: int) -> void:
	await signalname
	remove_overlay_normal_id_instant(id)

## Sets a overlay visible or invisible.
## [br]
## [br]
## [param id] is the id of the overlay from [member _active_overlays].
## [br]
## [param visible] is the visibility of the overlay. If true, it's visible and if false, invisible.
func set_active_overlay_visible_instant(id: int, visible: bool) -> void:
	_active_overlays[id].set_visible(visible)

#endregion

#region CHARACTER FUNCS

## Hides all the [DemoScripter_VisualNovelCharacter]s from [member characters_node].
func hide_characters() -> void:
	for k in characters_node.get_children():
		if k is DemoScripter_VisualNovelCharacter:
			main_scene.hide_character_instant(k, 0)

## Show all the [DemoScripter_VisualNovelCharacter]s from [member characters_node].
func show_characters() -> void:
	for k in characters_node.get_children():
		if k is DemoScripter_VisualNovelCharacter:
			main_scene.show_character_instant(k, 0)

#endregion

#region BACKGROUND FUNCS

## Changes background.
## [br]
## [br]
## [param index] 
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

## Changes [member background_sprites] frame.
## [br]
## [br]
## [param index] is the index it will change to.
## [br]
## If [param group] ins't empty, it will change the [member background_sprites]'s animation.
## In this case, it would change the group.
func change_background_instant(index: int, group: String = "") -> void:
	if group:
		background_sprites.animation = group
	
	background_sprites.frame = index

## Changes background using a fade transition.
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

## Hides [member background_sprites].
func hide_background() -> void:
	background_sprites.set_visible(false)

## Shows [member background_sprites].
func show_background() -> void:
	background_sprites.set_visible(true)

## Changes background using a transition.
## [br]
## [br]
## [param index] is the index it will change to.
## [br]
## [param group] is the group it will change to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration for the function.
## [br]
## [br]
## Parameters for [param config_arg]
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method change_background_transition_instant] with 0 [param duration] instead.
## [br]
## If [param persistant_chars] is true, the characters will be on top of the background transition.
## [br]
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## [param hold_out] is how long before [method change_background_transition_instant] gets executed.
## [br]
## [param hold_signal] is how long before [signal background_transition_finished] gets emitted.
## [br]
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed.
## [br]
## [param show_character] is an array of which characters will be show.
## [br]
## [param hide_character] is an array of which characters will be hidden.
## [br]
## If [param hide_characters_on_end] is true, runs [method hide_characters] when transition finishes.
func change_background_transition(index: int, group: String, duration: float, config_arg: Dictionary = {}) -> void:
	# NOTE: types
	# fast_skipable: bool
	# persistant_chars: bool
	# hold_in: float
	# hold_out: float
	# hold_signal: float
	var default_config: Dictionary = {
		"fast_skipable": true,
		"persistant_chars": false,
		"hold_in": 0,
		"hold_out": 0,
		"hold_signal": 0,
		"active_overlay_visible": {},
		"remove_active_overlay": [],
		"show_character": [],
		"hide_character": [],
		"hide_characters_on_end": true
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	var config_instant: Dictionary = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		change_background_transition_instant(index, group, 0, config_instant)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	change_background_transition_instant(index, group, duration, config_instant)
	
	await get_tree().create_timer(duration + config["hold_in"]).timeout
	
	main_scene.dialogue_fade_in()

## Instant version of [method change_background_transition].
func change_background_transition_instant(index: int, group: String, duration: float, config_arg: Dictionary = {}) -> void:
	var default_config: Dictionary = {
		"persistant_chars": false,
		"hold_signal": 0,
		"remove_active_overlay": [],
		"active_overlay_visible": {},
		"show_character": [],
		"hide_character": [],
		"hide_characters_on_end": true
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
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
	
	if config["persistant_chars"]:
		characters_node.move_child(new_background, 0)
	
	if config["hide_character"]:
		for k in config["hide_character"]:
			main_scene.hide_character_instant.call(k, 0)
		
	if config["show_character"]:
		for k in config["show_character"]:
			main_scene.show_character_instant.call(k, 0)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(new_background, -persistant_overlays - 1)
		else:
			characters_node.move_child(new_background, -persistant_overlays - 1)
	
	var tween = get_tree().create_tween()
	tween.tween_property(new_background, "modulate", Color(new_background.modulate, 1), duration)
	if config["hide_characters_on_end"]:
		tween.tween_callback(hide_characters)
	tween.tween_callback(background_sprites.set_frame.bind(index))
	tween.tween_callback(background_sprites.set_animation.bind(group))
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	tween.tween_callback(new_background.queue_free)
	tween.tween_callback(emit_signal.bind("background_transition_finished")).set_delay(config["hold_signal"])

## Fades in the background with a shader effect. Useful for custom transitions.
## [br]
## [br]
## [param shader_name] is the shader file path.
## [br]
## [param property] is the property that will be changed during transition.
## [br]
## [param value] is the value the [param property] will go to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration of the function.
## [br]
## [br]
## Parameters for [config_arg].
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method background_effect_in_instant] instead.
## [br]
## [param hold] is how long before [signal overlay_effect_finished] gets emitted.
## [br]
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed. Keep in mind that
## [param hold] occurs before [param hold_in]!
## [br]
## [param hold_out] is how long before [method background_effect_in_instant] gets executed.
## [br]
## [param quick_direction] is the angle where the overlay effect will be on.
## Acceptable values are "up" (default), "down", "left" and "right".
## [param tween_type] is the type of the fade in will start on.
## Acceptable values are "auto" (uses the [param value] as negative value) and "manual"
## (uses [param tween_from] value.)
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed.
## [br]
## If [method hide_characters] is true, [method hide_characters] is executed when transition is
## finished.
## [br]
## If [method hide_background] is true, [method hide_background] is executed when transition is
## finished.
func background_effect_in(shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# rotation: float
	# fast_skipable: bool
	# hold: float
	# hold_in: float
	# hold_out: float
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hide_characters": true,
		"hide_background": true,
		"hold": 0,
		"hold_in": 0,
		"hold_out": 0,
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"active_overlay_visible": {},
		"remove_active_overlay": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	var config_instant: Dictionary = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		if config["hide_characters"]:
			hide_characters()
		
		if config["hide_background"]:
			hide_background()
		
		if config["active_overlay_visible"]:
			for k in config["active_overlay_visible"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible"][k])
		
		if config["remove_active_overlay"]:
			for k in config ["remove_active_overlay"]:
				remove_overlay_normal_id_instant(k)
		
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_effect_in_instant(shader_name, property, value, duration, config_instant)
	
	await overlay_effect_finished
	await get_tree().create_timer(config["hold_in"]).timeout
	main_scene.dialogue_fade_in()

## Instant version pf [method background_effect_in].
func background_effect_in_instant(shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# rotation: float
	# hold: float
	
	# types of tween:
	# auto - automatically sets the value negative
	# manual - sets the start value from tween_from
	# none - does not set the tween
	var default_config: Dictionary = {
		"hold": 0,
		"color": Color.WHITE,
		"hide_background": true,
		"hide_characters": true,
		"modulate": Color8(255, 255, 255, 255),
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"active_overlay_visible": {},
		"remove_active_overlay": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = config["color"]
	color_overlay.modulate = config["modulate"]
	#color_overlay.pivot_offset = Vector2(color_overlay.size.x / 2, color_overlay.size.y / 2)
	color_overlay.set_material(effect)
	
	# TODO: make this rotation func work, where it sets the node to full screen.
	#if config["rotation"] > 0:
		#color_overlay.set_rotation(config["rotation"])
		#resize_rect_to_fullscreen(color_overlay)
	
	if config["quick_direction"] != "up":
		match config["quick_direction"]:
			"down":
				#color_overlay.size = Vector2(540, 720)
				color_overlay.position = background_color.size
				color_overlay.rotation_degrees = 180
			"right":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(background_color.size.x, 0)
				color_overlay.rotation_degrees = 90
			"left":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(0, background_color.size.y)
				color_overlay.rotation_degrees = 270
	
	if use_overlay_exclusive_node:
		overlay_node.add_child(color_overlay)
	else:
		characters_node.add_child(color_overlay)
	
	if persistant_overlays > 0:
		if use_overlay_exclusive_node:
			overlay_node.move_child(color_overlay, -persistant_overlays - 1)
		else:
			characters_node.move_child(color_overlay, -persistant_overlays - 1)
	
	match config["tween_type"]:
		"auto":
			color_overlay.material.set_shader_parameter(property, -value)
		"manual":
			color_overlay.material.set_shader_parameter(property, config["tween_from"])
		"none":
			pass
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	if config["hide_background"]:
		tween.tween_callback(hide_background)
	if config["hide_characters"]:
		tween.tween_callback(hide_characters)
	tween.tween_callback(color_overlay.queue_free)
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	if config["active_overlay_visible"]:
		for k in config["active_overlay_visible"].keys():
			tween.tween_callback(set_active_overlay_visible_instant.bind(k, config["active_overlay_visible"][k]))
	if config["hold"] > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(config["hold"])
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

## Fades out the background with a shader effect. Useful for custom transitions.
## [br]
## [br]
## [param shader_name] is the shader file path.
## [br]
## [param property] is the property that will be changed during transition.
## [br]
## [param value] is the value the [param property] will go to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration of the function.
## [br]
## [br]
## Parameters for [config_arg].
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method background_effect_in_instant] instead.
## [br]
## [param hold] is how long before [signal overlay_effect_finished] gets emitted.
## [br]
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed. Keep in mind that
## [param hold] occurs before [param hold_in]!
## [br]
## [param hold_out] is how long before [method background_effect_out_instant] gets executed.
## [br]
## [param color] is the color the effect will have.
## [br]
## [param modulate] is the modulate the effect will have.
## [br]
## [param quick_direction] is the angle where the overlay effect will be on.
## Acceptable values are "up" (default), "down", "left" and "right".
## [param tween_type] is the type of the fade in will start on.
## Acceptable values are "auto" (uses the [param value] as negative value) and "manual"
## (uses [param tween_from] value.)
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed.
## [br]
## [param show_character] is an array of which characters will be show.
## [br]
## [param hide_character] is an array of which characters will be hidden.
func background_effect_out(shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold": 0,
		"hold_in": 0,
		"hold_out": 0,
		"color": Color.WHITE,
		"modulate": Color8(255, 255, 255, 255),
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"active_overlay_visible": {},
		"remove_active_overlay": [],
		"show_character": [],
		"hide_character": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	var config_instant: Dictionary = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		show_background()
		
		if config["hide_character"]:
			for k in config["hide_character"]:
				main_scene.hide_character.call(k)
		
		if config["show_character"]:
			for k in config["show_character"]:
				main_scene.show_character.call(k)
				
		if config["active_overlay_visible"]:
			for k in config["active_overlay_visible"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible"][k])
		
		if config["remove_active_overlay"]:
			for k in config ["remove_active_overlay"]:
				remove_overlay_normal_id_instant(k)
		
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_effect_out_instant(shader_name, property, value, duration, config_instant)
	await overlay_effect_finished
	if config["hold_in"] > 0:
		await get_tree().create_timer(config["hold_in"]).timeout
	
	main_scene.dialogue_fade_in()

## Instant version [method background_effect_out].
func background_effect_out_instant(shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# rotation: float
	# hold: float
	var default_config: Dictionary = {
		"hold": 0,
		"color": Color.WHITE,
		"modulate": Color8(255, 255, 255, 255),
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"remove_active_overlay": [],
		"active_overlay_visible": {},
		"show_character": [],
		"hide_character": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = config["color"]
	color_overlay.modulate = config["modulate"]
	color_overlay.set_material(effect)
	
	# TODO: make this rotation func work, where it sets the node to full screen.
	#if config["rotation"] > 0:
		#color_overlay.set_rotation(config["rotation"])
		#resize_rect_to_fullscreen(color_overlay)
	
	if config["quick_direction"] != "up":
		match config["quick_direction"]:
			"down":
				#color_overlay.size = Vector2(540, 720)
				color_overlay.position = background_color.size
				color_overlay.rotation_degrees = 180
			"right":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(background_color.size.x, 0)
				color_overlay.rotation_degrees = 90
			"left":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(0, background_color.size.y)
				color_overlay.rotation_degrees = 270
	
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
	
	if config["hide_character"]:
		for k in config["hide_character"]:
			main_scene.hide_character.call(k)
	
	if config["show_character"]:
		for k in config["show_character"]:
			main_scene.show_character.call(k)
	
	match config["tween_type"]:
		"auto":
			color_overlay.material.set_shader_parameter(property, -value)
		"manual":
			color_overlay.material.set_shader_parameter(property, config["tween_from"])
		"none":
			pass
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	tween.tween_callback(color_overlay.queue_free)
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	if config["active_overlay_visible"]:
		for k in config["active_overlay_visible"].keys():
			tween.tween_callback(set_active_overlay_visible_instant.bind(k, config["active_overlay_visible"][k]))
	if config["hold"] > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(config["hold"])
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

## Fades out the background with a [method change_background_instant] using a shader.
## Useful for custom transitions that lead to a background change.
## [br]
## [br]
## [param index] is the index the [member background_sprites] will go to.
## [br]
## [param group] is the group the [member background_sprites] will go to.
## [br]
## [param shader_name] is the shader file path.
## [br]
## [param property] is the property that will be changed during transition.
## [br]
## [param value] is the value the [param property] will go to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration of the function.
## [br]
## [br]
## Parameters for [config_arg].
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method background_effect_in_instant] instead.
## [br]
## [param hold] is how long before [signal overlay_effect_finished] gets emitted.
## [br]
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed. Keep in mind that
## [param hold] occurs before [param hold_in]!
## [br]
## [param hold_out] is how long before [method background_effect_out_instant] gets executed.
## [br]
## [param quick_direction] is the angle where the overlay effect will be on.
## Acceptable values are "up" (default), "down", "left" and "right".
## [param tween_type] is the type of the fade out will start on.
## Acceptable values are "auto" (uses the [param value] as negative value) and "manual"
## (uses [param tween_from] value.)
## [br]
## [param tween_from] is where the tween will start from.
## Only gets used if [param tween_type] is "manual".
## [br]
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed.
## [br]
## [param show_character] is an array of which characters will be show.
## [br]
## [param hide_character] is an array of which characters will be hidden.
func background_effect_out_change(index: int, group: String, shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold": 0,
		"hold_in": 0,
		"hold_out": 0,
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"active_overlay_visible": {},
		"remove_active_overlay": [],
		"show_character": [],
		"hide_character": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	var config_instant: Dictionary = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		show_background()
		change_background_instant(index, group)
		
		if config["hide_character"]:
			for k in config["hide_character"]:
				main_scene.hide_character.call(k)
		
		if config["show_character"]:
			for k in config["show_character"]:
				main_scene.show_character.call(k)
		
		if config["active_overlay_visible"]:
			for k in config["active_overlay_visible"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible"][k])
		
		if config["remove_active_overlay"]:
			for k in config ["remove_active_overlay"]:
				remove_overlay_normal_id_instant(k)
		
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_effect_out_change_instant(index, group, shader_name, property, value, duration, config_instant)
	await overlay_effect_finished
	if config["hold_in"] > 0:
		await get_tree().create_timer(config["hold_in"]).timeout
	
	main_scene.dialogue_fade_in()

## Instant version [method background_effect_out_change].
func background_effect_out_change_instant(index: int, group: String, shader_name: String, property: String, value: float, duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# rotation: float
	# hold: float
	# color: color
	# modulate: color
	# quick_direction: string
	# transition_type: string
	
	# Types of transitions:
	# auto (manually sets the value to negative
	# manual
	var default_config: Dictionary = {
		"hold": 0,
		"color": Color.WHITE,
		"modulate": Color8(255, 255, 255, 255),
		"quick_direction": "up",
		"tween_type": "auto",
		"tween_from": -1,
		"active_overlay_visible": {},
		"show_character": [],
		"hide_character": [],
		"remove_active_overlay": []
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var effect = load(shader_name)
	var persistant_overlays = _check_persistant_amount_overlays()
	
	var color_overlay = ColorRect.new()
	color_overlay.size = background_color.size
	color_overlay.color = config["color"]
	color_overlay.modulate = config["modulate"]
	color_overlay.set_material(effect)
	
	# TODO: make this rotation func work, where it sets the node to full screen.
	#if config["rotation"] > 0:
		#color_overlay.set_rotation(config["rotation"])
		#resize_rect_to_fullscreen(color_overlay)
	
	if config["quick_direction"] != "up":
		match config["quick_direction"]:
			"down":
				#color_overlay.size = Vector2(540, 720)
				color_overlay.position = background_color.size
				color_overlay.rotation_degrees = 180
			"right":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(background_color.size.x, 0)
				color_overlay.rotation_degrees = 90
			"left":
				color_overlay.size = Vector2(background_color.size.y, background_color.size.x)
				color_overlay.position = Vector2(0, background_color.size.y)
				color_overlay.rotation_degrees = 270
	
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
	
	if config["hide_character"]:
		for k in config["hide_character"]:
			main_scene.hide_character_instant.call(k)
	
	if config["show_character"]:
		for k in config["show_character"]:
			main_scene.show_character_instant.call(k)
	#show_characters()
	
	match config["tween_type"]:
		"auto":
			color_overlay.material.set_shader_parameter(property, -value)
		"manual":
			color_overlay.material.set_shader_parameter(property, config["tween_from"])
		"none":
			pass
	
	var tween = get_tree().create_tween()
	tween.tween_property(color_overlay, "material:shader_parameter/" + property, value, duration)
	tween.tween_callback(color_overlay.queue_free)
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	if config["active_overlay_visible"]:
		for k in config["active_overlay_visible"].keys():
			tween.tween_callback(set_active_overlay_visible_instant.bind(k, config["active_overlay_visible"][k]))
	
	if config["hold"] > 0:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished")).set_delay(config["hold"])
	else:
		tween.tween_callback(emit_signal.bind("overlay_effect_finished"))

## Fades in the background.
## [br]
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration argument.
## [br]
## [br]
## Parameters for [param config_arg].
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running 
## [method background_fade_in_instant] instead.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## [param hold] is how long before [signal fade_in_finished] gets emitted.
## [br]
## [param hold_out] is how long before [method background_fade_in_instant] gets executed.
## [br]
## If [param hide_characters] is true, executes [method hide_characters] when fade in is finished.
## [br]
## If [param hide_background] is true, executes [method hide_background] when fade in is finished.
## [br]
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed once fade in
## is finished.
func background_fade_in(duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold_out: float
	# hide_character: bool
	# hide_background: bool
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold": 0,
		"hold_out": 0,
		"hide_characters": true,
		"hide_background": true,
		"active_overlay_visible": {},
		"remove_active_overlay": []
	}
	
	var config = _create_config_dict(default_config, config_arg)
	var config_instant = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		if config["hide_characters"]:
			hide_characters()
		
		if config["hide_background"]:
			hide_background()
		
		if config["active_overlay_visible"]:
			for k in config["active_overlay_visible"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible"][k])
		
		if config["remove_active_overlay"]:
			for k in config ["remove_active_overlay"]:
				remove_overlay_normal_id_instant(k)
		
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_fade_in_instant(duration, config_instant)
	
	if config["hold_in"] < 0:
		return
	
	await fade_in_finished
	main_scene.dialogue_fade_in()

## Instant version of [method background_fade_in].
func background_fade_in_instant(duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# hold: float
	# hide_background: bool
	# hide_characters: bool
	var default_config: Dictionary = {
		"hold": 0,
		"hide_characters": true,
		"hide_background": true,
		"active_overlay_visible": {},
		"remove_active_overlay": []
	}
	
	var config = _create_config_dict(default_config, config_arg)
	
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
	if config["hide_background"]:
		tween.tween_callback(hide_background)
	if config["hide_characters"]:
		tween.tween_callback(hide_characters)
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	if config["active_overlay_visible"]:
		for k in config["active_overlay_visible"].keys():
			tween.tween_callback(set_active_overlay_visible_instant.bind(k, config["active_overlay_visible"][k]))
	tween.tween_callback(color_overlay.queue_free)
	if config["hold"] > 0:
		tween.tween_callback(emit_signal.bind("fade_in_finished")).set_delay(config["hold"])
	else:
		tween.tween_callback(emit_signal.bind("fade_in_finished"))

## Fades out the background.
## [br]
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param config_arg] is the [Dictionary] configuration argument.
## [br]
## [br]
## Parameters for [param config_arg].
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running 
## [method background_fade_out_instant] instead.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_out] gets executed.
## [br]
## [param hold] is how long before [signal fade_out_finished] gets emitted.
## [br]
## [param hold_out] is how long before [method background_fade_in_instant] gets executed.
## [br]
## [param active_overlay_visible] sets visibility of overlay.
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param remove_active_overlay] is an array of which active overlays will be removed once fade out
## is finished.
## [br]
## [param show_character] is an array of which characters will be show.
## [br]
## [param hide_character] is an array of which characters will be hidden.
func background_fade_out(duration: float, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold: float
	# hold_out: float
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold": 0,
		"hold_out": 0,
		"active_overlay_visible": {},
		"remove_active_overlay": [],
		"show_character": [],
		"hide_character": []
	}
	
	var config = _create_config_dict(default_config, config_arg)
	var config_instant = _remove_config_keys(config, ["fast_skipable", "hold_in", "hold_out"])
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		show_background()
		
		if config["hide_character"]:
			for k in config["hide_character"]:
				main_scene.hide_character.call(k)
		
		if config["show_character"]:
			for k in config["show_character"]:
				main_scene.show_character.call(k)
		
		if config["active_overlay_visible"]:
			for k in config["active_overlay_visible"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible"][k])
		
		if config["remove_active_overlay"]:
			for k in config ["remove_active_overlay"]:
				remove_overlay_normal_id_instant(k)
		return
		
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_fade_out_instant(duration, config_instant)
	
	await fade_out_finished
	if config["hold_in"] > 0:
		await get_tree().create_timer(config["hold_in"]).timeout
	
	main_scene.dialogue_fade_in()

## Instant version [method background_fade_out].
func background_fade_out_instant(duration: float, config_arg: Dictionary = {}) -> void:
	# BUG: Somehow, the fadeout tween doesnt work
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold: float
	# hold_out: float
	var default_config: Dictionary = {
		"hold": 0,
		"active_overlay_visible": {},
		"remove_active_overlay": [],
		"show_character": [],
		"hide_character": []
	}
	
	var config = _create_config_dict(default_config, config_arg)
	
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
	
	if config["hide_character"]:
			for k in config["hide_character"]:
				main_scene.hide_character.call(k)
		
	if config["show_character"]:
		for k in config["show_character"]:
			main_scene.show_character.call(k)
	
	var tween = get_tree().create_tween()
	if config["remove_active_overlay"]:
		for k in config["remove_active_overlay"]:
			tween.tween_callback(remove_overlay_normal_id_instant.bind(k))
	if config["active_overlay_visible"]:
		for k in config["active_overlay_visible"].keys():
			tween.tween_callback(set_active_overlay_visible_instant.bind(k, config["active_overlay_visible"][k]))
	tween.tween_callback(show_background)
	tween.tween_property(color_overlay, "modulate", Color(color_overlay.modulate, 0), duration)
	tween.tween_callback(color_overlay.queue_free)
	if config["hold"] > 0:
		tween.tween_callback(emit_signal.bind("fade_out_finished")).set_delay(config["hold"])
	else:
		tween.tween_callback(emit_signal.bind("fade_out_finished"))

## Changes background using a shader transition effect.
## Useful for custom transitions that lead to a background change.
## [br]
## [br]
## [param index] is the index the [member background_sprites] will go to.
## [br]
## [param group] is the group the [member background_sprites] will go to.
## [br]
## [param shader_name] is the shader file path.
## [br]
## [param property] is the property that will be changed during transition.
## [br]
## [param value_in] is the value the [param background_effect_in] will go to.
## [br]
## [param value_out] is the value the [param background_effect_out] will go to.
## [br]
## [param duration_in] is how long the [param background_effect_in] will last.
## [br]
## [param duration_out] is how long the [param background_effect_out] will last.
## [br]
## [param config_arg] is the [Dictionary] configuration of the function.
## [br]
## [br]
## Parameters for [config_arg].
## [br]
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method change_background_instant] with duration 0 instead.
## [br]
## If [param hide_characters_in] is true, executes [method hide_characters] during
## [method background_effect_in].
## [br]
## If [param hide_background_in] is true, executes [method hide_background] during
## [method background_effect_in].
## [br]
## [param show_character_out] is an array of which characters will show during
## [method background_effect_out].
## [br]
## [param hide_character_out] is an array of which characters will hide during
## [method background_effect_out].
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## [param hold_middle] is how long before [method background_effect_out_instant] gets executed.
## [br]
## [param hold_out] is how long before [method background_effect_in_instant] gets executed.
## [br]
## [param hold_fadein] is the hold fade in duration for [method background_effect_in_instant].
## [br]
## [param hold_fadeout] is the hold fade out duration for [method background_effect_out_instant].
## [br]
## [param quick_direction_fadein] is the angle for [method background_effect_in_instant] will be on.
## Acceptable values are "up" (default), "down", "left" and "right".
## [br]
## [param quick_direction_fadeout] is the angle for [method background_effect_out_instant] will be on.
## Acceptable values are "up" (default), "down", "left" and "right".
## [br]
## [param color_fadein] is the color for [method background_effect_in_instant].
## [br]
## [param color_fadeout] is the color for [method background_effect_out_instant].
## [br]
## [param modulate_fadein] is the modulate for [method background_effect_in_instant].
## [br]
## [param modulate_fadeout] is the modulate for [method background_effect_out_instant].
## [br]
## [param tween_type_fadein] is the type of tween [background_effect_in_instant] will use.
## Acceptable values are "auto" (uses the [param value] as negative value) and "manual"
## (uses [param tween_from_fadein] value.)
## [br]
## [param tween_type_fadeout] is the type of tween [background_effect_out_instant] will use.
## Acceptable values are "auto" (uses the [param value] as negative value) and "manual"
## (uses [param tween_from_fadeout] value.)
## [br]
## [param tween_from_fadein] is where the [method background_effect_in_instant]'s tween will start 
## from. Only gets used if [param tween_type_fadein] is "manual".
## [br]
## [param tween_from_fadeout] is where the [method background_effect_out_instant]'s tween will start 
## from. Only gets used if [param tween_type_fadeout] is "manual".
## [br]
## [param remove_active_overlay_fadein] is an array of which active overlays will be removed during
## [method background_effect_in_instant].
## [br]
## [param remove_active_overlay_fadeout] is an array of which active overlays will be removed during
## [method background_effect_out_instant].
## [br]
## [param active_overlay_visible_fadein] sets visibility of overlay during 
## [method background_effect_in_instant].
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param active_overlay_visible_fadeout] sets visibility of overlay during 
## [method background_effect_out_instant].
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## @experimental: I feel like the hold_out, hold_in names should be changed since it seems confusing? I'll probably do that in v1.0.0.
func change_background_effect(index: int, group: String, shader_name: String, property: String, value_in: float, value_out: float, duration_in: float, duration_out: float, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold: float
	# hold_in: float
	# hold_out: float
	# rotation: float
	# TODO: make seperate keys for fade in and fade out? like quick_direction_fadein, etc?
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hide_characters_in": true,
		"hide_background_in": true,
		"show_character_out": [],
		"hide_character_out": [],
		"hold_in": 0,
		"hold_middle": 0,
		"hold_out": 0,
		"hold_fadein": 0,
		"hold_fadeout": 0,
		"quick_direction_fadein": "up",
		"quick_direction_fadeout": "up",
		"color_fadein": Color.WHITE,
		"color_fadeout": Color.WHITE,
		"modulate_fadein": Color8(255, 255, 255, 255),
		"modulate_fadeout": Color8(255, 255, 255, 255),
		"tween_type_fadein": "auto",
		"tween_type_fadeout": "auto",
		"tween_from_fadein": -1,
		"tween_from_fadeout": -1,
		"remove_active_overlay_fadein": [],
		"remove_active_overlay_fadeout": [],
		"active_overlay_visible_fadein": {},
		"active_overlay_visible_fadeout": {}
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var config_fadein: Dictionary = {
		"hold": config["hold_fadein"],
		"hide_characters": config["hide_characters_in"],
		"hide_background": config["hide_background_in"],
		"color": config["color_fadein"],
		"modulate": config["modulate_fadein"],
		"quick_direction": config["quick_direction_fadein"],
		"tween_type": config["tween_type_fadein"],
		"tween_from": config["tween_from_fadein"],
		"active_overlay_visible": config["active_overlay_visible_fadein"],
		"remove_active_overlay": config["remove_active_overlay_fadein"]
	}
	
	var config_fadeout: Dictionary = {
		"hold": config["hold_fadeout"],
		"color": config["color_fadeout"],
		"modulate": config["modulate_fadeout"],
		"quick_direction": config["quick_direction_fadeout"],
		"tween_type": config["tween_type_fadeout"],
		"tween_from": config["tween_from_fadeout"],
		"active_overlay_visible": config["active_overlay_visible_fadeout"],
		"remove_active_overlay": config["remove_active_overlay_fadeout"],
		"show_character": config["show_character_out"],
		"hide_character": config["hide_character_out"]
	}
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		if config["hide_characters_in"]:
			hide_characters()
		
		if config["hide_character_out"]:
			for k in config["hide_character_out"]:
				main_scene.hide_character_instant.call(k)
		
		if config["show_character_out"]:
			for k in config["show_character_out"]:
				main_scene.show_character_instant.call(k)
			
		change_background_instant(index, group)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	background_effect_in_instant(shader_name, property, value_in, duration_in, config_fadein)
	await overlay_effect_finished
	
	if config["hold_middle"] > 0:
		await get_tree().create_timer(config["hold_middle"]).timeout
	
	background_effect_out_change_instant(index, group, shader_name, property, value_out, duration_out, config_fadeout)
	await overlay_effect_finished
	
	if config["hold_in"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
	
	main_scene.dialogue_fade_in()

## Changes background using a fade transition.
## [br]
## [br]
## [param index] is the index [member background_sprites] will go to.
## [br]
## [param group] is the group [member background_sprites] will go to.
## [br]
## [param fadeout] is how long the fade out will last.
## [br]
## [param hold_out] is how long before fade in starts.
## [br]
## [param fadein] is how long the fade in will last.
## [br]
## [param hold_in] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## If [param fast_skipable] is true, players can fast skip this function, executing
## [method change_background_instant] instead.
func change_background_fade_new(index: int, group: String, fadeout: float, hold_out: float, fadein: float, hold_in: float, fast_skipable: bool = true) -> void:
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

## Causes a background fade in and fade out at the same time.
## [br]
## [br]
## [param fadein] is how long the fade in will last.
## [br]
## [param fadeout] is how long the fade out will last.
## [br]
## [param config_arg] is the [Dictionary] configuration for the function.
## [br]
## [br]
## Parameters for [param config_arg].
## [br]
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method change_background_instant] with duration 0 instead.
## [br]
## If [param hide_characters_in] is true, executes [method hide_characters] during
## [method background_effect_in].
## [br]
## If [param hide_background_in] is true, executes [method hide_background] during
## [method background_effect_in].
## [br]
## [param show_character_out] is an array of which characters will show during
## [method background_effect_out].
## [br]
## [param hide_character_out] is an array of which characters will hide during
## [method background_effect_out].
## [param hold_in] is how long before [member main_scene]'s
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## [param hold_middle] is how long before [method background_effect_out_instant] gets executed.
## [br]
## [param hold_out] is how long before [method background_effect_in_instant] gets executed.
## [br]
## [param hold_fadein] is the hold fade in duration for [method background_effect_in_instant].
## [br]
## [param hold_fadeout] is the hold fade out duration for [method background_effect_out_instant].
## [br]
## [param rect_color] is the color the blink will have.
## [br]
## [param remove_active_overlay_fadein] is an array of which active overlays will be removed during
## [method background_fade_in_instant].
## [br]
## [param remove_active_overlay_fadeout] is an array of which active overlays will be removed during
## [method background_fade_out_instant].
## [br]
## [param active_overlay_visible_fadein] sets visibility of overlay during 
## [method background_fade_in_instant].
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
## [br]
## [param active_overlay_visible_fadeout] sets visibility of overlay during 
## [method background_fade_out_instant].
## The key is the overlay id from [member _active_overlays] and the value is the visibility.
## (true = visible, false = invisible)
func rect_blink(fadein: float, fadeout: float, config_arg: Dictionary = {}) -> void:
	# types:
	# fast_skipable: bool
	# hold_in: float
	# hold_out: float
	# hide_background_in: bool
	# hide_character_in: bool
	var old_background_color: Color = background_color.modulate
	
	var default_config: Dictionary = {
		"fast_skipable": true,
		"hold_in": 0,
		"hold_out": 0,
		"hold_fadein": 0,
		"hold_middle": 0,
		"hold_fadeout": 0,
		"hide_background_in": true,
		"hide_characters_in": false,
		"rect_color": background_color.modulate,
		"remove_active_overlay_fadein": [],
		"remove_active_overlay_fadeout": [],
		"active_overlay_visible_fadein": {},
		"active_overlay_visible_fadeout": {}
	}
	
	assert(_check_same_keys_dict(default_config, config_arg), "Invalid key in config argument!")
	
	var config = default_config.duplicate()
	if !config_arg.is_empty():
		config.merge(config_arg, true)
	
	var config_fadein: Dictionary = {
		"hold": config["hold_fadein"],
		"hide_characters": config["hide_characters_in"],
		"hide_background": config["hide_background_in"],
		"active_overlay_visible": config["active_overlay_visible_fadein"],
		"remove_active_overlay": config["remove_active_overlay_fadein"]
	}
	
	# NOTE: in case fadeout in the future gets more optional arguments
	var config_fadeout: Dictionary = {
		"hold": config["hold_fadeout"],
		"active_overlay_visible": config["active_overlay_visible_fadeout"],
		"remove_active_overlay": config["remove_active_overlay_fadeout"]
	}
	
	if config["fast_skipable"] and Input.is_action_pressed("fast_skip"):
		if config["hide_characters_in"]:
			hide_characters()
		
		if config["active_overlay_visible_fadein"]:
			for k in config["active_overlay_visible_fadein"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible_fadein"][k])
		
		if config["remove_active_overlay_fadein"]:
			for k in config ["remove_active_overlay_fadein"]:
				remove_overlay_normal_id_instant(k)
		
		if config["active_overlay_visible_fadeout"]:
			for k in config["active_overlay_visible_fadeout"]:
				set_active_overlay_visible_instant(k, config["active_overlay_visible_fadeout"][k])
		
		if config["remove_active_overlay_fadeout"]:
			for k in config ["remove_active_overlay_fadeout"]:
				remove_overlay_normal_id_instant(k)
		
		return
	
	if config["hold_in"] > 0:
		await get_tree().create_timer(config["hold_in"]).timeout
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	if config["rect_color"] != background_color.modulate:
		set_rect_modulate_instant(config["rect_color"], background_color)
	
	background_fade_in_instant(fadein, config_fadein)
	await fade_in_finished
	
	# TODO: make it so overlays are not visible?
	if config["hold_middle"] > 0:
		await get_tree().create_timer(config["hold_middle"]).timeout
	
	background_fade_out_instant(fadeout, config_fadeout)
	await fade_out_finished
	
	if background_color.modulate != old_background_color:
		set_rect_modulate_instant(old_background_color, background_color) 
	
	if config["hold_out"] > 0:
		await get_tree().create_timer(config["hold_out"]).timeout
		main_scene.dialogue_fade_in()
	elif config["hold_out"] < 0:
		return
	else:
		main_scene.dialogue_fade_in()

## Sets the color of [member background_color].
## [br]
## [br]
## [param newColor] is the color [member background_color] will use.
## [br]
## If [param fast_skipable] is true, the player can fast skip this function, running
## [method set_rect_color_instant] instead.
## [br]
## [param hold_in] is how long before [method set_rect_color_instant] gets executed.
## [br]
## [param hold_out] is how long before fade in starts.
## @experimental: The hold in and out names seems wrong? May be reworked in v1.0.0
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

## Instant version of [method set_rect_color].
func set_rect_color_instant(newColor: Color) -> void:
	background_color.color = newColor

## Sets the color of [member background_color].
## [br]
## [br]
## [param newColor] is the color [member background_color] will use.
## [br]
## [param duration] is how much the transition will last.
## [br]
## If [param fast_skipable] is true, the player can fast skip this function, running
## [method set_rect_color_instant] instead.
## [br]
## [param hold_in] is how long before transition starts.
## [br]
## [param hold_out] is how long before fade in starts.
## @experimental: The hold in and out names seems wrong? May be reworked in v1.0.0
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

## Sets [member background_sprites]'s modulate property.
func set_background_modulate_instant(newColor: Color) -> void:
	background_sprites.set_modulate(newColor)

#endregion

#region UNDERSCORE

## Checks how much overlays in [member _active_overlays] is persistant.
func _check_persistant_amount_overlays() -> int:
	var amount: int = 0  
	
	for k in _active_overlays:
		if !k.has_meta("isPersistant"):
			continue
		
		if k.get_meta("isPersistant"):
			amount += 1
	
	return amount

## Adds a active overlay to [member _active_overlays].
func _add_active_overlay(node: Node) -> void:
	_active_overlays.append(node)

## Removes a active overlay to [member _active_overlays].
func _remove_active_overlay(node: Node) -> void:
	_active_overlays.erase(node)

## Adds a active overlay to [member _active_overlays] using ID.
func _remove_active_overlay_id(id: int) -> void:
	_active_overlays.remove_at(id)

## Checks if [param dict2] has the same keys in [param dict1].
## Used for [method _create_config_dict].
func _check_same_keys_dict(dict1: Dictionary, dict2: Dictionary) -> bool:
	if dict2.is_empty():
		return true
	
	for k in dict2:
		if not k in dict1:
			print_stack()
			print("dict1: " + str(dict1))
			print("dict2: " + str(dict2))
			print("\n")
			print("\"" + k + "\" is not in dict1!")
			return false
	
	return true

## Creates a config dictionary.
## Used for Object Options pattern. (where a function accepts a config dictionary as argument)
## [br]
## [br]
## [param default_config] is the default configuration.
## [br]
## [param config_arg] is the configurartion that will overwrite values from default configuration.
func _create_config_dict(default_config: Dictionary, config_arg: Dictionary) -> Dictionary:
	assert(_check_same_keys_dict(default_config, config_arg), "Invalid key in config argument!")
	
	var config = default_config.duplicate()
	if !config_arg.is_empty():
		config.merge(config_arg, true)
	
	return config

## Returns a configuration with [param keys] removed from [param config_arg].
## [br]
## [br]
## [param config_arg] is the configuration argument.
## [br]
## [param keys] is the keys that will be removed.
func _remove_config_keys(config_arg: Dictionary, keys: Array) -> Dictionary:
	var config = config_arg.duplicate()
	
	for k in config.keys():
		if k in keys:
			config.erase(k)
	
	return config

#endregion

#region OBSOLETE

# OLD STUFF BELOW

## Changes background using transition.
## [br]
## [br]
## [param index] sets the background sprite frame.
## [br]
## [param group] sets the background's animation, in this case, the group of sprites.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param hold] is how long before dialogue fades in.
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method change_background_instant] instead.
## @deprecated: Old method of changing background transitions. This doesn't support handling characters. Use [member change_background_transition] instead. May be removed in v1.0.0.
func change_background_transition_old(index: int, group: String, duration: float, hold: float = 0.15, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		change_background_instant(index, group)
		return
	
	var old_background = background_sprites
	var new_background = AnimatedSprite2D.new()
	old_background.set_name("OldSprites")
	new_background.set_name("Sprites")
	new_background.sprite_frames = old_background.sprite_frames
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
	await get_tree().create_timer(hold).timeout
	main_scene.dialogue_fade_in()

## Sets background modulate, including all characters's modulate.
## @experimental: Uses a old method of applying modulate to characters. May be reworked v1.0.0.
func set_background_modulate_instant_all(newColor: Color) -> void:
	var characters = []
	for k in main_scene.get_child_count():
		if main_scene.get_child(k) is DemoScripter_VisualNovelCharacter:
			characters.append(main_scene.get_child(k))
	
	background_sprites.set_modulate(newColor)
	for k in characters:
		k.set_modulate(newColor)

## Sets background modulate using a transition.
## [br]
## [br]
## [param newColor] is what color it will set to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param hold] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] executes.
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method set_background_modulate_instant] instead.
## @experimental: May be reworked in v1.0.0.
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

## Sets background's modulate, including all characters' modulate using a transition.
## [br]
## [br]
## [param newColor] is the color the background's modulate will go to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param hold] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in]. 
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running
## [method set_background_modulate_instant_all] instead.
## @experimental: May be reworked in v1.0.0.
func set_background_modulate_transition_all(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_background_modulate_instant_all(newColor)
		return
	
	var characters = []
	for k in characters_node.get_child_count():
		if characters_node.get_child(k) is DemoScripter_VisualNovelCharacter:
			characters.append(characters_node.get_child(k))
	
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

## Sets the background's modulate.
## [br]
## [br]
## [param newColor] is the color the background will be set to.
## [br]
## [param hold] is how long before dialogue fades in.
## [br]
## If [param fast_skipable] is true, players can fast skip this function, running 
## [method set_background_modulate_instant] instead.
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


## Fades the background in.
## @deprecated: Use [method background_fade_in] instead.
func background_fadein_old(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

## Fades the background, affecting characters.
## @deprecated: Use [method background_fade_in] instead.
func background_fadein_all(duration: float, hold: float = 0) -> void: 
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

## Instant version of [method background_fadein_old].
## @deprecated: Use [method background_fade_in_instant] instead.
func background_fadein_instant(duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration)

## Fades the background out.
## @deprecated: Use [method background_fade_out] instead.
func background_fadeout_old(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

## Fades the background out, affecting the characters.
## @deprecated: Use [method background_fade_out] instead.
func background_fadeout_all(duration: float, hold: float = 0) -> void:
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

## Instant version of [method background_fadeout_old].
## @deprecated: Use [method background_fade_out_instant] instead.
func background_fadeout_instant(duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration)

## Sets a [param rect] object's modulate.
## [br]
## [br]
## [param newColor] is the color the [param rect] object will be set to.
## [br]
## [param hold] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## [param rect] is the rect object target.
## [br]
## If [param fast_skipable] is true, players can fast skip this, 
## running [method set_rect_modulate_instant] instead.
## @experimental: May be renamed in v1.0.0.
func set_rect_modulate(newColor: Color, hold: float, rect, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_rect_modulate_instant(newColor, rect)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	set_rect_modulate_instant(newColor, rect)
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

## Sets a [param rect] object's modulate using a transition.
## [br]
## [br]
## [param newColor] is the color the [param rect] object will be set to.
## [br]
## [param duration] is how long the transition will last.
## [br]
## [param rect] is the rect object target.
## [br]
## [param hold] is how long before [member main_scene]'s 
## [method DemoScripter_VisualNovelScene.dialogue_fade_in] gets executed.
## [br]
## If [param fast_skipable] is true, players can fast skip this, 
## running [method set_rect_modulate_instant] instead.
## @experimental: May be renamed in v1.0.0.
func set_rect_modulate_transition(newColor: Color, duration: float, rect, hold: float = 0, fast_skipable: bool = true) -> void:
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_rect_modulate_instant(newColor, rect)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "modulate", newColor, duration)
	await tween.finished
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

## Instant version of [method set_rect_modulate].
## [br]
## [br]
## [param newColor] is the color the [param rect] object will be set to.
## [br]
## [param rect] is the rect object target.
## [br]
## @experimental: May be renamed in v1.0.0.
func set_rect_modulate_instant(newColor: Color, rect) -> void:
	rect.set_modulate(newColor)

#endregion
