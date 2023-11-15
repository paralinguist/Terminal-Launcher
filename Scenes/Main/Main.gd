extends Node2D

const CONFIG_FILE_LOCATION = "res://PythonFiles/FilesToBeRun/config_file.txt"
const STARTUP_POP = "res://Scenes/Main/FileSystemSelect.tscn"


func _ready():
	var result = false
	var file = File.new()
	file.open(CONFIG_FILE_LOCATION, File.READ)
	
	while not file.eof_reached():
		var line = file.get_line()
		var split = line.split(": ")
		print(split)
		if split[0] == "Already_Config":
			if split[1] == "0":
				print("Yes")
				result = true
	
	file.close()
	
	if result == true:
		_BringUpFileSelector()
	else:
		$MainMenu/StartPopup.visible = false
	
func _BringUpFileSelector():
	#for loop, 3 times, change text on time
	#ask sir where game selection will be handled
	#this is being disgusting rn so imma do folder method then figure out later
	$MainMenu/StartPopup/FileSystem/TextBackground/Label.text = "Locate the folder which holders all the python files"
	$MainMenu/StartPopup/FileSystem/FileDialog.popup()
	
func _ChangeConfigFile(directory):
	var file = File.new()
	file.open(CONFIG_FILE_LOCATION, File.WRITE)
	
	file.store_string("Already_Config: 1\n")
	
	file.store_string("Command Terminal Path: " + str(directory) + str("/command.py")+"\n")
	file.store_string("Status Terminal Path: " + str(directory) + str("/status.py")+"\n")
	file.store_string("Game Terminal Path: " + str(directory) + str("/telnet_game.py")+"\n")
	
	#Game Terminal Path: C:\Users\joshd\Desktop\CompSciProject\Terminal-Exploit\clients\telnet_game.py
	
	file.close()



#launch the python files
func _on_Start_pressed():
	#the location of the files in respect to the godot project itself but without res
	var IDLE_base_path = "PythonFiles/VirtualEnviron/Scripts/pythonw.exe"
	#res://PythonFiles/VirtualEnviron/
	var launcher_base_path = "PythonFiles/FilesToBeRun/launcher.py"
	
	#initialising the paths of the files that will be run to launch the different terminals
	var IDLE_path = ""
	var launcher_path = ""
	
	#path if in the godot editor
	if (OS.has_feature("standalone")) == false:
		IDLE_path = ProjectSettings.globalize_path("res://" + IDLE_base_path)
		launcher_path = ProjectSettings.globalize_path("res://" + launcher_base_path)
	#path if executable
	else:
		var directory = OS.get_executable_path().get_base_dir()
		
		IDLE_path = directory.plus_file(IDLE_base_path)
		launcher_path = directory.plus_file(launcher_base_path)
	
	#in args is just the file to be run, blocking so godot can run while the terminals run
	#then the error array incase stuff goes wrong - which will most likely happen 
	#wait blocking cancels error, at some point i should be not lazy enough to delete it 
	var args = [launcher_path]
	var blocking = false
	var error = [] #if everything goess well, error shouldn't happen
	
	
	print(IDLE_path)
	print(launcher_path)
	OS.execute(IDLE_path, args, blocking, error)
	print(error)


func _on_FileDialog_dir_selected(dir):
	print(dir)
	$MainMenu/StartPopup.visible = false
	_ChangeConfigFile(dir)
	
