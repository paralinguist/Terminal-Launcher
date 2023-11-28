extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuButton/PopupMenu2.add_item("hi")
	$MenuButton/PopupMenu2.popup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PopupMenu2_id_pressed(id):
	print(id)
	print($MenuButton/PopupMenu2.get_item_text(id))
	

func _input(event):
	if event.is_action_pressed("ui_down"):
		$MenuButton/PopupMenu2.popup()
