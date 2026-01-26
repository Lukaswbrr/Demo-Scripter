class_name DemoScripter_VisualNovelScene
extends CanvasLayer
## Base class for handling Visual Novel scenes.
##
## Base class for handling Visual Novel scenes, which contains dialogue
## functions, character functions, music/audio functions, etc.

## Emits when [method add_dialogue] has been executed.
signal add_dialogue_finished(text: String, id: int, setname: String)
## Emits when [method add_dialogue_special] has been executed.
signal add_dialogue_special_finished(funcname: Callable, args)
## Emits when [method load_dialogue] has been executed.
signal load_dialogue_finished()
## @deprecated: This signal does not get emitted at all. Will be reworked in
## v1.0.0 version. (refactor)
signal load_dialogue_special_signal
## Emits when the text animation (tween) of the dialogue has been finished.
## This is used for the text icon to show up when a dialogue line is finished. 
signal text_animation_finished
## Emits when the current page of dialogie is finished and goes to the next one.
## id is what page it gone to.
signal dialogue_next_page(id: int)
## Emits when dialogue's fade_in animation is about to play.
## Occurs at the end of dialogue's fade_out animatiion.
signal animation_text_fading_in
## Emits when play_dialogue has reached the last possible dialogue index of a
## set.
signal end_dialogue_signal 

# Variables related to HUD node
 ## The main node path which is going to be used for dialogue text, etc.
@export var hud_node_path: NodePath = "Text"
## The HUD node got from [member hud_node_path].
@onready var hud_node = get_node(hud_node_path)
## The Label or RichTextNode used to display dialogue.
## Must be a child node of [member hud_node]
@onready var dialogue_node = hud_node.get_node("Dialogue")
## The background used behind the dialogue's text.
## Must be a child node of [member hud_node]
@onready var darkbackground_node = hud_node.get_node("DarkBackground")
## The animation player for the dialogue, used for fading in and fading out.
## Must be a child node of [member hud_node]
@onready var _animation_player: AnimationPlayer = darkbackground_node.get_node("AnimationPlayer")
## The icon of the dialogue system.
## Must be a child node of [member hud_node]
@onready var icon_text = hud_node.get_node("IconText")

## Dictionary where all the dialogue created from [method add_dialogue] is
## stored on.
## [br]
## [br]
## The keys (member dialogue_index]) is the incremented by 1 everytime add_dialogue is executed
## and the values are the information of the text.
## [br]
## [br]
## The following syntax for the values in the dictionary is:
## [br]
## index 0: Text of the dialogue
## [br]
## index 1: Number of words the text has
## [br]
## index 2: The page that the dialogue was added on
## [br]
## index 3: The set where the dialogue was added on.
## @experimental: In the v1.0.0 refactor version, this dictionary's structure will change.
var dialogue_dictionary: Dictionary = {}
## Dictionary where the functions created from [member add_dialogue_special] is stored on.
## [br]
## [br]
## Used for which function will be executed.
var function_dialogue_dictionary: Dictionary = {}
## Dictionary in which ID of [member dialogue_dictionary] that has a function
## created by [member add_dialogue_special].
var function_array_numbers: Array = []

## The current index of dialogue that is being displayed.
var dialogue_index: int = 1 # The current dialogue displaying
## The current page of dialogue.
var dialogue_current_id: int = 1

## Used for [member add_dialogue], where once the argument is set, next dialogue
## will use the same ID until a different id is used.
var add_dialogue_id: int = 1

# Dialogue states and system variables
## Used for when a dialogue is finished displaying.
## (when the tween animation is finished, showing all the text.)
var finished: bool
## Used for when a dialogue is paused.
## @experimental: This seems inconsistent because when using [member play_dialogue], dialogue is considered paused? I don't remember much why I used it since the framework base was worked in 2023 where I was still a begineer in GDScript and Godot. Will be reworked in v1.0.0 version.
var paused: bool
## Used for when the dialogue's system is disabled.
## Occurs during fade in and fade outs, functions like [method set_character_emotion], etc.
var disabled: bool
## Used for when the dialogue has been ended by [method end_dialogue].
var dialogue_ended: bool
## Used for checking if the current animation from [member _animation_player] is playing fade_out.
## Used on method [method wait_for_anim_func].
var check_wait_for_anim: bool
## If the dialogue has been started by [method load_dialogue].
var dialogue_started: bool

## Regex for filtering [] tags in dialogue.
## This fixes the issue where [] counts as characters, which is not meant to when using BBCode effects.
var regex = RegEx.new()
## If regex has been already compiled.
## [br]
## [br]
## If not, [method add_dialogue] compiles it automatically.
var regex_compiled = false

# Variables for tween
## The tween object used for text animations. (showing the text per word)
## @experimental: The name will be changed in v1.0.0 and functionality may change.
var tweenthing: Tween
## The to value used for [member tweehthing], where it gets the max length of the text from
## a dialogue.
## @experimental: The name will be changed in v1.0.0.
var maxvisible: int = 0

## The current dialogue set displaying the dialogue from.
var dialogue_current_set: String = "start" # The current set of dialogue (example set 1 is normal route, set 2 is different route, etc)
## Used in [method add_dialogue] where if you set the setname argument once, the next dialogues
## will be added in the specific set until set to another set.
var add_dialogue_set: String = "start"

@export_group("Text")
## Adds a space on texts that doesn't start with ".
@export var auto_space: bool = true 
## A icon appears after a text is finished displaying. This enables the icon from [member icon_text].
@export var enable_icon_text: bool = true 
## Duration of the dialogue's text speed. (this value gets multipled) 
## @experimental: This feature is currently not implemented and during test periods, this wasn't stable using non default values. May be added in v1.0.0.
@export var default_text_speed: float = 0.030 

## Checks if it's allowed to use fast skip.
## @experimetal: In v1.0.0, this may be changed to a export variable. Right now, [method pause_dialogue] changes this variable instead of [member can_fast_skip] so in order to not break compability (and the entire code, tbh), it will only be changed in v1.0.0.
var allowed_fast_skip: bool = true 
## If true, player can use fast skip.
var can_fast_skip: bool = true 

@export_group("Fast Skip")
## The delay of fast skip.
@export var fast_skip_delay: float = 0.15 
## If true, text will not be display fully if text wasn't fully displayed, 
## playing the text tween animation instead.
@export var ignore_text_full_display_fast_skip: bool = true 

@export_group("Character variables")
## The default used in [method set_character_emotion] before dialogue go to fade_in state.
@export var default_emotion_delay_end: float = 0.35

## If true, this kills the [member tweenthing] Tween and forces the text to be fully displayed.
## Used in fast skip.
@onready var ignore_text: bool = ignore_text_full_display_fast_skip
## Checks if its paused caused by [method pause_dialogue]
var forced_paused: bool
## Checks if its going to be paused at the end of the dialogue. 
## (used for fast skip not go to next dialouge)
var about_to_pause: bool 

# Modular stuff
@export_group("Modulars")
## If true, this uses default behavior and does not use custom icon funcionality.
var _use_default_icon_behavior: bool = true
## The custom icons created using [DemoScripter_IconModule] class.
@export var icon_modular: Array[Node]
## The extra modules created using [DemoScripter_ExtraModule] class.
@export var extra_modular: Array[Node]

## Starts the compile for filtering [] tags in dialogue.
## This is for preventing BBCode effects tags count as a character in the dialogue system,
## causing unexpected behavior.
func start_regex_compile() -> void:
	regex.compile("\\[.*?\\]")
	regex_compiled = true

## Adds a dialogue text to [member dialogue_dictionary] variable.
## This is for adding dialogues to your Visual Novel scenes.
## [br]
## [br]
## [param text] is the text of the dialogue.
## [br]
## [param id] is the dialogue's page.
## [br]
## If [param first_text] is true, it doesn't add a new line before the text.
## [br]
## [param setname] is the set where the dialogue will be added.
## [br]
## [param _speed] is how fast the dialogue text will be displayed. Currently unused.
## @experimental: In v1.0.0, the arguments may be changed to a Options Object pattern where it uses a Dictionary instead. (or maybe a class made in the script for config) A example of Options Object pattern used in [method DemoScripter_BackgroundHandler.change_background_transition]. the _speed argument may be functional in v1.0.0. 
func add_dialogue(text, id = add_dialogue_id, first_text = false, setname: String = add_dialogue_set, _speed = 1, should_auto_space: bool = auto_space) -> void:
	if !regex_compiled:
		start_regex_compile() 
	
	if should_auto_space:
		if text.begins_with("\n"):
			if !text[text.count("\n")] == '"': # do not add space if its a quote that uses multiple new lines
				text = text.insert(text.count("\n"), " ")
	
	var notags_text = regex.sub(text, "", true)
	
	add_dialogue_id = id
	add_dialogue_set = setname
	
	if !first_text:
#		print(str(text.begins_with("\"")) + ": " + str(text))
		if !should_auto_space: # checks if auto space is enabled
			dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + text), len(str("\n") + notags_text), id, setname]
		else:
			if text.begins_with("\""):
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + text), len("\n" + notags_text), id, setname]
			else:
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + " " + text), len("\n" + notags_text) + 1, id, setname]
	else:
		if !should_auto_space: # checks if auto space is enabled
			dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(text), len(notags_text), id, setname]
		else:
			if text.begins_with("\""):
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(text), len(notags_text), id, setname]
			else:
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(" " + text), len(notags_text) + 1, id, setname]
		
	add_dialogue_finished.emit(text, id, first_text, setname)

func add_dialogue_special(funcname: Callable, args: Array = []) -> void:
	# This function adds a dialogue to a array with a function as a extra value, making it possible to
	# run code if the id is the same as the special dialogue. (Example: changing character emotion, etc)
	function_dialogue_dictionary[function_dialogue_dictionary.size() + 1] = [dialogue_dictionary.keys().back(), funcname, args]
	add_dialogue_special_finished.emit(funcname, args)

func add_dialogue_next(text, id = add_dialogue_id + 1, setname = add_dialogue_set) -> void:
	add_dialogue(text, id, true, setname)

func add_dialogue_start(text, setname = add_dialogue_set) -> void: ## The id is automatically 1 instead of manual
	add_dialogue(text, 1, true, setname)

func add_dialogue_start_quote(text, setname = add_dialogue_set) -> void: 
	add_dialogue_start("\"" + text + "\"", setname)

func add_dialogue_continue(text, id = add_dialogue_id, setname = add_dialogue_set ) -> void: # Adds dialogue on same line (making it not necessary to set the id and then set to true first_text)
	add_dialogue(text, id, true, setname)

func add_dialogue_continue_no_space(text, id = add_dialogue_id, setname = add_dialogue_set) -> void: # Same as add_dialogue_continue, expect if auto_space is enabled, it will not add a auto space to the same line
	add_dialogue(text, id, true, setname, 1, false)

func add_dialogue_quote(text, id = add_dialogue_id, first_text = false, setname = add_dialogue_set, speed = 1) -> void:
	add_dialogue("\"" + text + "\"", id, first_text, setname, speed)

func next_add_dialogue_id() -> void:
	add_dialogue_id = add_dialogue_id + 1
	
func next_dialogue() -> void: # Go into the next dialogue after a dialogue's text is finished displaying
	pause_dialogue(true)
	await self.text_animation_finished
	dialogue_index += 1
	play_dialogue()
	pause_dialogue(false)

func delay_dialogue(timer, clear_dialogue = false) -> void: # Delays a dialogue text
	add_dialogue("", add_dialogue_id, true, add_dialogue_set)
	add_dialogue_special(delay_text, [timer])
	if clear_dialogue:
		add_dialogue_special(reset_dialogue)

func dialogue_fade_in() -> void:
	pause_dialogue(false)
	dialogue_state("fade_in")

func dialogue_fade_out() -> void:
	pause_dialogue(true)
	dialogue_state("fade_out")

func delay_text(time) -> void:
	pause_dialogue(true)
	await get_tree().create_timer(time).timeout
	dialogue_index += 1
	play_dialogue()
	pause_dialogue(false)

func set_add_dialogue_id(id) -> void:
	add_dialogue_id = id

func fastskip_pause() -> void:
	if ignore_text_full_display_fast_skip:
		ignore_text = false

func fastskip_unpause() -> void:
	if ignore_text_full_display_fast_skip:
		ignore_text = true

func fast_skip_button() -> void:
	if Input.is_action_pressed("fast_skip"):
		if !allowed_fast_skip:
			return
		
		if paused:
			return
		
		if can_fast_skip and !dialogue_ended:
			if tweenthing and ignore_text:
				if tweenthing.is_running():
					tweenthing.stop()
					tweenthing.custom_step(10)
				tweenthing.kill()
			can_fast_skip = false
			
			if ignore_text:
				dialogue_index += 1
			else:
				if finished:
					dialogue_index += 1
			
			#print_rich("[color=red]Current dialogue index from fast skip button: [/color]" + str(dialogue_index) + "\n")
			play_dialogue(ignore_text)
			await get_tree().create_timer(fast_skip_delay).timeout
			can_fast_skip = true


func load_dialogue(id, loadinstant = true, set_id: String = dialogue_current_set) -> void: # This loads all the dialogue into the text
	dialogue_current_id = id
	dialogue_current_set = set_id
	
	if loadinstant:
		finished = true
		
		if enable_icon_text:
			if _use_default_icon_behavior:
				icon_text.set_visible(true)
			else:
				show_icon_modular()
		
		dialogue_node.visible_characters = dialogue_dictionary[dialogue_index][1]
	else:
		dialogue_node.visible_characters = 0 
		#print_rich("[color=goldenrod]Max Visible from load dialogue: [/color]" + str(maxvisible))
	reset_dialogue()
	for test in dialogue_dictionary.size():
		if set_id == dialogue_dictionary[test + 1][3]:
			if id == dialogue_dictionary[test + 1][2]:
				dialogue_node.text += dialogue_dictionary[test + 1][0]
	
	emit_signal("load_dialogue_finished")

func load_dialogue_set(set_id: String, load_instant = true) -> void:
	dialogue_current_set = set_id
	for check in dialogue_dictionary.size():
		if set_id == dialogue_dictionary[check + 1][3]:
			dialogue_index = (check + 1)
			#print("Current dialogue index: " + str(dialogue_index))
			break
	finished = false
	load_dialogue(1, load_instant, set_id)
	maxvisible = dialogue_dictionary[dialogue_index][1]
	
	if load_instant == false:
		if tweenthing:
			tweenthing.kill()
		tweenthing = get_tree().create_tween()
		tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * default_text_speed).from(0)
		
	check_dialogue_function()

func load_dialogue_start(id: int = 1, set_id: String = "start", loadinstant = true, load_func = true, play_tween = false) -> void: # Sets the max visible when loading dialogue by start
	dialogue_started = true
	
	if id == 1 and set_id == "start":
		dialogue_index = 1
		load_dialogue(id, loadinstant, set_id)
	else:
		for k in dialogue_dictionary.size():
			if set_id == dialogue_dictionary[k + 1][3]:
				if id == dialogue_dictionary[k + 1][2]:
					dialogue_index = k + 1
#					print(dialogue_dictionary[k + 1][0])
					load_dialogue(id, loadinstant, set_id)
					break
	if load_func:
		load_function_dialogue()
	
	check_dialogue_function()
	maxvisible = dialogue_dictionary[dialogue_index][1]
	if play_tween:
		if _use_default_icon_behavior:
			icon_text.set_visible(false)
		else:
			hide_icon_modular()
		
		finished = false
		if tweenthing:
			if tweenthing.is_running():
				tweenthing.stop()
				tweenthing.custom_step(10)
			tweenthing.kill()

		wait_for_anim_func()

		if check_wait_for_anim:
			await animation_text_fading_in
			tweenthing = get_tree().create_tween()
			tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
			tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * default_text_speed).from(0)
		else:
			tweenthing = get_tree().create_tween()
			tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
			tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * default_text_speed).from(0)


func check_dialogue_function() -> void:
	if function_array_numbers.has(dialogue_index):
		for i in function_dialogue_dictionary.size():
			if dialogue_index == function_dialogue_dictionary[i + 1][0]:
				var function = function_dialogue_dictionary[i + 1][1]
				var arguments = function_dialogue_dictionary[i + 1][2]
				
				function.callv(arguments)

func dialogue_system() -> void: # Checks if space button is pressed, right click and etc! [Runs every frame]
	if !dialogue_started:
		return
	
	hide_darkbackground()
	
	if disabled: # above: functions that works even if dialogue system is disabled, below: functions that only works if dialogue system is not disabled
		return
	
	if Input.is_action_just_pressed("ui_accept") and !dialogue_ended:
		if !paused and !forced_paused:
			if finished:
				dialogue_index += 1
			play_dialogue()
			#print("Current dialogue index: " + str(dialogue_index) + "\n")
	
	if !paused and !forced_paused:
		fast_skip_button()

func hide_darkbackground() -> void:
	if Input.is_action_just_pressed("right_click"):
		$Text.visible = !$Text.visible

func play_dialogue(ignore_textanimation: bool = false) -> void: # This will start the dialogue [Making the dialogue appear]
	if enable_icon_text:
		if _use_default_icon_behavior:
			icon_text.set_visible(false)
		else:
			hide_icon_modular()
	
	if !dialogue_dictionary.has(dialogue_index) or !dialogue_dictionary[dialogue_index][3] == dialogue_current_set:
		emit_signal("end_dialogue_signal")
		return
	
	finished = false
	
	paused = true
	#print("Start of play dialogue: " + str(paused))
	
	# create tweens thing
	
	if tweenthing:
		if tweenthing.is_running():
			tweenthing.stop()
			tweenthing.custom_step(10)
			if !ignore_textanimation:
				paused = false
				tweenthing.emit_signal("finished")
				#print_rich("[color=forest_green]tween forced to display full! [/color]")
				#print_rich("[color=forest_green]Max visible currently: [/color]" + str(maxvisible))
				return
		tweenthing.kill()
	
	check_dialogue_function()
	
	if _animation_player.get_current_animation() == "fade_out":
		if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
			maxvisible = dialogue_dictionary[dialogue_index][1]
		else:
			maxvisible = maxvisible + dialogue_dictionary[dialogue_index][1]
		#print_rich("[color=purple]Before animation_started[/color]")
		await _animation_player.animation_started
		#print_rich("[color=purple]after animation_started[/color]")
		if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
			reset_dialogue()
		await get_tree().create_timer(0.15).timeout # figured out something: paused variable doesn't work
		#print_rich("[color=purple]0.15 delay signal[/color]")
		paused = false
		
		tweenthing = get_tree().create_tween()
		tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * default_text_speed).from(maxvisible - dialogue_dictionary[dialogue_index][1])
	else:
		if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
			maxvisible = dialogue_dictionary[dialogue_index][1]
		else:
			maxvisible = maxvisible + dialogue_dictionary[dialogue_index][1]
		
		paused = false
		tweenthing = get_tree().create_tween()
		tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * default_text_speed).from(maxvisible - dialogue_dictionary[dialogue_index][1]) # old method of speed:  / 50 + 1
	
	if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
		dialogue_current_id += 1
		emit_signal("dialogue_next_page", dialogue_current_id)
		load_dialogue(dialogue_current_id, false)

func reset_dialogue() -> void:
	dialogue_node.text = ""

func _process(_delta: float) -> void:
	dialogue_system()

func end_dialogue() -> void:
	reset_dialogue()
	dialogue_ended = true
	print_rich("[color=crimson]The current dialogue has ended.[/color]")

func load_function_dialogue() -> void: # Checks for functions on dialogue dictionary. If it finds a function, adds the dialogue index to array
	for i in function_dialogue_dictionary.size():
		function_array_numbers.append(function_dialogue_dictionary[i + 1][0])
	#print(function_array_numbers)


func set_character_emotion(character, emotion: String, delay: float = default_emotion_delay_end) -> void:
	if Input.is_action_pressed("fast_skip"):
		set_character_emotion_instant(character, emotion)
	else:
		disabled = true
		dialogue_state("fade_out")
		
		await _animation_player.animation_finished
		
		#print("the set character function has been called")
		set_character_emotion_instant(character, emotion, true)
		
		await get_tree().create_timer(delay).timeout
		
		dialogue_state("fade_in")
		disabled = false

func set_character_emotion_instant(character, emotion: String, playShow: bool = false) -> void:
	emotion = emotion.to_upper()
	
	if not emotion in character.emotions:
		return
	
	if !Input.is_action_pressed("fast_skip"):
		#print_debug("fast skip is not pressed")
		#print(character.visible)
		#print(character.is_hidden())
		if character.visible and not character.is_hidden() and playShow:
			#print_debug("conditions passed")
			var tween = get_tree().create_tween()
			character.set_modulate(Color(character.modulate.r, character.modulate.g, character.modulate.b, 0))
			tween.tween_property(character, "modulate", Color(character.modulate.r, character.modulate.g, character.modulate.b, 1), 0.35)
			#playanim_character_instant(character, "show")
	
	character.current_emotion = emotion

func setpos_character(character: DemoScripter_VisualNovelCharacter, pos, fast_skipable: bool = true) -> void: # Set position of a character with delay
	if Input.is_action_pressed("fast_skip") and fast_skipable:
		setpos_character_instant(character, pos)
		return
	
	dialogue_fade_out()
	
	await _animation_player.animation_finished
	setpos_character_instant(character, pos)
	await get_tree().create_timer(0.35).timeout
	
	dialogue_fade_in()


func setpos_character_instant(character: DemoScripter_VisualNovelCharacter, pos) -> void: # Set position of a character
	match pos:
		"right":
			character.position = character.pos_right
		"middle":
			character.position = character.pos_middle
		"left":
			character.position = character.pos_left
		_:
			character.position = pos

func playanim_character(character, anim, speed = 1) -> void:
	disabled = true
	dialogue_state("fade_out")
	
	await _animation_player.animation_finished
	
	playanim_character_instant(character, anim, speed)
	
	await character.anim_player.animation_finished
	
	dialogue_state("fade_in")
	disabled = false

func playanim_character_instant(character, anim: String, speed = 1) -> void:
	character.anim_player.play(anim)
	character.anim_player.set_speed_scale(speed)

func playanim_object(object, animation) -> void:
	object.play(animation)

func show_character(character, duration: float = 0.35, hold: float = 0, fast_skipable: bool = true):
	if Input.is_action_pressed("fast_skip") and fast_skipable:
		character.modulate = Color(character.modulate.r, character.modulate.g, character.modulate.b, 1)
		character.set_visible(true)
		return
	
	dialogue_fade_out()
	await _animation_player.animation_finished
	
	character.set_modulate(Color(character.modulate.r, character.modulate.g, character.modulate.b, 0))
	character.set_visible(true)
	
	var tween = get_tree().create_tween()
	tween.tween_property(character, "modulate", Color(character.modulate.r, character.modulate.g, character.modulate.b, 1), duration)
	await tween.finished
	
	character.emit_signal("show_finished")
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		dialogue_fade_in()
	else:
		dialogue_fade_in()

func show_character_instant(character, duration: float = 0.35) -> void:
	character.set_modulate(Color(character.modulate.r, character.modulate.g, character.modulate.b, 0))
	character.set_visible(true)
	
	var tween = get_tree().create_tween()
	tween.tween_property(character, "modulate", Color(character.modulate.r, character.modulate.g, character.modulate.b, 1), duration)
	await tween.finished
	character.emit_signal("show_finished")
	

func hide_character(character, duration: float = 0.35, hold: float = 0, fast_skipable: bool = true):
	if Input.is_action_pressed("fast_skip") and fast_skipable:
		character.modulate = Color(character.modulate.r, character.modulate.g, character.modulate.b, 0)
		character.set_visible(false)
		return

	dialogue_fade_out()
	await _animation_player.animation_finished
	
	if duration > 0:
		var tween = get_tree().create_tween()
		tween.tween_property(character, "modulate", Color(character.modulate.r, character.modulate.g, character.modulate.b, 0), duration)
		await tween.finished
	else:
		character.modulate = Color(character.modulate.r, character.modulate.g, character.modulate.b, 0)
	
	character.emit_signal("hide_finished")
	character.set_visible(false)
	
	if hold > 0:
		await get_tree().create_timer(hold).timeout
		dialogue_fade_in()
	elif hold < 0:
		return
	else:
		dialogue_fade_in()

func hide_character_instant(character, duration: float = 0.35) -> void:
	if duration > 0:
		var tween = get_tree().create_tween()
		tween.tween_property(character, "modulate", Color(character.modulate.r, character.modulate.g, character.modulate.b, 0), duration)
		await tween.finished
	else:
		character.modulate = Color(character.modulate.r, character.modulate.g, character.modulate.b, 0)
	
	character.set_visible(false)
	character.emit_signal("hide_finished")
	

func pause_dialogue(value: bool) -> void:
	forced_paused = value
	allowed_fast_skip = !value

#region MUSIC_AUDIO

func play_audio(audio: AudioStreamPlayer) -> void:
	audio.play()

func stop_audio(audio: AudioStreamPlayer) -> void:
	audio.stop()

func play_music(music: AudioStreamPlayer) -> void:
	music.play()

func stop_music(music: AudioStreamPlayer) -> void:
	music.stop()

func play_music_wait_signal(music) -> void:
	if Input.is_action_pressed("fast_skip"):
		play_music(music)
	else:
		await _animation_player.animation_started
		play_music(music)

func play_audio_wait_signal(audio) -> void:
	if Input.is_action_pressed("fast_skip"):
		play_audio(audio)
	else:
		await _animation_player.animation_started
		play_audio(audio)

func fadein_music(music: AudioStreamPlayer, duration: float, config_arg: Dictionary = {}) -> void:
	if music.has_meta("isFadingOut") and music.get_meta("isFadingOut"):
		music.get_meta("fadeOutTween").kill()
	
	music.set_meta("isFadingIn", true)
	
	var default_config: Dictionary = {
		"volume_to": 0,
		"use_node_old_volume_as_to": false,
		"set_node_volume_to_55": true,
		"pause": false
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var musictween = get_tree().create_tween()
	var music_volume_to: float

	music.set_meta("fadeInTween", musictween)
	
	if config["use_node_old_volume_as_to"]:
		music_volume_to = music.volume_db
	else:
		music_volume_to = config["volume_to"]
	
	if config["set_node_volume_to_55"]:
		music.volume_db = -55
	
	if music_volume_to == -55:
		music_volume_to = 0
	
	if !music.playing:
		if config["pause"]:
			pause_music(music)
		else:
			music.play()
	
	musictween.tween_property(music, "volume_db", music_volume_to, duration)
	musictween.tween_callback(music.remove_meta.bind("fadeInTween"))
	musictween.tween_callback(music.remove_meta.bind("isFadingIn"))

func fadeout_music(music: AudioStreamPlayer, duration: float, config_arg: Dictionary = {}) -> void:
	if music.has_meta("isFadingIn") and music.get_meta("isFadingIn"):
		music.get_meta("fadeInTween").kill()
	
	music.set_meta("isFadingOut", true)
	
	var default_config: Dictionary = {
		"volume_from": 0,
		"set_custom_volume_to": null,
		"pause": false
	}
	
	var config: Dictionary = _create_config_dict(default_config, config_arg)
	
	var musictween = get_tree().create_tween()
	music.set_meta("fadeOutTween", musictween)
	
	if config["set_custom_volume_to"]:
		musictween.tween_property(music, "volume_db", config["set_custom_volume_to"], duration)
	else:
		musictween.tween_property(music, "volume_db", -55, duration)
	musictween.tween_callback(music.remove_meta.bind("fadeOutTween"))
	if config["pause"]:
		musictween.tween_callback(music.set_meta.bind("isFadingOut", false))
		musictween.tween_callback(pause_music.bind(music))
		return
	musictween.tween_callback(music.set_meta.bind("isFadingOut", false))
	musictween.tween_callback(music.stop)
	

func set_music_pitch(music, pitch):
	music.set_pitch_scale(pitch)

func pause_music(music, wait_for_anim = false):
	# maybe make the wait_for_anim emits a signal when the animation is fading in?
	if wait_for_anim: # this is used in cases first dialogue of set contains a special function that makes the hud transparent
		wait_for_anim_func()
		await self.animation_text_fading_in
		music.stream_paused = !music.stream_paused
		print("Music stream paused: " + str(music.stream_paused))
	else:
		music.stream_paused = !music.stream_paused
		print("Music stream paused: " + str(music.stream_paused))

#endregion

#region MODULAR

func load_icon_modules() -> void:
	_use_default_icon_behavior = false
	for k in icon_modular:
		k.connect_module(self)

func show_icon_modular() -> void:
	for k in icon_modular:
		k.show_icon()

func hide_icon_modular() -> void:
	for k in icon_modular:
		k.hide_icon()

func load_extra_modules() -> void:
	for k in extra_modular:
		k.connect_module(self)

#endregion

func dialogue_state(state: String) -> void:
	match state:
		"hide":
			darkbackground_node.hide()
			dialogue_node.hide()
		"show":
			darkbackground_node.show()
			dialogue_node.show()
		"fade_in":
			_animation_player.play("fade_in")
		"fade_out":
			_animation_player.play("fade_out")

func wait_for_anim_func() -> void:
	if _animation_player.get_current_animation() == "fade_out":
		check_wait_for_anim = true
		await _animation_player.animation_started
		await get_tree().create_timer(0.15).timeout
		emit_signal("animation_text_fading_in")
	else:
		check_wait_for_anim = false

func wait_signal_func(signalName, funcname: Callable, args: Array = [], fast_skipable: bool = true) -> void:
	if Input.is_action_pressed("fast_skip") and fast_skipable:
		funcname.callv(args)
		return
	
	await signalName
	funcname.callv(args)

func _on_text_tween_completed() -> void:
	if dialogue_ended:
		return

	finished = true
	emit_signal( "text_animation_finished" )
	#print_rich("[color=cyan]" + str(finished) + "[/color]")
	
	if !enable_icon_text:
		print("false, returning")
		return
	
	if !paused and !forced_paused:
		if _use_default_icon_behavior:
			icon_text.set_visible(true)
			return
		
		show_icon_modular()

#region CONFIG_UTILS
# TODO: maybe make a DemoScripterUtils global node in the future? probably after refactoring the
# framework, tbh (around v1.0.0)

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

func _create_config_dict(default_config: Dictionary, config_arg: Dictionary) -> Dictionary:
	assert(_check_same_keys_dict(default_config, config_arg), "Invalid key in config argument!")
	
	var config = default_config.duplicate()
	if !config_arg.is_empty():
		config.merge(config_arg, true)
	
	return config

func _remove_config_keys(config_arg: Dictionary, keys: Array) -> Dictionary:
	var config = config_arg.duplicate()
	
	for k in config.keys():
		if k in keys:
			config.erase(k)
	
	return config
