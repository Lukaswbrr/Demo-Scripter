class_name DemoScripter_VisualNovelCharacter
extends Node

@onready var anim_player = $AnimationPlayer

@export var pos_middle: Vector2
@export var pos_left: Vector2
@export var pos_right: Vector2

#enum emotions { -- Example for setting up emotions
#	NORMAL, 
#	HAPPY,
#	SAD,
#}

func set_current_position(pos):
	self.position = pos
