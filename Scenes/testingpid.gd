extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var output = []
	OS.execute("CMD.exe", ["/C", 'tasklist /fi "pid eq 4920"'], true, output)
	print(output) # Replace with function body.
	#[INFO: No tasks are running which match the specified criteria.
	var test = "INFO: No tasks are running which match the specified criteria."
	print(output[0])
	if test in output[0]:
		print("pog champ")

# tasklist /fi "pid eq 20000"
#OS.execute("CMD.exe", ["/C", "cd %TEMP% && dir"], true, output)

