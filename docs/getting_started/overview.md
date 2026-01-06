>[!WARNING]
>In the future when DemoScripter is available as a Godot Addon, it's planned for DemoScripter to have a unique addon menu where you can create dialogue scenes and save them as Resources files! (which you can make translations on the addon menu too, making it easier to translate and save as .csv file)
>This page MAY be obsolute in the future and only be used for legacy purposes. (but for now, it inst.)

# Creating a basic dialogue scene

1. Create a new CanvasLayer scene
2. Duplicate the VisualNovelScene_hud.tscn scene into the new CanvasLayer scene (make the HUD scene local)
3. Add a script to the new scene which extends DemoScripter_VisualNovelScene
4. Paste the example code
5. Run the scene
6. By pressing space (or any key binded to ui_accept), the text should proceed!

In step 2, the tree should look like this:

![tree screenshot](./images/tree_screenshot.png "Tree Screenshot")

## Example code

```gdscript
extends DemoScripter_VisualNovelScene


func _ready() -> void:
	add_dialogue_start("Hello World!")
	add_dialogue("testing dialogue")
	add_dialogue("test again moment")
	
	add_dialogue_start("This one is the next page", 2)
	add_dialogue("very cool")
	add_dialogue("moment")
	
	load_dialogue_start()


func _on_end_dialogue_signal() -> void:
	end_dialogue()
```

### In game screenshot

Note: The resolution of the project in this screenshot is set to 720x540 (the same of VisualNovelScene_hud.tscn)

![in game example 1](./images/in_game_example_1.png? "In game screenshot")

## Other examples

I made a [repository](https://github.com/Lukaswbrr/Demo-Scripter-Examples) which shows more examples using the framework.

# Adding dialogue

In the example above shows a very basic way of adding dialogue to a visual novel scene.

However, there are more functions related to dialogue, for example, creating dialogue on a different page, a different set, running functions, etc.

>[!NOTE] 
>Sets are like different groups of dialogue.
>By default, "start" is the main set of the dialogue.
>Sets can go to different sets, for example, you can use a button handler which shows different options that goes to a different set!
>Like "start" > "choice1" or "start" > "choice2".

>[!NOTE]
>Always remember to connect the end dialogue signal scene to the script!
>Otherwise, the dialogue wouldn't end!

## Dialogue Next function

Using the example above as reference, instead of setting manually the id using add_dialogue_start, you can use add_dialogue_next to create a new dialogue on a next page automatically!

```gdscript
extends DemoScripter_VisualNovelScene


func _ready() -> void:
	add_dialogue_start("Hello World again!")
	add_dialogue("testing dialogue again")
	add_dialogue("test again moment -again-")
	
	add_dialogue_next("This one is the next page, which automatically incremented to the next page without needing to set it manually!")
	add_dialogue("very cool")
	add_dialogue("moment")
	add_dialogue("amogus")
	
	load_dialogue_start()


func _on_end_dialogue_signal() -> void:
	end_dialogue()
```

## Dialogue Special

Dialogue specials is a type of dialogue that runs the function the moment the dialogue index is on the above dialogue line.

You can use this alongside Background Handler to change backgrounds, change characters emotions, positions, etc!

### Test function example

Here is a example with a custom defined function on the same scene, running add_dialogue_special.

The moment the index reaches 3, which is test dialogue special 2, it will run the function print_no_args, outputting !Hello World!" on the console.

![no args example 1](./images/print_no_args_example_1.png)
![no args example 2](./images/print_no_args_example_2.png)

```gdscript
extends DemoScripter_VisualNovelScene

func _ready() -> void:
	add_dialogue_start("Start of dialogue!")
	add_dialogue("test dialogue 1")
	add_dialogue("test dialogue special 2")
	add_dialogue("test dialogue 3")
	add_dialogue("test dialogue 4")
	
	load_dialogue_start()

func print_no_args() -> void:
	print("Hello World!")

func _on_end_dialogue_signal() -> void:
	end_dialogue()
```

### Test function with arguments example

Here is a example using a custom function that has two arguments.

You can execute the arguments in the second argument of add_dialogue_special, which is a array argument (accepts multiples arguments of the function you're calling.)

This example also includes the previous no arguments function!

![print args example 1](./images/print_args_example_1.png)
![print args example 2](./images/print_args_example_2.png)

```gdscript
extends DemoScripter_VisualNovelScene

func _ready() -> void:
	add_dialogue_start("Start of dialogue!")
	add_dialogue("test dialogue 1")
	add_dialogue("test dialogue special 2")
	add_dialogue_special(print_args, ["Hello World!", "How are you?"])
	add_dialogue("test dialogue 3")
	add_dialogue("test dialogue special 4")
	add_dialogue_special(print_no_args)
	
	load_dialogue_start()

func print_args(arg1: String, arg2: String) -> void:
	print("Arg1: " + arg1)
	print("Arg2: " + arg2)

func print_no_args() -> void:
	print("Hello World!")

func _on_end_dialogue_signal() -> void:
	end_dialogue()

```

### Character example

>[!NOTE]
>This will be used the Arcueid's character example!
>You can follow the creating a character section for the arcueid example or copy the arcueid folder from examples/characters to your godot project.

In this example, it will be tested functionality for making a character visible, change emotions, positions and make it invisible!

Once you have a character done, in this case Arcueid, create a Node2D named Characters in your visual novel scene. This is where the characters will be added.

![alt text](image.png)

>[!NOTE]
>You can add a control named Background with a ColorRect on it, if you want. It's just for a simple color background. (which is not used in the example)


Then, instantiate arcueid scene on Characters node.

![alt text](image-10.png)
![alt text](image-11.png)

Here is the code used for the example.

```gdscript
extends DemoScripter_VisualNovelScene


func _ready() -> void:
	add_dialogue_start("character example!")
	add_dialogue("angry")
	add_dialogue_special(set_character_emotion, [$Characters/Arcueid, "angry"])
	add_dialogue("angry 2")
	add_dialogue_special(set_character_emotion, [$Characters/Arcueid, "angry_2"])
	add_dialogue("surprised")
	add_dialogue_special(set_character_emotion, [$Characters/Arcueid, "SURPRISED"])
	
	add_dialogue_next("back to normal")
	add_dialogue_special(set_character_emotion, [$Characters/Arcueid, "NORMAL"])
	add_dialogue("doubt emotion")
	add_dialogue_special(set_character_emotion, [$Characters/Arcueid, "DOUBT"])
	add_dialogue_quote("Testing quote dialogue thing.")
	add_dialogue("yeah")
	add_dialogue_continue("it works")
	
	add_dialogue_next("testing left")
	add_dialogue_special(setpos_character, [$Characters/Arcueid, "left"])
	add_dialogue("right")
	add_dialogue_special(setpos_character, [$Characters/Arcueid, "right"])
	add_dialogue("back to middle")
	add_dialogue_special(setpos_character, [$Characters/Arcueid, "middle"])
	add_dialogue("yipeee")
	
	load_dialogue_start()
```

![alt text](image-13.png)
![alt text](image-14.png)
![alt text](image-15.png)
![alt text](image-16.png)
![alt text](image-17.png)
![alt text](image-18.png)
![alt text](image-19.png)
![alt text](image-34.png)
![alt text](image-35.png)
![alt text](image-36.png)
![alt text](image-37.png)
![alt text](image-38.png)
![alt text](image-39.png)

The set_character_emotion sets the character's emotion. Most of the functions has a _instant variation, which means they get executed without the hud fading in and out! (and the _instant functions gets executed once the fade out animation finishes or fast_skip button is held.)

![alt text](image-12.png)

It's optional if you want to type the emotions argument in uppercase or lowercase since it automatically sets the argument to uppercase!

add_dialogue_quote automatically creates a dialogue between "".

add_dialogue_continue creates a dialogue in the same line.

setpos_character sets the character pos to a specific side. It uses the exported variables of position from the character!

hide_character makes the character invisible and show_character makes the character visible. the _instant variations doesnt trigger the hud fade animation.

### Background handler example

>[!NOTE]
>This uses the Background Handler created via the Adding backgrounds for the framework example!
>You can follow that section on how to add backgrounds for the framework.
>This also uses the Arcueid example from Adding characters to the framework!

In this example, it will be used the Background Handler node to handle backgrounds, which includes background transitions, etc!

Keep in mind, the current scene for this test looks like this.
![alt text](image-40.png)

```gdscript
extends DemoScripter_VisualNovelScene

@onready var background: DemoScripter_BackgroundHandler = $Background

func _ready() -> void:
	add_dialogue_start("background example!")
	add_dialogue("normal background")
	add_dialogue("change to sprite 1")
	add_dialogue_special(background.change_background_transition, [1, "default", 2])
	add_dialogue("change to sprite 3")
	add_dialogue_special(background.change_background_transition, [3, "default", 2])
	add_dialogue("change to sprite 7")
	add_dialogue_special(background.change_background_transition, [7, "default", 2])
	add_dialogue("short change to sprite 10")
	add_dialogue_special(background.change_background_transition, [10, "default", 1])
	add_dialogue("long change to sprite 11")
	add_dialogue_special(background.change_background_transition, [11, "default", 3])
	
	add_dialogue_next("back to sprite 0")
	add_dialogue_special(background.change_background_transition, [0, "default", 1])
	add_dialogue("uhuh")
	
	add_dialogue_next("now with character visible")
	add_dialogue_special(show_character, [$Characters/Arcueid])
	add_dialogue("change to sprite 3")
	add_dialogue_special(background.change_background_transition, [3, "default", 2])
	add_dialogue("the background gets in front of the character, making the character hidden!")
	add_dialogue("appear arcueid again")
	add_dialogue_special(show_character, [$Characters/Arcueid])
	add_dialogue("change to sprite 5 persistant")
	add_dialogue_special(background.change_background_transition, [5, "default", 2, {
		"persistant_chars": true
	}])
	add_dialogue("now the character is on front!")
	add_dialogue("very cool...")
	
	add_dialogue_next("back to sprite 0, once again")
	add_dialogue_special(background.change_background_transition, [0, "default", 2])
	add_dialogue("background fade in")
	add_dialogue_special(background.background_fade_in, [2])
	add_dialogue("background fade out")
	add_dialogue_special(background.background_fade_out, [2])
	add_dialogue("arcueid appear again")
	add_dialogue_special(show_character, [$Characters/Arcueid]) 
	add_dialogue("fade in again")
	add_dialogue_special(background.background_fade_in, [2])
	add_dialogue("fade out again")
	add_dialogue_special(background.background_fade_out, [2])
	add_dialogue("as you can see, arcueid disappeared during the fade in animation!")
	add_dialogue("arcueid appear again -again-")
	add_dialogue_special(show_character, [$Characters/Arcueid]) 
	add_dialogue("fade in again -again-")
	add_dialogue_special(background.background_fade_in, [2, {
		"hide_characters": false
	}])
	add_dialogue("while arcueid got affected by the fadein effect, arcueid didnt completely disappear!")
	
	add_dialogue_next("back to normal again")
	add_dialogue_special(background.background_fade_out, [2])
	add_dialogue("test blink")
	add_dialogue_special(background.rect_blink, [1, 1])
	add_dialogue("quick blink")
	add_dialogue_special(background.rect_blink, [0.3, 0.3])
	add_dialogue("by default, characters dont disappear during the effect of rect blink")
	add_dialogue("hide characters test")
	add_dialogue_special(background.rect_blink, [0.3, 0.3, {
		"hide_characters_in": true
	}])
	add_dialogue("dont hide background test")
	add_dialogue_special(background.rect_blink, [0.3, 0.3, {
		"hold_fadein": 3,
		"hide_background_in": false
	}])
	add_dialogue("only works when you set the hold_fadein argument higher than 0")
	add_dialogue("test colored rect_blink")
	add_dialogue_special(background.rect_blink, [0.5, 0.5, {
		"rect_color": Color8(255, 0, 0)
	}])
	
	load_dialogue_start()

```

![alt text](image-41.png)
![alt text](image-42.png)
![alt text](image-43.png)
![alt text](image-44.png)
![alt text](image-45.png)
![alt text](image-46.png)
![alt text](image-47.png)
![alt text](image-48.png)
![alt text](image-49.png)
![alt text](image-50.png)
![alt text](image-51.png)
![alt text](image-52.png)
![alt text](image-54.png)
![alt text](image-55.png)

change_background_transition changes the background with a transition effect that fades in the new background on top of the old background. By default, characters get affected by the transition effect. You can enable persistant characters adding { "persistant_chars": true } to the config argument.

background_fade_in fades the background in, which makes it invisible and only making the color behing the Background's Sprites node visible. (ColorRect) Just like change_background_transition, characters get affected by the background fade. You can disable this by using { "hide_characters_in": false } in the config argument.

![alt text](image-53.png)

background_fade_out fades the background out.

rect_blink fades the background in and then out. You can set the rect_color temporarily using "rect_color" in the config argument. (it sets back to the original color value background had.) Characters don't disappear during the effect of rect blink by default.

#### Background colors example

>[!NOTE]
>This uses the Background Handler created via the Adding backgrounds for the framework example!
>You can follow that section on how to add backgrounds for the framework.
>This also uses the Arcueid example from Adding characters to the framework!

In this example, it will be shown functions that change the background's colors, including characters color during the transition.

There is a node in this example named Overlay with a child of ColorRect named Color. This ColorRect has a material of CanvasItemShader with blend mode set to multiply. This gets used on add_dialogue_special(background.set_rect_modulate_transition, [Color8(255, 0, 0), 3, $Overlay/Color]) function.

![alt text](image-57.png)
![alt text](image-58.png)

```gdscript
extends DemoScripter_VisualNovelScene

@onready var background: DemoScripter_BackgroundHandler = $Background

func _ready() -> void:
	add_dialogue_start("background second example!")
	add_dialogue("arghh")
	
	add_dialogue_next("test background color")
	add_dialogue_special(background.set_background_modulate, [Color8(255, 0, 0)])
	add_dialogue("this causes the background's color to change without transition")
	add_dialogue("back to normal")
	add_dialogue_special(background.set_background_modulate, [Color8(255, 255, 255)])
	
	add_dialogue_next("background modulate transition")
	add_dialogue_special(background.set_background_modulate_transition, [Color8(255, 0, 0), 3])
	add_dialogue("this only sets the modulate to the background!")
	add_dialogue("back to normal again")
	add_dialogue_special(background.set_background_modulate_transition, [Color8(255, 255, 255), 1])
	
	add_dialogue_next("background modulate all transition")
	add_dialogue_special(background.set_background_modulate_transition_all, [Color8(255, 0, 0), 3])
	add_dialogue("this sets the background and the characters modulate to a specific value")
	add_dialogue("back to normal again again")
	add_dialogue_special(background.set_background_modulate_transition_all, [Color8(255, 255, 255), 1])
	
	add_dialogue_next("testing ColorRect with CanvasItemMaterial with blend mode on multiply transition")
	add_dialogue_special(background.set_rect_modulate_transition, [Color8(255, 0, 0), 3, $Overlay/Color])
	add_dialogue("back to normal again again again")
	add_dialogue_special(background.set_rect_modulate_transition, [Color8(255, 255, 255), 1, $Overlay/Color])
	add_dialogue("with this treasure, i summon..............")

	
	load_dialogue_start()
```

![alt text](image-56.png)
![alt text](image-59.png)
![alt text](image-60.png)
![alt text](image-61.png)
![alt text](image-62.png)
![alt text](image-63.png)
![alt text](image-65.png)

set_background_modulate sets the background's modulate (color) after the fade out animation of HUD finishes.

set_background_modulate_transition sets the background's modulate (color) using a transition. This doesn't affect characters.

set_background_modulate_transition_all sets the background's modulate (color) using a transition. This affect characters.

set_rect_modulate_transition sets a ColorRect to a specific modulate (color) with a transition. This was used to set the ColorRect from Overlay node, which affected the background and characters (alternative to set_background_modulate_transition_all and allows characters to have their own modulate instead of being forced to be on the specific modulate from set_background_modulate_transition_all.)

#### Transition shader example

>[!NOTE]
>This example uses [Pixelated diamond directional fading transition](https://godotshaders.com/shader/pixelated-diamond-directional-fading-transition/) by [Joey Bland](https://godotshaders.com/author/joey_bland/) on [Godot Shaders](https://godotshaders.com/). The example folder includes a shader folder which contains this shader.

>[!NOTE]
>This uses the Background Handler created via the Adding backgrounds for the framework example!
>You can follow that section on how to add backgrounds for the framework.
>This also uses the Arcueid example from Adding characters to the framework!

This example showcases a custom shader for transitions!

```gdscript
extends DemoScripter_VisualNovelScene

@onready var background: DemoScripter_BackgroundHandler = $Background

func _ready() -> void:
	add_dialogue_start("background third example!")
	add_dialogue("this is for showcasing transition with shaders")
	add_dialogue_next("test transition")
	add_dialogue_special(background.change_background_effect, [2, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3])
	add_dialogue("this is a horizontal shader transition!")
	add_dialogue_next("change background to 3")
	add_dialogue_special(background.change_background_effect, [3, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3])
	add_dialogue("pretty cool")
	
	add_dialogue_next("background effect fade in")
	add_dialogue_special(background.background_effect_in, ["res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, 3])
	add_dialogue("uhuh")
	add_dialogue("background effect fade out")   
	add_dialogue_special(background.background_effect_out, ["res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", -1, 3])
	add_dialogue("ok")
	add_dialogue("effect fade in fast")
	add_dialogue_special(background.background_effect_in, ["res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, 1])
	add_dialogue("fade out normal")
	add_dialogue_special(background.background_fade_out, [3])
	add_dialogue("cool")
	
	add_dialogue_next("fade in normal")
	add_dialogue_special(background.background_fade_in, [1])
	add_dialogue("effect out change background")
	add_dialogue_special(background.background_effect_out_change, [10, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", -1, 3])
	add_dialogue("yeah that worked")
	add_dialogue("change background to frame 7 with right direction")
	add_dialogue_special(background.change_background_effect, [7, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "right",
	}])
	add_dialogue("change background to frame 10 with left direction")
	add_dialogue_special(background.change_background_effect, [10, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "right",
	}])
	add_dialogue("change background to frame 13 with down direction")
	add_dialogue_special(background.change_background_effect, [13, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "right",
	}])
	add_dialogue("that worked too, incredible!")
	
	add_dialogue_next("character test")
	add_dialogue_special(show_character, [$Characters/Arcueid])
	add_dialogue("transition test with character")
	add_dialogue_special(background.change_background_effect, [16, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "right",
	}])
	
	add_dialogue_next("different transitions directions 1")
	add_dialogue_special(background.change_background_effect, [20, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "left",
		"quick_direction_fadeout": "up",
	}])
	add_dialogue("different transitions directions 2")
	add_dialogue_special(background.change_background_effect, [4, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "down",
	}])
	add_dialogue("yeah, thats cool")
	
	add_dialogue_next("character test again")
	add_dialogue_special(show_character, [$Characters/Arcueid])
	add_dialogue_next("transition without character hide")
	add_dialogue_special(background.change_background_effect, [16, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "right",
		"quick_direction_fadeout": "right",
		"hide_characters_in": false
	}])
	add_dialogue("transition without character hide hold middle")
	add_dialogue_special(background.change_background_effect, [6, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "left",
		"quick_direction_fadeout": "left",
		"hide_characters_in": false,
		"hold_middle": 3
	}])
	add_dialogue("by holding the middle by default, the character appears in the hold middle")
	add_dialogue("to make the character appear again after the effect background, use show_character_out and specific the character inside a array argument")
	add_dialogue("transition with character hide, hold middle and show character out")
	add_dialogue_special(background.change_background_effect, [6, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
		"quick_direction_fadein": "left",
		"quick_direction_fadeout": "left",
		"hold_middle": 3,
		"show_character_out": [$Characters/Arcueid]
	}])
	add_dialogue("now the character appears at the fade out!")
	
	load_dialogue_start()

```

background_effect_in does a background fade in using a shader.

background_effect_out does a background fade out using a shader.

background_effect_out_change changes the background first and does a fade out effect using a shader.

change_background_effect changes the background using a shader. This contains a quick_direction config argument that you can set the direction of the shader. (up, right, left, down. the default is up) By default, in the fade out effect, it uses the value argument reversed. (1 becomes -1) You can change this behavior by using tween_type to auto and specifying the tween_from value.

```gdscript
add_dialogue_special(background.change_background_effect, [16, "default", "res://Demo-Scripter/docs/examples/shaders/transition_shadermaterial.tres", "height", 1, -1, 3, 3, {
	"tween_type": "manual",
	"tween_from: 0
}])
```

![alt text](image-66.png)
![alt text](image-67.png)
![alt text](image-68.png)
![alt text](image-69.png)
![alt text](image-73.png)
![alt text](image-71.png)
![alt text](image-72.png)
![alt text](image-74.png)
![alt text](image-75.png)
![alt text](image-76.png)
![alt text](image-77.png)
![alt text](image-78.png)
![alt text](image-79.png)

#### Overlay example

>[!NOTE]
>This example uses [Pixelated diamond directional fading transition](https://godotshaders.com/shader/pixelated-diamond-directional-fading-transition/) by [Joey Bland](https://godotshaders.com/author/joey_bland/) on [Godot Shaders](https://godotshaders.com/). The example folder includes a shader folder which contains this shader.

>[!NOTE]
>This uses the Background Handler created via the Adding backgrounds for the framework example!
>You can follow that section on how to add backgrounds for the framework.
>This also uses the Arcueid example from Adding characters to the framework!

This example showcases a custom shader for transitions!

### Playing music example

>[!NOTE]
>The following musics are from Tsukihime. Tsukihime is owned by TYPE-MOON. This is only for example purposes.
>I got the music files from accessing the CD folder from [ReadTsukihime's Tsukihime download page](https://www.readtsukihi.me/downloads).
>The musics is from Tsuki-Bako version of Tsukihime.

# Adding backgrounds for the framework

>[!NOTE]
>The following background images are from Tsukihime. Tsukihime is owned by TYPE-MOON. This is only for example purposes.
>I extracted the Tsukihime's character sprites using [ONScripter-EN's](https://github.com/Galladite27/ONScripter-EN) tools maintained by [Galladite27](https://galladite.net/~galladite/). (extracting the ONScripter source code, running ./configure on terminal and running make tools on terminal.)
>If you'd like support on how to use ONScripter-EN and it's tools, feel free to ask for help on [ONScripter-EN's discord server](https://github.com/Galladite27/ONScripter-EN)!
>You can also filter the discord server messages via the search bar and see my first messages, which shows me asking for help on how to extract sprites.

## Tsukihime backgrounds example

>[!NOTE]
>The example below uses a project resolution of 720x540.

First, instantiate background handler from demoscripter folder to your visual novel scene.
![alt text](image-20.png)


![alt text](image-26.png)

Rename the BackgroundHandler to Background.

![alt text](image-22.png)

Make the Background node (previuosly named BackgroundHandler) to local. This is for adding the background sprites and not altering the background handler from demoscripter folder.

![alt text](image-23.png)

Create a new SpriteFrame on Sprites and add the Tsukihime backgrounds from assets/backgrounds of this documentation folder.

![alt text](image-24.png)

As you can see, the sprite resolution inst in the correct size due to the project being in 720x540.

On Sprites node, set the Scale size to x: 1.125 and y: 1.125
![alt text](image-25.png)

After changing the scale, create a Node2D on your scene named Characters.

>[!NOTE]
>Even if you're not going to use characters, this is for preventing the assert function of empty characters node from returng true, causing an error.

On Background node, set the Main Scene variable to the root node (or the node that the background handler is inside, which is a DemoScripter_VisualNovelScene node)

![alt text](image-21.png)

Then set the Characters Node to the Node2D named Characters you just created.

![alt text](image-27.png)

The overlay node can be empty because it's optional and only meant to be used if Use Overlay Exclusive Node is enabled, which handles overlays on a seperate node.

And done! You should have a background handler ready to use!

# Creating characters using the framework

>[!NOTE]
>The following characters are from Tsukihime. Tsukihime is owned by TYPE-MOON. This is only for example purposes.

>[!NOTE]
>I extracted the Tsukihime's character sprites using [ONScripter-EN's](https://github.com/Galladite27/ONScripter-EN) tools maintained by [Galladite27](https://galladite.net/~galladite/). (extracting the ONScripter source code, running ./configure on terminal and running make tools on terminal.)
>After making the extractions, I used my [NScripter Sprite Extractor](https://github.com/Lukaswbrr/nscripter-sprite-extractor-script) script made for Krita to make the sprites transparent.
>If you'd like support on how to use ONScripter-EN and it's tools, feel free to ask for help on [ONScripter-EN's discord server](https://github.com/Galladite27/ONScripter-EN)!
>You can also filter the discord server messages via the search bar and see my first messages, which shows me asking for help on how to extract sprites.

To create characters to be used with the framework, you use the DemoScripter_VisualNovelCharacter class.

The character must have the following nodes:

- AnimatedSprites for the characters sprites
- AnimationPlayer for show and hide animations (can also be custom animations)
- AnimationPlayer named EmotionPlayer for the characters's emotions

There is a base character scene in scenes/character_base/CharacterBase.tscn.

![character base image](./images/character_base_image.png)

## Arcueid Example

>[!IMPORTANT]
>The example below uses a project resolution of 720x540.

This a step-by-step example on making a character using the CharacterBase scene file as reference. The following character is from Tsukihime (2000). The complete example can be accessed
in examples/characters folder.

### Create characters folder

In your godot project, create a folder that will be used to store your characters.
It can be any folder name. In this example, it's just called characters.

![arcueid step 1](./images/arcueid_step_1.png)

### Create arcueid folder

Create the folder to store arcueid's sprites, files, etc.

![alt text](./images/arcueid_step_2.png)

### Duplicate character base to arcueid folder

On character_base folder from DemoScripter, duplicate CharacterBase.tscn file and name it arcueid.tscn

![alt text](./images/arcueid_step_3.png)

Move the arcueid.tscn to arcueid folder located in characters

![alt text](./images/arcueid_step_3_2.png)

For safety purposes, in case AnimationPlayer gets somehow modified in the base despite only modifying on Arcueid's scene file, go to EmotionPlayer, click on Manage Animations and on \[global], click on Save Icon and click on Turn Unique.

![alt text](./images/arcueid_step_3_3.png)

Do the same to the AnimationPlayer node.

![alt text](./images/arcueid_step_3_4.png)

### Rename Arcueid scene's CharacterBase nose to Arcueid

Change the main node's name to Arcueid.

![alt text](./images/arcueid_step_4.png)

### Create assets folder in arcueid folder

In arcueid's folder, create a folder named assets.

This is where the sprites images will be located.

![Create assets folder](./images/arcueid_step_5.png)

### Add sprites to assets folder

In the docs/assets/characters/arcueid folder, copy all of the sprites to the arcueid's assets folder.

![Copy sprites into assets](./images/arcueid_step_6.png)

![Arcueid sprites list part 2](./images/arcueid_step_6_1.png)

### Create SpriteFrames on AnimatedSprites node

On AnimatedSprites node, create a new SpriteFrames.

![Create SpriteFrames resource](./images/arcueid_step_7.png)

### Rename default group to normal

>[!NOTE]
>This is not really necessary and if you want, you can use the default group name. The reason why I ask to rename this to normal is because the EmotionPlayer emotions example (NORMAL, SAD, RESET) sets the AnimatedSprites's group propriety to normal. You can change this in the EmotionPlayer's to default group before using a group name named default on AnimatedSprites node.

![Rename default group to normal](./images/arcueid_step_8.png)

### Add Arcueid's sprites from the assets folder of the character to normal group of SpriteFrames

![Add sprites to normal group](./images/arcueid_step_9.png)

![Added sprites preview](./images/arcueid_step_9_1.png)

![All sprites loaded](./images/arcueid_step_9_2.png)

### Move AnimatedSprites's position

When added the arcueid's sprites, the position of the AnimatedSprites looks off and not fully to the ground.

![Adjust AnimatedSprites position](./images/arcueid_step_10.png)

To fix this, on the x position, type 720/2 which will divide 720 by 2, resulting in 360. (720 is the project's width value.)

Using the move tool, hold shift and try to move it down where it overlaps with the project's resolution boundaries.

![Move tool alignment](./images/arcueid_step_11.png)

The final value will be:

- x: 360
- y: 300

![Final position values](./images/arcueid_step_11_2.png)

### Resize AnimatedSprites

Right now, Arcueid's sprite seems too small.

Click on the AnimatedPlayer nodes with the select mode, hold shift and resize Arcueid's top left point until it overlaps with the project's resolution.

![Resize sprite top-left handle](./images/arcueid_step_12.png)

![Resize confirmation](./images/arcueid_step_12_2.png)

When you resize the sprite, it will look offset again from the center.
![Offset after resize](./images/arcueid_step_12_3.png)

In the position propriety of AnimatedSprites node, change the position to the following:

- x: 360
- y: 270

It will be on center again.

![Recenter to 360x270](./images/arcueid_step_12_4.png)

### Fix incorrect SAD emotion

By default, the SAD emotion sets the frame of the AnimatedSprites to 1.

In arcueid's case, this is the wrong sprite for the emotion.

![alt text](./images/arcueid_step_13.png)

The fix will change the frame to 7, which will change to sprite 7 from AnimatedSprites.

![alt text](./images/arcueid_step_13_2.png)

>[!NOTE]
>In case your 7 frame is different from this screenshot, change the value to where the sprite image from 7 in the screenshot is.

In the EmotionPlayer, select the SAD animation and click on the image from frame property.

![alt text](./images/arcueid_step_13_3.png)

In the right side (or where your inspector's properties screen is located on), change the value to 7.

![alt text](./images/arcueid_step_13_4.png)

Now the SAD emotion should have the right sprite.

![alt text](./images/arcueid_step_13_5.png)

>[!NOTE]
>You may need to change the emotion from the EmotionPlayer to NORMAL then to SAD to see the difference

### Create new emotions

To create new emotions, I recommend duplicating a already existing emotion, in this case, NORMAL.

The animations from EmotionPlayer runs for 0.01 seconds, which is only meant for a easy way to create emotions for characters. Duplicating a existant emotion already sets the animation time to 0.01.

>[!NOTE] In case your new character emotion is not being updated, despite changing the frame property value, verify if you accidentally moved the frame property. This could change the emotion not to change.
>![alt text](./images/arcueid_step_14.png)

We will create the new emotions named:

- NORMAL_2
- NORMAL_3
- ANGRY
- ANGRY_2
- DOUBT
- DOUBT_2
- SAD_2
- SURPRISED
- SURPRISED_2

First, select NORMAL emotion, then click on duplicate.

![alt text](./images/arcueid_step_14_2.png)

By default, the name should be NORMAL_2:
![alt text](./images/arcueid_step_14_3.png)

Change the NORMAL_2's frame property value to 1.

![alt text](./images/arcueid_step_14_4.png)

Repeat the same process with the following values of each emotion name:

- NORMAL_3: 2
- ANGRY: 3
- ANGRY_2: 4
- DOUBT: 5
- DOUBT_2: 6
- SAD_2: 8
- SURPRISED: 9
- SURPRISED_2: 10

Your EmotionPlayer's animation list should be like this.

![alt text](./images/arcueid_step_14_5.png)

### Set position left and right values

When you select the Arcueid node, you can notice that DemoScripter_VisualNovelCharacter has three export variables:

![alt text](image-1.png)

- Pos Middle
- Pos Left
- Pos Right

This is for setting the character's position when setpos_character function is executed on DemoScripter_VisualNovelScene.

Keep in mind, this is for setting the character's node named Arcueid and not the Sprites!

Since arcueid's position is already on the middle (0, 0), Pos middle will remain the same. (0, 0)

![alt text](image-28.png)

![alt text](image-4.png)

After that, select the Arcueid node and while holding shift, move it to the left.

![alt text](image-29.png)

Copy the value from position and paste it to Pos Left.

![alt text](image-31.png)

In this case, the position X is -189.

Then, copy the value from Pos Left to Pos Right and remove the minus sign of the x value. (-189, which will turn into 189)

![alt text](image-32.png)

Copy the Pos Middle value to Arcueid's position property to center Arcueid by default again.
![alt text](image-33.png)

### Create arcueid script

Right click on Arcueid's node and click on Extend script.

![alt text](image-7.png)

Save it on arcueid's character folder.

![alt text](image-8.png)

### Auto add emotions function

On arcueid.gd, in the _ready function, add auto_add_emotions() function. This is for loading the emotions for the character.

![alt text](image-9.png)

```gdscript
extends DemoScripter_VisualNovelCharacter


func _ready() -> void:
	auto_add_emotions()
```

And now, the arcued character example should be finished and ready to be added to a scene!

# Playing audio using the framework

W.I.P
