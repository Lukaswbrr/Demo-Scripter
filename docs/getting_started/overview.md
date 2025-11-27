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

```
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
### Characters example

### Background handler example
>[!NOTE]
>The following background images are from Tsukihime. Tsukihime is owned by TYPE-MOON. This is only for example purposes.
>I extracted the Tsukihime's character sprites using [ONScripter-EN's](https://github.com/Galladite27/ONScripter-EN) tools maintained by [Galladite27](https://galladite.net/~galladite/). (extracting the ONScripter source code, running ./configure on terminal and running make tools on terminal.)
>If you'd like support on how to use ONScripter-EN and it's tools, feel free to ask for help on [ONScripter-EN's discord server](https://github.com/Galladite27/ONScripter-EN)!
>You can also filter the discord server messages via the search bar and see my first messages, which shows me asking for help on how to extract sprites.


#### Transition shader example

### Playing music example
>[!NOTE]
>The following musics are from Tsukihime. Tsukihime is owned by TYPE-MOON. This is only for example purposes.
>I got the music files from accessing the CD folder from [ReadTsukihime's Tsukihime download page](https://www.readtsukihi.me/downloads).
>The musics is from Tsuki-Bako version of Tsukihime.

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

There is a base character scene in scenes/cgaracter_base/CharacterBase.tscn.

![character base image](./images/character_base_image.png)

## Arcueid Example
This a step-by-step example on making a character using the CharacterBase scene file as reference. The following character is from Tsukihime (2000). The complete example can be accessed
in examples/characters folder.

### Create characters folder
In your godot project, create a folder that will be used to store your characters.
It can be any folder name. In this example, it's just called characters.

![arcueid step 1](./images/arcueid_step_1.png.png)

### Create arcueid folder
Create the folder to store arcueid's sprites, files, etc.

![alt text](./images/arcueid_step_2.png.png)

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

# Playing audio using the framework
W.I.P
