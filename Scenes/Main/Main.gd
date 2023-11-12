extends Node2D



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
