import os
import threading
import time
import platform

#os is needed to execute the files
#threading is needed otherwise the separate terminals can't be run
#time is needed just so there is time between each terminal opening
#platform is needed to get the system os

base_command = " "

platform_system = platform.system()

platform_system = platform_system.lower()

if platform_system == 'linux':
    #ew yuck why are you use lienux it is totally not the most superior os
    base_command = "python3 "
elif platform_system == 'windows':
    base_command = "py "
elif platform_system == "darwin":
    #imagine paying $3000 for a terrible computer
    base_command = "python3 "
else:
    #let's role the dice and use python3
    #later implement complain to godot
    base_command = "python3 "

#getting file direc
current_file_path = os.path.dirname(__file__)
config_file_directory = os.path.join(current_file_path, "config_file.txt")

print(config_file_directory)
#reading file line by line and opening it
file = open(config_file_directory, "r")
lines = file.readlines()
pathArrays = []

for line in lines:
    split = line.split(": ")
    path = split[1]
    path = path.replace("\n", "")
    pathArrays.append(path)
    print(pathArrays)
    #would the last bit being a \n be a problem?

file.close()

def runPythonFile(path):
    python_command = base_command + str(path)
    os.system(python_command)

def runExecutableFile(path):
    #do later
    pass

#threads so more than once 
threadCommand = threading.Thread(target=runPythonFile, args=(pathArrays[0],))
threadStatus = threading.Thread(target=runPythonFile, args=(pathArrays[1],))
threadGame = threading.Thread(target=runPythonFile, args=(pathArrays[2],))
threadCommand.start()
threadStatus.start()
threadGame.start()

print(threading.active_count())