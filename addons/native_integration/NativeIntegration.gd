tool
extends EditorPlugin
class_name NativeIntegration

var dir:Directory = Directory.new()
var slash = "/"
var main_window:Control = null
var bt_main:Button = Button.new()
const main_path = "res://addons/native_integration/NativeMain.tscn"
func _enter_tree():
	bt_main.text = "Native"
	bt_main.connect("pressed",self,"_on_bt_main_pressed")
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,bt_main)
	main_window = load(main_path).instance()
	
	add_child(main_window)
	
	if (OS.get_name() == "Windows"): slash = "\\"
	
	dir.open(ProjectSettings.globalize_path("user://"))
	dir.change_dir("../../")
	if dir.dir_exists(dir.get_current_dir()+slash+"native"):
		print("it has")
		
	else:
		print("not exitst")
		var output:Array
		OS.execute("git",["clone","https://github.com/nonunknown/godot-cpp-base.git", dir.get_current_dir()+slash+"native", "--recursive"],true,output,true)
		print(output)
		
#	dir.change_dir(dir.get_current_dir()+slash+"native"+slash+"godot-cpp")
#	print("new dir %s" % dir.get_current_dir())
	main_window.set_native_path(dir.get_current_dir())

func _exit_tree():
	remove_child(main_window)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR,bt_main)
	pass

func _on_bt_main_pressed():
	main_window.about_to_open()
	main_window.get_node("Dialog").show()
	pass
