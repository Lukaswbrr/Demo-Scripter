class_name DemoScripter_VisualNovelCharacter
extends Node2D
## Base class for characters to be used on [DemoScripter_VisualNovelScene]
##
## Base class for characters to be used on [DemoScripter_VisualNovelScene].
##
## @tutorial (Creating characters for DemoScripter): https://github.com/Lukaswbrr/Demo-Scripter/blob/main/docs/getting_started/overview.md#creating-characters-using-the-framework

## Emitted when the character is fully hided.
## @experimental: Doesn't get emitted at all. Will be reworked on v1.0.0.
signal hide_finished
## Emitted when the character is fully showed.
## @experimental: Doesn't get emitted at all. Will be reworked on v1.0.0.
signal show_finished

## The emotion player is used to set the character's [AnimatedSprite] to a different value.
## Can also be used to other things, too.
@onready var emotion_player: AnimationPlayer = $EmotionPlayer
## The animation player of the character.
## For example, show and hide animation.
@onready var anim_player: AnimationPlayer = $AnimationPlayer

## The position the character will be on when [method DemoScripter_VisualNovelScene.setpos_character] 
## targets this character with [param pos] "right".
@export var pos_middle: Vector2
## The position the character will be on when [method DemoScripter_VisualNovelScene.setpos_character] 
## targets this character with [param pos] "left".
@export var pos_left: Vector2
## The position the character will be on when [method DemoScripter_VisualNovelScene.setpos_character] 
## targets this character with [param pos] "middle".
@export var pos_right: Vector2

## The current emotion of this character.
var current_emotion: String: set = set_emotion
## The emotions of this character. Can be added via [method add_emotion] or [method auto_add_emotion].
var emotions: Array

## Adds a emotion to [member emotions].
func add_emotion(emotion: String) -> void:
	emotions.append(emotion)

## Helper function for [method add_emotion] where it gets all the emotions from [member emotion_player]
## and runs [method add_emotion] for every emotion.
func auto_add_emotions() -> void:
	for k in emotion_player.get_animation_list():
		add_emotion(k)

## Sets the default emotion of the character.
## Does not play [member emotion_player].
## @experimental: Will be reworked on v1.0.0.
func set_default_emotion(emotion: String) -> void:
	if not emotion in emotions:
		return
	
	current_emotion = emotion

## Sets the emotion of the character.
## @experimental: Will be reworked on v1.0.0.
func set_emotion(emotion: String) -> void:
	if not emotion in emotions:
		return
	
	current_emotion = emotion
	emotion_player.play(emotion)

## Sets the [member modulate] of this character with a [Tween] transition.
## [br]
## [br]
## [param newColor] is the color the character will go to.
## [br]
## [param duration] is how long the transition duration will be.
func set_modulate_transition(newColor: Color, duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", newColor, duration)

## Checks if the [member anim_player]'s current animation is hide.
## @experimental: May be reworked in V1.0.0?????? This doesn't check if the character's [member visible] is false.
func is_hidden() -> bool:
	return anim_player.current_animation == "hide"

## Hides character.
## Makes it invisible without animation.
func hide_character():
	set_visible(false)

## Shows character.
## Makes it visible without animation.
func show_character():
	set_visible(true)
