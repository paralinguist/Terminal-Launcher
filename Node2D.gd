extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var a = "res://clients"
	var favoured_path

	favoured_path = ProjectSettings.globalize_path(a)
	print(favoured_path)
	
	favoured_path = OS.get_executable_path().get_base_dir()
	print(favoured_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
