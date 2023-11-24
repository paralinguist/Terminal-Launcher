extends Node2D

const CONFIG_FILE = "res://launcher_config.txt"
const STARTUP_POP = "res://Scenes/Main/FileDialog.tscn"
const BUTTON_TEXTS = ["> Launch the game", "> Disconnect from the game"]

var operating_system = "Windows"
var launcher_path = ""
var python_interpreter_path = ""
var game_terminals = []
var status_terminal = "status.py"
var command_terminal = "command.py"
var game_terminal = ""
var status_pid = []
var command_pid = []
var game_pid = []
var copy_command = "xcopy"
var copy_args = "/Y"

var wait_fs: GDScriptFunctionState

#what is this?
var folder_directory = ""

#check if a PID is still running, then go

func _notification(notification_kind):
    if notification_kind == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        kill_terminals()
        get_tree().quit()

#I considered called this "kill_children" but thought better of it
func kill_terminals():
    for pid in status_pid:
        OS.kill(pid)
    for pid in command_pid:
        OS.kill(pid)
    for pid in game_pid:
        OS.kill(pid)

func set_os():
    operating_system = OS.get_name()

func check_terminals():
    var terminals_present = false
    #path if in the godot editor
    if (OS.has_feature("standalone")) == false:
        launcher_path = ProjectSettings.globalize_path("res://")
    #path if exported
    else:
        var directory = OS.get_executable_path().get_base_dir()
        launcher_path = directory
    var file_check = File.new()
    if file_check.file_exists(status_terminal) and file_check.file_exists(command_terminal):
        var launcher_directory = Directory.new()
        
        if launcher_directory.open(launcher_path) == OK:
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
            copy_command = "cp"
            copy_args = ""
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
        game_terminal = game_terminals[0]
        #Display a dialogue asking for user to select game terminal

func _ready():
    operating_system = OS.get_name()
    read_config()
    check_terminals()
    check_interpreter()
    check_game_terminal()
    $MainMenu/HBox/Panel/VBox/MessageLog/VBoxContainer/Start.text = BUTTON_TEXTS[0]
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

#launch the python files
func _on_Start_pressed():
    
    var node_for_start_button = $MainMenu/HBox/Panel/VBox/MessageLog/VBoxContainer/Start
    
    if node_for_start_button.text == BUTTON_TEXTS[0]:
        node_for_start_button.text = BUTTON_TEXTS[1]
        var blocking = false
        var output = []
        var stderr = false
        var open_console = true
        
    #	if $MainMenu/HBoxContainer/TestingCheckBox.pressed:
        if $MainMenu/HBox/Panel/VBox/MessageLog/VBoxContainer/TestingCheckBox.pressed:
            var game_directory = Directory.new()
            var original_config_file = "client_settings.txt"
            var backup_config_file = "client_settings.txt.bak"
            var test_config_file = "client_settings.txt.test"        
            if game_directory.open(".") == OK:
                game_directory.copy(original_config_file, backup_config_file)
                for i in range(1,5):
                    game_directory.copy(test_config_file+str(i), original_config_file)
                    status_pid.append(OS.execute(python_interpreter_path, [status_terminal], blocking, output, stderr, open_console))
                    command_pid.append(OS.execute(python_interpreter_path, [command_terminal], blocking, output, stderr, open_console))
                    game_pid.append(OS.execute(python_interpreter_path, [game_terminal], blocking, output, stderr, open_console))
                    $CopyTimer.start(1)
                    yield($CopyTimer, "timeout")
                game_directory.copy(backup_config_file, original_config_file)
        else:
            status_pid.append(OS.execute(python_interpreter_path, [status_terminal], blocking, output, stderr, open_console))
            command_pid.append(OS.execute(python_interpreter_path, [command_terminal], blocking, output, stderr, open_console))
            game_pid.append(OS.execute(python_interpreter_path, [game_terminal], blocking, output, stderr, open_console))
    else:
        #means node_for_Start_button.text is [1]
        for pid in status_pid:
            OS.kill(pid)
        for pid in command_pid:
            OS.kill(pid)
        for pid in game_pid:
            OS.kill(pid)
        node_for_start_button.text = BUTTON_TEXTS[0]
        
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



func _on_BlockingFileCopier_done_copying():
    print("Finished copy job")
    if is_instance_valid(wait_fs):
        wait_fs.resume()


func _on_Quit_pressed():
    kill_terminals()
    get_tree().quit()
