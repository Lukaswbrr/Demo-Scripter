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
	
	load_dialogue_start()
```

![alt text](image-13.png)
![alt text](image-14.png)
![alt text](image-15.png)
![alt text](image-16.png)
![alt text](image-17.png)
![alt text](image-18.png)
![alt text](image-19.png)


The set_character_emotion sets the character's emotion. Most of the functions has a _instant variation, which means they get executed without the hud fading in and out! (and the _instant functions gets executed once the fade out animation finishes or fast_skip button is held.)

![alt text](image-12.png)

It's optional if you want to type the emotions argument in uppercase or lowercase since it automatically sets the argument to uppercase!

add_dialogue_quote automatically creates a dialogue between "".

add_dialogue_continue creates a dialogue in the same line.

### Background handler example
>[!NOTE]
>This uses the Background Handler created via the Adding backgrounds for the framework example!
>You can follow that section on how to add backgrounds for the framework.

In this example, it will be used the Background Handler node to handle backgrounds, which includes background transitions, etc!


#### Transition shader example

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

There is a base character scene in scenes/cgaracter_base/CharacterBase.tscn.

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
