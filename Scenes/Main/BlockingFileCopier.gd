extends Node
signal done_copying
#This makes no sense at all
func copy_config(directory, target, destination):
	if directory.copy(target, destination) == OK:
		print("Copied " + target + " to " + destination)
		emit_signal("done_copying")
