class_name DemoScripter_VisualNovelScene
extends CanvasLayer

## This is the base that handles the current scene (dialogue, set characters, play music, etc)

signal text_animation_finished
signal animation_text_fading_in
signal end_dialogue_signal

@onready var dialogue_node = $Text/Dialogue
@onready var darkbackground_node = $Text/DarkBackground
@onready var _animation_player = $Text/DarkBackground/AnimationPlayer
@onready var icon_text = $Text/IconText

var dialogue_dictionary: Dictionary = {}
var function_dialogue_dictionary: Dictionary = {}

var function_array_numbers: Array = []

# Current dialogue IDs

var dialogue_index: int = 1 # The current dialogue displaying
var dialogue_current_id: int = 1 # The current group of dialogue [example, list of dialogues with ID 1]

# Add dialogue id

var add_dialogue_id: int = 1

# Dialogue states and system variables

var finished: bool
var paused: bool
var disabled: bool
var loadanimation: bool
var dialogue_ended: bool
var check_wait_for_anim: bool # checks if the current animation_player is fade_out for wait_for()_func to run
var dialogue_started: bool

## Regex for filtering [] tags
var regex = RegEx.new()

# Variables for tween
var tweenthing
var maxvisible = 0

var dialogue_current_set: int = 1 # The current set of dialogue (example set 1 is normal route, set 2 is different route, etc)
var add_dialogue_set: int = 1

@export_group("Text")
@export var auto_space: bool = true ## Adds a space on texts that doesn't start with "
@export var enable_icon_text: bool = true ## A icon appears after a text is finished displaying.
@export var default_text_speed: bool = 0.030 ## Duration of text_speed (this value gets multipled) [if i add the feature of every text having different speed, use the speed argument from add_dialogue]

var allowed_fast_skip: bool = true ## Checks if it's allowed to use fast skip
var can_fast_skip: bool = true ## If true, player can use fast skip [for rate of fire delay]

@export_group("Fast Skip")
@export var fast_skip_delay: float = 0.15 ## The delay of fast skip
@export var ignore_text_full_display_fast_skip: bool = true ## If true, text will not be display at full if text wasn't fully displayed.

@export_group("Character variables")
@export var default_emotion_delay_end: float = 0.35

@onready var ignore_text: bool = ignore_text_full_display_fast_skip
var forced_paused = false ## Checks if its paused caused by pause_dialogue
var about_to_pause = false ## Checks if its going to be pause at the of dialogue (used for fast skip not go to next dialouge)

var regex_compiled = false

func start_regex_compile() -> void:
	regex.compile("\\[.*?\\]")
	regex_compiled = true

func _ready() -> void:
	pass

func add_dialogue(text, id = add_dialogue_id, first_text = false, set = add_dialogue_set, _speed = 1) -> void:
	if !regex_compiled:
		start_regex_compile() 
	
	if auto_space:
		if text.begins_with("\n"):
			if !text[text.count("\n")] == '"': # do not add space if its a quote that uses multiple new lines
				text = text.insert(text.count("\n"), " ")
	
	var notags_text = regex.sub(text, "", true)
	
	add_dialogue_id = id
	add_dialogue_set = set
	
	#	Some information about the values in the dictionary:
#		1: Text of the dialogue
#		2: Number of words the text has
#		3: ID that the dialogue was added in
#		4: Function if the dialogue has one
#		5: Speed of the dialogue (probably)
	
	if !first_text:
#		print(str(text.begins_with("\"")) + ": " + str(text))
		if !auto_space: # checks if auto space is enabled
			dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + text), len(str("\n") + notags_text), id, set]
		else:
			if text.begins_with("\""):
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + text), len("\n" + notags_text), id, set]
			else:
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str("\n" + " " + text), len("\n" + notags_text) + 1, id, set]
	else:
		if !auto_space: # checks if auto space is enabled
			dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(text), len(notags_text), id, set]
		else:
			if text.begins_with("\""):
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(text), len(notags_text), id, set]
			else:
				dialogue_dictionary[dialogue_dictionary.size() + 1] = [str(" " + text), len(notags_text) + 1, id, set]

func add_dialogue_special(funcname: Callable, args = null) -> void: # Arguments for function must be a array
	var arguments_array = []
	
	if !args == null:
		arguments_array = args
	
	function_dialogue_dictionary[function_dialogue_dictionary.size() + 1] = [dialogue_dictionary.keys().back(), funcname, arguments_array]
	
	# This function adds a dialogue to a array with a function as a extra value, making it possible to
	# run code if the id is the same as the special dialogue. (Example: changing character emotion, etc)

func add_dialogue_start(text, id = add_dialogue_id, set = add_dialogue_set) -> void: # same as add_dialogue_continue (just named it to make it more easier to read)
	add_dialogue(text, id, true, set)

func add_dialogue_start_quote(text, id = add_dialogue_id, set = add_dialogue_set, speed = 1) -> void: 
	add_dialogue("\"" + text + "\"", id, true, set, speed)

func add_dialogue_continue(text, id = add_dialogue_id, set = add_dialogue_set ) -> void: # Adds dialogue on same line (making it not necessary to set the id and then set to true first_text)
	add_dialogue(text, id, true, set)

func add_dialogue_quote(text, id = add_dialogue_id, first_text = false, set = add_dialogue_set, speed = 1) -> void:
	add_dialogue("\"" + text + "\"", id, first_text, set, speed)

func next_add_dialogue_id() -> void:
	add_dialogue_id = add_dialogue_id + 1
	
func next_dialogue() -> void: # Go into the next dialogue after a dialogue's text is finished displaying
	var icon_enabled = enable_icon_text
	if icon_enabled:
		enable_icon_text = false
	
	#print(enable_icon_text)
	pause_dialogue(true)
	await self.text_animation_finished
	
	dialogue_index += 1
	play_dialogue()
	#print(enable_icon_text)
	pause_dialogue(false)
	
	if icon_enabled:
		await get_tree().create_timer(0.01).timeout # i don't really like this solution. Maybe theres some other way to deal with this problem.
		enable_icon_text = true

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


func load_dialogue(id, loadinstant = true, set_id = dialogue_current_set) -> void: # This loads all the dialogue into the text
	dialogue_current_id = id
	dialogue_current_set = set_id
	
	if loadinstant:
		finished = true
		
		if enable_icon_text:
			icon_text.set_visible(true)
		
		dialogue_node.visible_characters = dialogue_dictionary[dialogue_index][1]
	else:
		dialogue_node.visible_characters = 0
		#print_rich("[color=goldenrod]Max Visible from load dialogue: [/color]" + str(maxvisible))
	reset_dialogue()
	for test in dialogue_dictionary.size():
		if set_id == dialogue_dictionary[test + 1][3]:
			if id == dialogue_dictionary[test + 1][2]:
				dialogue_node.text += dialogue_dictionary[test + 1][0]

func load_dialogue_set(set_id, load_instant = true) -> void:
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
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * 0.030).from(0)
		
	check_dialogue_function()

func load_dialogue_start(id = 1, set_id = 1, loadinstant = true, load_func = true, play_tween = false) -> void: # Sets the max visible when loading dialogue by start
	dialogue_started = true
	
	if id == 1 and set_id == 1:
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
		icon_text.set_visible(false)
		finished = false
		if tweenthing:
			if tweenthing.is_running():
				tweenthing.stop()
				tweenthing.custom_step(10)
			tweenthing.kill()

		wait_for_anim_func()

		if check_wait_for_anim:
			await self.animation_text_fading_in
			tweenthing = get_tree().create_tween()
			tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
			tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * 0.030).from(0)
		else:
			tweenthing = get_tree().create_tween()
			tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
			tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * 0.030).from(0)


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
		icon_text.set_visible(false)
	
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
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * 0.030).from(maxvisible - dialogue_dictionary[dialogue_index][1])
	else:
		if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
			maxvisible = dialogue_dictionary[dialogue_index][1]
		else:
			maxvisible = maxvisible + dialogue_dictionary[dialogue_index][1]
		
		paused = false
		tweenthing = get_tree().create_tween()
		tweenthing.connect("finished", Callable(self, "_on_text_tween_completed"))
		tweenthing.tween_property(dialogue_node, "visible_characters", maxvisible, dialogue_dictionary[dialogue_index][1] * 0.030).from(maxvisible - dialogue_dictionary[dialogue_index][1]) # old method of speed:  / 50 + 1
	
	if !dialogue_dictionary[dialogue_index][2] == dialogue_current_id:
		dialogue_current_id += 1
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


func set_character_emotion(character, emotion) -> void:
	disabled = true
	dialogue_state("fade_out")
	
	await _animation_player.animation_finished
	
	#print("the set character function has been called")
	set_character_emotion_instant(character, emotion)
	
	await get_tree().create_timer(0.35).timeout
	
	dialogue_state("fade_in")
	disabled = false

func set_character_emotion_instant(character, emotion) -> void:
	emotion = emotion.to_upper()
	character.current_emotion = character.emotions[emotion]

func setpos_character(character, pos) -> void: # Set position of a character with delay
	disabled = true
	dialogue_state("fade_out")
	
	await _animation_player.animation_finished
	setpos_character_instant(character, pos)
	await get_tree().create_timer(0.35).timeout
	
	dialogue_state("fade_in")
	disabled = false


func setpos_character_instant(character, pos) -> void: # Set position of a character
	match pos:
		"right":
			character.position = character.pos_right
		"middle":
			character.position = character.pos_middle
		"left":
			character.position = character.pos_left

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

func pause_dialogue(value: bool) -> void:
	forced_paused = value
	allowed_fast_skip = !value


# MUSIC/AUDIO FUNCTIONS

func play_audio(audio):
	audio.play()

func stop_audio(audio):
	audio.stop()

func play_music(music) -> void:
	music.play()

func stop_music(music) -> void:
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

func fadein_music(music, duration: float) -> void:
	var musictween = get_tree().create_tween()
	var music_oldvalue = music.volume_db
	music.volume_db = -55
	
	if music_oldvalue == -55:
		music_oldvalue = 0
	
	musictween.tween_property(music, "volume_db", music_oldvalue, duration)
	#print(music_oldvalue)

func fadeout_music(music, duration: float) -> void:
	var musictween = get_tree().create_tween()
	var music_oldvalue = music.volume_db
	musictween.tween_property(music, "volume_db", -55, duration)
	await musictween.finished
	music.stop()

# ---------------------

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
		icon_text.set_visible(true)
