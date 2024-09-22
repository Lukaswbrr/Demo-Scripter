extends Node
class_name DemoScripter_BackgroundHandler

@export var main_scene: Node

@onready var anim_player = $AnimationPlayer
@onready var background_color = $ColorRect
@onready var background_sprites = $Sprites
@onready var current_background = background_sprites.frame

func _ready():
	assert(type_string(typeof(main_scene)) == "Object", "The main scene variable hasn't been defined!")

func change_background_instant(index: int, group = null):
	if group is String:
		background_sprites.animation = group
	
	background_sprites.frame = index

func change_background(index: int, group = null, hold: float = 0, fast_skipable: bool = true):
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

func change_background_fade(index: int, group, fadeout: float, hold_out: float, fadein: float, hold_in: float, fast_skipable: bool = true):
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

func change_background_transition(index: int, group, duration: float, hold: float = 0, fast_skipable: bool = true):
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

func set_background_modulate_instant(newColor: Color):
	background_sprites.set_modulate(newColor)

func set_background_modulate_instant_all(newColor: Color):
	var characters = []
	for k in main_scene.get_child_count():
		if main_scene.get_child(k) is DemoScripter_VisualNovelCharacter:
			characters.append(main_scene.get_child(k))
	
	background_sprites.set_modulate(newColor)
	for k in characters:
		k.set_modulate(newColor)

func set_background_modulate_transition(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true):
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

func set_background_modulate_transition_all(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true):
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

func set_background_modulate(newColor: Color, hold: float = 0, fast_skipable: bool = true):
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

func background_fadein_instant(duration: float):
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration)

func background_fadein(duration: float, hold: float = 0):
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

func background_fadein_all(duration: float, hold: float = 0):
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 1), duration, hold)

func background_fadeout_instant(duration: float):
	var tween = get_tree().create_tween()
	tween.tween_property(background_sprites, "modulate", Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration)

func background_fadeout(duration: float, hold: float = 0):
	set_background_modulate_transition(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

func background_fadeout_all(duration: float, hold: float = 0):
	set_background_modulate_transition_all(Color(background_sprites.modulate.r, background_sprites.modulate.g, background_sprites.modulate.b, 0), duration, hold)

func rect_blink(fadein: float, hold_in: float, fadeout: float, hold_out: float):
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

func set_rect_color(newColor: Color):
	background_color.color = newColor

func set_rect_color_transition(newColor: Color, duration: float, hold: float = 0, fast_skipable: bool = true):
	if fast_skipable and Input.is_action_pressed("fast_skip"):
		set_rect_color(newColor)
		return
	
	main_scene.dialogue_fade_out()
	await main_scene._animation_player.animation_finished
	var tween = get_tree().create_tween()
	tween.tween_property(background_color, "color", newColor, duration)
	await tween.finished
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		main_scene.dialogue_fade_in()
	elif hold < 0:
		return
	else:
		main_scene.dialogue_fade_in()

func set_overlay_modulate(newColor: Color, hold: float, overlay: ColorRect, fast_skipable: bool = true):
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

func set_overlay_modulate_transition(newColor: Color, hold: float, duration: float, overlay: ColorRect, fast_skipable: bool = true):
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

func set_overlay_modulate_instant(newColor: Color, overlay: ColorRect):
	overlay.set_modulate(newColor)
