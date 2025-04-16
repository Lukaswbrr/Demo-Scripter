class_name DemoScripter_IconEndText_IconModule
extends DemoScripter_IconModule

var paragraph = TextParagraph.new()

@export var legacy_icon_pos = false ## If true, icon will not update position on text end

var font
var font_size

func _ready() -> void:
	# Add the text to the paragraph with the loaded font and with font size 32
	# Set the max width to 300
	pass

func _hide_icon() -> void:
	icon_node.set_visible(false)

func _show_icon() -> void:
	icon_node.set_visible(true)
	update_dialogue_icon()

func _connect_module(node: DemoScripter_VisualNovelScene) -> void:
	font = _dialogue_node.get_theme_font("normal_font")
	font_size = _dialogue_node.get_theme_font_size("normal_font_size")
	paragraph.width = _dialogue_node.size.x
	
	
	await _main_visualnovel_scene.load_dialogue_finished
	update_icon_text_pos()
	update_dialogue_icon()


func update_icon_text_pos():
	# Get the primary text server
	var text_server = TextServerManager.get_primary_interface()
	var x = _dialogue_node.position.x
	var y = _dialogue_node.position.y
	var ascent = 0.0
	var descent = 0.0
	
	# for each line
	for i in paragraph.get_line_count():
		# reset x
		x = _dialogue_node.position.x
		# get the ascent and descent of the line
		ascent = paragraph.get_line_ascent(i)
		descent = paragraph.get_line_descent(i)

		# get the rid of the line
		var line_rid = paragraph.get_line_rid(i)
		# get all the glyphs that compose the line
		var glyphs = text_server.shaped_text_get_glyphs(line_rid)

		# for each glyph
		for glyph in glyphs:
			# get the advance (how much the we need to move x)
			var advance = glyph.get("advance", 0)
			# get the offset, I'm not sure what this does but it may be needed
			var offset = glyph.get("offset", Vector2.ZERO)
			# add the advance to x
			x += advance
			#print(x)
		# update y with the ascent and descent of the line
		y += ascent + descent
	
	#print(x, y)
	icon_node.position = Vector2(x, y)

func update_dialogue_icon():
	paragraph.clear()
	paragraph.add_string(get_visible_dialogue_text(), font, font_size)
	update_icon_text_pos()

func get_visible_dialogue_text():
	var _dialogue_text = _dialogue_node.text
	var dialogue_visible_characters = _dialogue_node.visible_characters
	
	var final_text = _dialogue_text.left(dialogue_visible_characters)
	return final_text
