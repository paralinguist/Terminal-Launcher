extends Node2D

const CONFIG_FILE_LOCATION = "res://PythonFiles/FilesToBeRun/config_file.txt"
const STARTUP_POP = "res://Scenes/Main/FileDialog.tscn"

var python_interpreter_path = ""
var folder_directory = ""

func _ready():
	
	var file_for_check = File.new()
	var check_if_exists = file_for_check.file_exists(CONFIG_FILE_LOCATION)
	print(check_if_exists)
	
	if check_if_exists == true:
		var result = false
		var file = File.new()
		file.open(CONFIG_FILE_LOCATION, File.READ)

		while not file.eof_reached():
			var line = file.get_line()
			print(line)
			var split = line.split(": ")
			if split[0] == "Already_Config":
				if "0" in split[1]:
					print("not configed")
					result = true

		file.close()

		if result == true:
			_BringUpFileSelector("folder")
		else:
			$MainMenu/StartPopup.visible = false
		
	else: 
		_CreateConfigFile()
		_ready()
		
func _BringUpFileSelector(type):
	#for loop, 3 times, change text on time
	#ask sir where game selection will be handled
	#this is being disgusting rn so imma do folder method then figure out later
	$MainMenu/StartPopup/FileSystem/FileDialog.visible = true

	
	var new_file_dialog = load(STARTUP_POP)
	var file_instance = new_file_dialog.instance()
	$MainMenu/StartPopup/FileSystem.add_child(file_instance)
	file_instance.popup()
	
	$MainMenu/StartPopup.visible = true
	file_instance.connect("file_selected", self, "_on_FileDialog_file_selected")
	file_instance.connect("dir_selected", self, "_on_FileDialog_dir_selected")
	
	if type == "folder":
		$MainMenu/StartPopup/FileSystem/TextBackground/Label.text = "Locate the folder which holders all the python files"
		file_instance.mode = FileDialog.MODE_OPEN_DIR
		file_instance.window_title = "Select folder location"
	elif type == "python files":
		$MainMenu/StartPopup/FileSystem/TextBackground/Label.text = "Locate a python interpreter path. It should be pythonw.exe"
		file_instance.mode = FileDialog.MODE_OPEN_FILE
		file_instance.window_title = "Select file location"
	
	
	
func _ChangeConfigFile():
	var directory = folder_directory
	var path = python_interpreter_path
	
	var file = File.new()
	file.open(CONFIG_FILE_LOCATION, File.WRITE)
	
	file.store_string("Already_Config: 1\n")
	
	file.store_string("Command Terminal Path: " + str(directory) + str("/command.py")+"\n")
	file.store_string("Status Terminal Path: " + str(directory) + str("/status.py")+"\n")
	file.store_string("Game Terminal Path: " + str(directory) + str("/telnet_game.py")+"\n")
	
	file.store_string("Python interpreter Path: " + str(path))
	
	#Game Terminal Path: C:\Users\joshd\Desktop\CompSciProject\Terminal-Exploit\clients\telnet_game.py
	
	file.close()
	
func _CreateConfigFile():
	var file = File.new()
	file.open(CONFIG_FILE_LOCATION, File.WRITE)
	
	file.store_string("Already_Config: " + "0 \n")
	file.store_string("Command Terminal Path: \n")
	file.store_string("Status Terminal Path: \n")
	file.store_string("Game Terminal Path: \n")
	
	file.store_string("Python interpreter Path: ")
	
	#Game Terminal Path: C:\Users\joshd\Desktop\CompSciProject\Terminal-Exploit\clients\telnet_game.py
	
	file.close()



#launch the python files
func _on_Start_pressed():
	#the location of the files in respect to the godot project itself but without res
#	var IDLE_base_path = "PythonFiles/VirtualEnviron/Scripts/pythonw.exe"
	#res://PythonFiles/VirtualEnviron/
	var launcher_base_path = "PythonFiles/FilesToBeRun/launcher.py"
	
	#initialising the paths of the files that will be run to launch the different terminals
#	var IDLE_path = ""
	var launcher_path = ""
	
	#path if in the godot editor
	if (OS.has_feature("standalone")) == false:
#		IDLE_path = ProjectSettings.globalize_path("res://" + IDLE_base_path)
		launcher_path = ProjectSettings.globalize_path("res://" + launcher_base_path)
	#path if executable
	else:
		var directory = OS.get_executable_path().get_base_dir()
#		IDLE_path = directory.plus_file(IDLE_base_path)
		launcher_path = directory.plus_file(launcher_base_path)
	
	#in args is just the file to be run, blocking so godot can run while the terminals run
	#then the error array incase stuff goes wrong - which will most likely happen 
	#wait blocking cancels error, at some point i should be not lazy enough to delete it 
	var args = [launcher_path]
	var blocking = false
	var error = [] #if everything goess well, error shouldn't happen
	
	var IDLE_path = null
	
	var file = File.new()
	file.open(CONFIG_FILE_LOCATION, File.READ)
	
	while not file.eof_reached():
		var line = file.get_line()
		var split = line.split(": ")
		if split[0] == "Python interpreter Path":
				IDLE_path = split[1]
	file.close()
	
	
	
	
	

	OS.execute(IDLE_path, args, blocking, error)


func _on_FileDialog_dir_selected(dir):
	print("DOING A DIRECTORY")
	print(dir)
	$MainMenu/StartPopup.visible = false
	folder_directory = dir
	_BringUpFileSelector("python files")
	

func _on_FileDialog_file_selected(path):
	print("DOING A PATH")
	print(path)
	python_interpreter_path = path
	_ChangeConfigFile()
	
	#this is the only way to shut it down for now and it is getting annoy agegagegagega
	#fix later
	$MainMenu/StartPopup/FileSystem/FileDialog.queue_free()
	$MainMenu/StartPopup.visible = false
