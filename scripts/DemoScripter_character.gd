class_name DemoScripter_VisualNovelCharacter
extends Node2D

signal hide_finished
signal show_finished

@onready var emotion_player: AnimationPlayer = $EmotionPlayer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var pos_middle: Vector2
@export var pos_left: Vector2
@export var pos_right: Vector2

var current_emotion: String: set = set_emotion
var emotions: Array

func add_emotion(emotion: String) -> void:
	emotions.append(emotion)

func auto_add_emotions() -> void:
	for k in emotion_player.get_animation_list():
		add_emotion(k)

func set_default_emotion(emotion: String) -> void:
	if not emotion in emotions:
		return
	
	current_emotion = emotion

func set_emotion(emotion: String) -> void:
	if not emotion in emotions:
		return
	
	current_emotion = emotion
	emotion_player.play(emotion)

func set_modulate_transition(newColor: Color, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", newColor, duration)

func is_hidden() -> bool:
	return anim_player.current_animation == "hide"

func hide_character():
	set_visible(false)

func show_character():
	set_visible(true)
