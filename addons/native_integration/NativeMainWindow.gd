tool
extends Control
class_name NativeMain

export(Array,Texture) var icons
export var np_le_proj:NodePath
export var np_bt_createproj:NodePath
export var np_bt_genbin:NodePath
export var np_bt_compile:NodePath
export var np_ob_platform:NodePath
export var np_ob_target:NodePath
export var np_sb_proc:NodePath
export var np_bt_createclass:NodePath

onready var le_proj:LineEdit = get_node(np_le_proj)
onready var bt_createproj:Button = get_node(np_bt_createproj)
onready var bt_genbin:Button = get_node(np_bt_genbin)
onready var bt_compile:Button = get_node(np_bt_compile)
onready var ob_platform:OptionButton = get_node(np_ob_platform)
onready var ob_target:OptionButton = get_node(np_ob_target)
onready var sb_proc:SpinBox = get_node(np_sb_proc)
onready var bt_createclass:Button = get_node(np_bt_createclass)
#export var np_:NodePath

onready var file:File = File.new()

var native_path:String

func get_project_bin_path() -> String: return "%s/native/bin/%s" % [native_path, proj.proj_name]
func get_project_src_path() -> String: return "%s/native/src/%s" % [native_path, proj.proj_name]

func set_native_path(path:String):
	native_path = path
	print("base path is: "+native_path)
	
func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
	pass # Replace with function body.

func _disable_buttons(disable:bool=true):
	var buttons = [bt_compile,bt_genbin]
	
	for bt in buttons:
		if bt is Button:
			bt.disabled = disable
	

func _on_bt_genbind_pressed():
	_disable_buttons(true)
	var dir:Directory = Directory.new()
	dir.change_dir("%s/native/godot-cpp/" % native_path)
	var output:Array
#	var platform = "windows"
#	print(OS.get_name())
#	if OS.get_name() == "X11": platform = "linux"
	print("the dir bindinging: "+dir.get_current_dir())
	var platform = ob_platform.get_item_text(ob_platform.get_selected_id())
	var target = ob_target.get_item_text(ob_target.get_selected_id())
	var nproc = sb_proc.value
	var files = dir_contents(native_path+"/native/godot-cpp/bin",false)
	var generate_bindings:bool = true
	
	if files != []:
		bt_genbin.set_button_icon(icons[1])
		for f in files:
			var file:String = f
			if platform in file:
				if target in file:
					generate_bindings = false
					print("Bindings for selected options already exists")
	
	if generate_bindings:
		var path = "%s/native/godot-cpp/" % native_path
		var windows_stuff:String = ""
		if platform == "windows": windows_stuff = "use_mingw=yes"
		var result = OS.execute("scons",["-C",path,"-j%d" % nproc, "platform=%s" % platform,"generate_bindings=yes","target=%s" % target, windows_stuff,"bits=64"],true,output,true)
		if result != 0:
			bt_genbin.set_button_icon(icons[2])
		print(str(result))
	print(output)
	_disable_buttons(false)
	pass # Replace with function body.


#Project Stuff
const save_name:String = "NativeIntegrationSAVE.tres"
var proj:NativeProject = null

func about_to_open():
	#Check for save file
	var file = File.new()
	if file.file_exists("res://%s" % save_name):
		print("Save File Found")
		load_project()
	else:
		print("Project Not found, please create a new project and click create button before procedding")
	update_class_list()
func load_project():
	proj = ResourceLoader.load("res://%s" % save_name) as NativeProject
	le_proj.text = proj.proj_name
	le_proj.set_editable(false)
	bt_createproj.disabled = true
	
	bt_genbin.disabled = false
	
	pass

func save_project():
	if proj == null:
		proj = NativeProject.new()
	proj.proj_name = le_proj.text
	ResourceSaver.save("res://%s" % save_name,proj)
	load_project()
	pass
	
func create_project():
	var project_name:String = le_proj.text
	project_name = project_name.to_lower()
	project_name = project_name.replace(" ","_")
	
	#Check folders src/n and bin/n for a folder with project name
	var already_exists:bool = false
	for dir in dir_contents("%s/src/%s" % [native_path, project_name]):
		if project_name in dir:
			
			already_exists = true
			break
	if !already_exists:
		for dir in dir_contents("%s/src/%s" % [native_path, project_name]):
			if project_name in dir:
				already_exists = true
				break
	
	if already_exists:
		printerr("Error project: %s already exists, use another name" % project_name)
		return
	
	bt_createproj.disabled = true
	le_proj.set_editable(false)
	
	var dir:Directory = Directory.new()
	var folders = ["bin","src"]
	dir.open(native_path+"/native")
	for folder in folders:
		var path = dir.get_current_dir()+"/%s/%s" % [folder, project_name]
		print("Creating dir at: " + dir.get_current_dir())
		dir.make_dir(path)
	
	print("Directories created")
	save_project()
	
	pass

func create_class():
	$WindowDialog.show()

func dir_contents(path,folder_only:bool = true) -> Array:
	var dir = Directory.new()
	var contents:Array = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and folder_only:
				contents.append(file_name)
			elif !folder_only:
				contents.append(file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
	return contents

func _on_bt_compile_pressed():
	file.open("res://addons/native_integration/base_files/gdlibrary.txt",File.READ)
	var gdlib = file.get_as_text()
	file.close()
	var headers:String = ""
	var classes:String = ""
	for c in get_classes():
		headers += '#include "%s.hpp"\n' % c
		classes += "register_class<%s>();\n\t" % c
	
	gdlib = gdlib % [headers,classes]
	file.open(get_project_src_path()+"/gdlibrary.cpp",File.WRITE)
	file.store_string(gdlib)
	file.close()
	
	_disable_buttons(true)
	var dir:Directory = Directory.new()
	dir.change_dir(get_project_src_path())
	var output:Array
	print("the dir bindinging: "+dir.get_current_dir())
	var platform = ob_platform.get_item_text(ob_platform.get_selected_id())
	var target = ob_target.get_item_text(ob_target.get_selected_id())
	var nproc = sb_proc.value
	var files = dir_contents(native_path+"/native/godot-cpp/bin",false)
	
	if files != []:
		bt_genbin.set_button_icon(icons[1])
		for f in files:
			var file:String = f
			if platform in file:
				if !target in file:
					printerr("You must generate bindings for these options first")
					return
	
	
	var windows_stuff:String = ""
	if platform == "windows": windows_stuff = "use_mingw=yes"
	print("compiling on path %s" % native_path)
	print("src folder %s" % get_project_bin_path())
	var path = native_path+"/native"
	print("path: %s" % path)
	
#	var cmd:PoolStringArray = ["-C",'"%s"' % path,'target=release','platform=windows','src_path="%s/src/my_project"' % path, '-j4' ,windows_stuff, 'bits=64']
#	var result =OS.execute("scons",cmd,true,output,true)
	var result = -1
	if OS.get_name() == "Windows":
		file.open("res://addons/native_integration/base_files/build.bat",File.READ_WRITE)
		path = path.replace("/","\\")
		var target_path = path+"\\bin\\%s" % proj.proj_name
		var src_path = path+"\\src\\%s" % proj.proj_name
		var cmd = file.get_as_text() % [path,target_path,src_path,target,str(nproc) ]
		file.close()
		file.open("res://temp_build.bat",File.WRITE)
		file.store_string(cmd)
		file.close()
		
		result = OS.shell_open( ProjectSettings.globalize_path("res://temp_build.bat"))
	elif OS.get_name() == "X11":
		file.open("res://addons/native_integration/base_files/build.sh",File.READ)
		var target_path = path+"/bin/%s" % proj.proj_name
		var src_path = path+"/src/%s" % proj.proj_name
		var cmd = file.get_as_text() % [path, target_path,src_path,target,str(nproc)]
		file.close()
		file.open("res://temp_build.sh",File.WRITE)
		file.store_string(cmd)
		file.close()
		result = OS.shell_open( ProjectSettings.globalize_path("res://temp_build.sh"))
	if result != 0:
		bt_compile.set_button_icon(icons[2])
	else:
		var error = -1
		var lib:GDNativeLibrary = GDNativeLibrary.new()
		
		if OS.get_name() == "Windows":
			error = dir.copy(get_project_bin_path()+"/windows/libcdt-gd.dll","res://libcdt-gd.dll")
			lib.set("entry/Windows.64", "res://libcdt-gd.dll")
		else:
			error = dir.copy(get_project_bin_path()+"/x11/libcdt-gd.so","res://libcdt-gd.so")
			lib.set("entry/X11.64", "res://libcdt-gd.so")
		if error != OK:
			print("Error at copying dll to that folder: %d" % error)
			return
#		lib.config_file.set_value("resource","entry/Windows.64","res://libcdt-gd.dll")
#		lib.config_file.set_value("resource","dependency/Windows.64","[  ]")
	
		error = ResourceSaver.save("res://gdlib.gdnlib",lib)
		if error != OK:
			printerr("Error at saving GDLib: %d" % error)
			return
		
		for c in get_classes():
			var gdns:NativeScript = NativeScript.new()
			
			gdns.set("class_name",c)
			gdns.library = lib
			gdns.script_class_name = c
			error = ResourceSaver.save("res://%s.gdns" % c,gdns)
			if error !=OK:
				printerr("Error at saving GDNS: %s, error num: %d" % [c, error])
				return
		print("DONE")
		pass
		
	print(str(result))
	print(output)
	_disable_buttons(false)
	
	pass # Replace with function body.


func _on_bt_createproj_pressed():
	create_project()
	pass # Replace with function body.


func _on_bt_create_class_pressed():
	create_class()
	pass # Replace with function body.

func get_classes() -> Array:
	var dir = Directory.new()
	var path = native_path+"/native/src/%s" % proj.proj_name
	print(path)
	var contents = dir_contents(path,false)
	print(contents)
	var list = []
	for file in contents:
		if file == "gdlibrary.cpp": continue
		if file.ends_with(".cpp"):
			list.append(file.split(".")[0])
	return list

func update_class_list():
	
	var class_list:ItemList = $Dialog/vbc/p/vbcc/ClassList
	class_list.clear()
	for item in get_classes():
		class_list.add_item(item)
