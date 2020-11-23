tool
extends WindowDialog

onready var native_main = get_parent()
onready var te_name:LineEdit = $VBoxContainer/HBoxContainer/TextEdit
onready var msg:Label = $VBoxContainer/msg
var file:File = File.new()

func _create_src_files():
	var file_name:String = te_name.text
	var path:String = native_main.get_project_src_path()+"/%s.%s"
	file.open("res://addons/native_integration/base_files/cpp.txt",File.READ)
	var cpp = file.get_as_text()
	file.close()
	
	
	file.open("res://addons/native_integration/base_files/hpp.txt",File.READ)
	var hpp = file.get_as_text()
	file.close()
	
	file.open( path % [file_name, "cpp"],File.WRITE)
	file.store_string(cpp.replace("%CLASS_NAME%",file_name))
	file.close()
	file.open(path % [file_name, "hpp"],File.WRITE)
	hpp = hpp.replace("%DEF%",file_name.to_upper())
	file.store_string(hpp.replace("%CLASS_NAME%",file_name))
	file.close()
	hide()
	native_main.update_class_list()
	pass

func _on_bt_done_pressed():
	var project_folder = native_main
	_create_src_files()
	pass # Replace with function body.
