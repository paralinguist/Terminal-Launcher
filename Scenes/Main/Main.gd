extends Node2D

var CONFIG_FILE = "res://clients/launcher_config.txt"
var STARTUP_POP = "res://Scenes/Main/FileDialog.tscn"
const BUTTON_TEXTS = ["> Launch the game", "> Disconnect from the game"]

var operating_system = "Windows"
var launcher_path = ""
var python_interpreter_path = ""
var game_terminals = []
var status_terminal = "clients/status.py"
var command_terminal = "clients/command.py"
var game_terminal = ""
var status_pid = []
var command_pid = []
var game_pid = []

var allowed_to_start = false
var testing_tcp_udp = false

#what is this?
#i dont even have a clue but the code complains without it
var folder_directory = ""


#check if a PID is still running, then go

func _notification(notification_kind):
	if notification_kind == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		kill_terminals()
		get_tree().quit()
		_changing_start_back_to_normal()

#I considered called this "kill_children" but thought better of it
func kill_terminals():
	#I did not think better sir and included it as a debug print statement to make sure the murders are justified
	print("we are killing kids!!!")
	for pid in status_pid:
		OS.kill(pid)
	for pid in command_pid:
		OS.kill(pid)
	for pid in game_pid:
		OS.kill(pid)

func set_os():
	operating_system = OS.get_name()

func _change_res_to_good(res_path):
	print("FUNCTION")
	print(res_path)
	var favoured_path = ""
	
	if (OS.has_feature("standalone")) == false:
		favoured_path = ProjectSettings.globalize_path(res_path)
	#path if exported
	else:
		favoured_path = OS.get_executable_path().get_base_dir()
		var text = res_path
		var new = res_path.replace("res://","")
		favoured_path += "/" + new
	
	print(favoured_path)
	return favoured_path

func check_terminals():
	var terminals_present = false
	#path if in the godot editor
	
	var directory = _change_res_to_good("res://clients")

#	if (OS.has_feature("standalone")) == false:
#		launcher_path = directory
#	else:
#		launcher_path = directory + "/clients/" 
	
	launcher_path = directory
	var file_check = File.new()
	if file_check.file_exists(status_terminal) and file_check.file_exists(command_terminal):
		var launcher_directory = Directory.new()
		
		print("GAME TERMINALS")
		print(launcher_path)
		if launcher_directory.open(launcher_path) == OK:
			print(launcher_path)
			
			print(launcher_directory)
			launcher_directory.list_dir_begin()
			var file_name = launcher_directory.get_next()
			while file_name != "":
				if file_name.ends_with("_game.py"):
					game_terminals.append(file_name)
				file_name = launcher_directory.get_next()
			if len(game_terminals) == 0:
				print("No game terminals!")
			else:
				terminals_present = true
	else:
		print("No status or command terminals!")
	return terminals_present

func read_config():
	var file_check = File.new()
	var config_exists = file_check.file_exists(CONFIG_FILE)
	print("Config exists: " + str(config_exists))
	
	if config_exists:
		var config_file = File.new()
		config_file.open(CONFIG_FILE, File.READ)

		while not config_file.eof_reached():
			var line = config_file.get_line()
			var split = line.split(":")
			if len(split) == 2:
				if split[0] == "interpreter":
					python_interpreter_path = split[1]
				elif split[0] == "game_terminal":
					game_terminal = split[1]
		config_file.close()
	else:
		pass
		#Create config
#OS Specific code please
func check_interpreter():
	if python_interpreter_path == "":
		var args
		var output = []
		var interpreter
		if operating_system == "Windows":
			python_interpreter_path = "py.exe"
			args = [python_interpreter_path] 
			OS.execute("where", args, true, output)
			interpreter = output[0].replace("\\", "/").strip_edges()
		else:
			python_interpreter_path = "python3"
			args = [python_interpreter_path] 
			OS.execute("which", args, true, output)
			interpreter = output[0]
			   
		var interpreter_check = File.new()
		if not interpreter_check.file_exists(interpreter):
				var new_file_dialog = load(STARTUP_POP)
				var file_instance = new_file_dialog.instance()
				$MainMenu/StartPopup/FileSystem.add_child(file_instance)
				file_instance.popup()
				$MainMenu/StartPopup.visible = true
				file_instance.connect("file_selected", self, "_on_FileDialog_file_selected")
				$MainMenu/StartPopup/FileSystem/TextBackground/Label.text = "Locate a python interpreter path. It should be py.exe"
				file_instance.mode = FileDialog.MODE_OPEN_FILE
				file_instance.window_title = "Select file location - Python"
	print(python_interpreter_path)
	
func check_game_terminal():
	if not (game_terminal in game_terminals):
		print("Available game terms: " + str(game_terminals))
		game_terminal = grab_game_term_from_client_settings()
		print(game_terminal)
		
		#Display a dialogue asking for user to select game terminal

func grab_game_term_from_client_settings():
	var role = ""
	var client_settings_location = "./clients/client_settings.txt"
	
	var client_file = File.new()
	client_file.open(client_settings_location, File.READ)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	while not client_file.eof_reached():
		var line = client_file.get_line()
		var split = line.split(":")
		#print(line)
		#print(split)
		if split[0] == "role":
			role = split[-1]
		
	client_file.close()
	var potential = $MainMenu/HBox/Panel/VBox/MessageLog/SettingsVBOX.arrayOfRoles
	
	var location = ""
	if potential.has(role):
		location = potential[role]
	else:
		location = "telnet"
	
	var game_term = "clients/" + location
	print(game_term)
	return game_term

func _ready():
	operating_system = OS.get_name()
	
	var new_config = _change_res_to_good(CONFIG_FILE)
	CONFIG_FILE = new_config
	
#	if (OS.has_feature("standalone")) == true:
#		CONFIG_FILE += "/launcher_config.txt"
	
	print("beg")
	read_config()
	print("Read")
	check_terminals()
	print("terminal")
	check_interpreter()
	print("interpreter")
	check_game_terminal()
	print("game")
	$MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/Start.text = BUTTON_TEXTS[0]
	print("Ready")
	
func _BringUpFileSelector(type):
	#for loop, 3 times, change text on time
	#ask sir where game selection will be handled
	#this is being disgusting rn so imma do folder method then figure out later
	#$MainMenu/StartPopup/FileSystem/FileDialog.visible = true
	
	
	#queue free after use!!!!
	#weird thing where python interperter no open
	
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
		$MainMenu/StartPopup/FileSystem/TextBackground/Label.text = "Locate a python interpreter path. It should be py.exe"
		file_instance.mode = FileDialog.MODE_OPEN_FILE
		file_instance.window_title = "Select file location"

func _ChangeConfigFile():
	var directory = folder_directory
	var path = python_interpreter_path
	
	var file = File.new()
	file.open(CONFIG_FILE, File.WRITE)
	
	file.store_string("Already_Config: 1\n")
	
	file.store_string("Command Terminal Path: " + str(directory) + str("/command.py")+"\n")
	file.store_string("Status Terminal Path: " + str(directory) + str("/status.py")+"\n")
	file.store_string("Game Terminal Path: " + str(directory) + str("/telnet_game.py")+"\n")
	
	file.store_string("Python interpreter Path: " + str(path))
	
	file.close()
	
func _CreateConfigFile():
	var config_file = File.new()
	config_file.open(CONFIG_FILE, File.WRITE)
	
	config_file.store_string("Already_Config: " + "0 \n")
	config_file.store_string("Command Terminal Path: \n")
	config_file.store_string("Status Terminal Path: \n")
	config_file.store_string("Game Terminal Path: \n")
	
	config_file.close()

func copy_script(directory, script, target_path):
	directory.copy(script, target_path + script)

#launch the python files
func _on_Start_pressed():
	print("Start has been pressed")
	check_game_terminal()
	
	if allowed_to_start == true:
		var node_for_start_button = $MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/Start
		
		if node_for_start_button.text == BUTTON_TEXTS[0]:
			
			node_for_start_button.text = BUTTON_TEXTS[1]
			var blocking = false
			var output = []
			var stderr = false
			var open_console = true
			
		#	if $MainMenu/HBoxContainer/TestingCheckBox.pressed:
			if $MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/TestingCheckBox.pressed:
				var game_directory = Directory.new()   
				var multilaunch_path = ""
				if game_directory.open(".") == OK:
					for i in range(1,5):
						#TODO: support other game terminals
						print("Yo! " + status_terminal)
						multilaunch_path = launcher_path + "/multilaunch/" + str(i) + "/"
						copy_script(game_directory, "status.py", multilaunch_path)
						copy_script(game_directory, "command.py", multilaunch_path)
						copy_script(game_directory, "terminal_api.py", multilaunch_path)
						copy_script(game_directory, "telnet_game.py", multilaunch_path)
						status_pid.append(OS.execute(python_interpreter_path, [multilaunch_path + "status.py"], blocking, output, stderr, open_console))
						command_pid.append(OS.execute(python_interpreter_path, [multilaunch_path + "command.py"], blocking, output, stderr, open_console))
						game_pid.append(OS.execute(python_interpreter_path, [multilaunch_path + "telnet_game.py"], blocking, output, stderr, open_console))
			else:
				status_pid.append(OS.execute(python_interpreter_path, [status_terminal], blocking, output, stderr, open_console))
				command_pid.append(OS.execute(python_interpreter_path, [command_terminal], blocking, output, stderr, open_console))
				if testing_tcp_udp == false:
					print("GAME TERMINAL")
					print(game_terminal)
					var extension = game_terminal.get_extension()
					
					if extension == "py":
						game_pid.append(OS.execute(python_interpreter_path, [game_terminal], blocking, output, stderr, open_console))
					else:
						print("EXE")
						print(game_terminal)
						game_pid.append(OS.execute(game_terminal, [], blocking, output))
						print(output)
		else:
			#means node_for_Start_button.text is [1]
			kill_terminals()
			_changing_start_back_to_normal()
			node_for_start_button.text = BUTTON_TEXTS[0]
	else:
		var get_connection = $ConnectionSetterUpper._checking_if_connected_to_host() 
		print("connection status: " + str(get_connection))
		if get_connection == true:
			$ConnectionSetterUpper._sending_test()
		else:
			$MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/Start.text = "> Can't connect to server. Change IP or ensure Server is running"
			var timer = Timer.new()
			timer.autostart = false
			timer.one_shot = true
			timer.wait_time = 3
			
			timer.connect("timeout", self, "_changing_start_back_to_normal")
			print("timeout")
			get_parent().add_child(timer)
			timer.start()

func _on_FileDialog_dir_selected(dir):
	print("DOING A DIRECTORY")
	print(dir)
	#$MainMenu/StartPopup.visible = false
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

func _changing_start_back_to_normal():
	print("timed out")
	$MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/Start.text = "> Test connection and launch game"


func _on_Quit_pressed():
	kill_terminals()
	get_tree().quit()


func _on_Settings_pressed():
	$MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX.visible = false
	$MainMenu/HBox/Panel/VBox/MessageLog/SettingsVBOX.visible = true


