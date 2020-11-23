# WIP - Godot Native Integration ( Experimental Release)


### Description

Provides a interface for easy GDNative management/building all-in-one inside the engine.
This is a implementation of @WillNationsDev's proposal #119 for godot engine - https://github.com/godotengine/godot-proposals/issues/119

All feedback is important on this stage of development so dont forget to create an issue, and tell your experience/idea/bug report

### Why this plugin exists?

Well the current workflow for doing Native stuff is very complex, so this plugin facilitate the workflow.

### Plans for the future

* Add support for all languages that godot-engine support
* Multiple Projects managing
* Cross-compiling support (if possible remote compiling with travis-ci)

## Requeriments

* Git (To download git repos)
The other requirements are the same for compiling the godot's source code
* For Linux:
https://docs.godotengine.org/en/stable/development/compiling/compiling_for_x11.html
* For Windows: 
https://docs.godotengine.org/en/stable/development/compiling/compiling_for_windows.html

## Instructions

* 1 - When You install like any plugin, and enable it (image below) it will take a little longer because it will install the necessary files at the godot data folder.

![test](https://i.imgur.com/kY2hap3.png)

* 2 - These new generated files Can be accessed via: 

![](https://i.imgur.com/qEwGjFO.png)

* 3 - You'll be able to see a folder called native

![](https://i.imgur.com/5wLcxGA.png)

* 4 - Inside the engine a button called native will appear on top-right corner:

![](https://i.imgur.com/kAtr079.png)

* 5 - This is the main window:

![](https://i.imgur.com/Bd5pxbK.png)

* 6 - About:
  - PROJECT NAME: For now only one project is supported, but in further updates you will be able to manage as many projects as you want
  - GENERATE BINDINGS: Generate necessary stuff for compiling your native code (if everything goes well a green icon will be shown)
  - COMPILE SOURCES: Compile your created classes, so you first must create your classes modify them (going into `native/src/my_project` see step 2)
  - PLATFORM: Select which OS you want to build for, (currently only works with the one you are working on e.g: if you are on windows just leave, or if you are on linux leave there)
  - TARGET: You can use release (for final stuff) or debug ( for testing purposes, larger file)
  - PROCESSOR CORES: How many cores your processor has (faster compiling)
  - INSERT NEW CLASS: Create your classes there

* 7 - Final:
Now just modify your classes (step 2 - for accesing them) and click COMPILE SOURCES, and if no error appears on output you're done!

### Credits

A huge thanks to this guy: ->

![](https://i.imgur.com/DCEHh03.png)

Without him this project wouldn't be possible he helped with SCons file for building, also a lot of help with my errors during development
