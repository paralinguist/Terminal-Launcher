extends VBoxContainer

var config_file_location

#remember to send this into whatchu mech call it af
var chosen_stats = {
	"user" : "",
	"team" : "",
	"role" : "",
	"addr" : ""
	
	
}

var arrayOfRoles = {}

var min_name_text = "> Name : "
var min_ip_text = "> IP Change : "

var base_team_text = "Current Team : "
var base_role_text = "Current Role : "

func _ready():
	var file_check = File.new()
	var client_directory = Directory.new()
	
	if client_directory.open("./clients") == OK:
		if file_check.file_exists("./clients/client_settings.txt"):
			config_file_location = "./clients/client_settings.txt"
		else:
			client_directory.copy("./clients/client_settings.txt.template", "./clients/client_settings.txt")
			config_file_location = "./clients/client_settings.txt"
	print("popups")
	#res://RoleandExtensions.txt
	grab_potential_roles()
	upload_to_popup()
	grab_specific_file_stats()
	updated_the_text()

func grab_potential_roles():
	var role_location = "res://RoleandExtensions.txt"
	
	var role_file = File.new()
	role_file.open(role_location, File.READ)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	while not role_file.eof_reached():
		var line = role_file.get_line()
		var split = line.split(":")
		print(line)
		print(split)
		#name:extension
		arrayOfRoles[split[0]] = split[-1]
	
	#var roles_array = arrayOfRoles
	role_file.close()
	#return roles_array

func upload_to_popup():
	var keys = arrayOfRoles.keys()
	
	for key in keys:
		$Control/MenuButton/PopupUpOfGames.add_item(key)

func grab_specific_file_stats():
	var line_by_line = {}

	var config_file = File.new()
	config_file.open(config_file_location, File.READ)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	var get_keys = chosen_stats.keys()
	
	while not config_file.eof_reached():
		var line = config_file.get_line()
		var split = line.split(":")
		if split[0] in get_keys:
			chosen_stats[split[0]] = split[-1]
		
		#name:extension
	
	
	config_file.close()

func updated_the_text():
	$Name.text += chosen_stats["user"]
	$ChangeIP.text += chosen_stats["addr"]
	
	$CurrentRole.text += chosen_stats["role"]
	$CurrentTeam.text += chosen_stats["team"]

func _on_Change_Role_pressed():
	$Control/MenuButton/PopupUpOfGames.popup()


func _on_Change_Team_pressed():
	print(chosen_stats["team"])
	if chosen_stats["team"] == "orange":
		chosen_stats["team"] = "green"
	else:
		chosen_stats["team"] = "orange"
	
	$CurrentTeam.text = base_team_text + chosen_stats["team"]


func _on_PopupUpOfGames_id_pressed(id):
	var chosen_role = $Control/MenuButton/PopupUpOfGames.get_item_text(id)
	chosen_stats["role"] = chosen_role
	$CurrentRole.text = base_role_text + chosen_stats["role"]


func _on_Name_text_changed(new_text):
	if (min_name_text in new_text) == false:
		$Name.text = min_name_text
		

func _on_ChangeIP_text_changed(new_text):
	if (min_ip_text in new_text) == false:
		$ChangeIP.text = min_ip_text



func _on_Save_pressed():
	var line_by_line = {}
	
	var config_file = File.new()
	config_file.open(config_file_location, File.READ)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	while not config_file.eof_reached():
		var line = config_file.get_line()
		var split = line.split(":")
		line_by_line[split[0]] = split[-1]
		
		#name:extension
	config_file.close()
	
	var name_text = $Name.text 
	var nt_split = name_text.split(" : ")
	
	if nt_split[-1] != "":
		line_by_line["user"] = str(nt_split[-1])
	
	var ip_text = $ChangeIP.text 
	var it_split = ip_text.split(" : ")
	
	if it_split[-1] != "":
		line_by_line["addr"] = str(it_split[-1])
	
	line_by_line["team"] = chosen_stats["team"]
	line_by_line["role"] = chosen_stats["role"]
	
	print(line_by_line)
	
	var change_config_file = File.new()
	change_config_file.open(config_file_location, File.WRITE)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	var get_keys = line_by_line.keys()
	for key in get_keys:
		if key != "":
			var stored_line = str(key)
			var value = line_by_line[key]
			stored_line += ":" + value
			change_config_file.store_line(stored_line)
	
	change_config_file.close()
	


func _on_Return_pressed():
	self.visible = false
	get_parent().get_node("MainVBOX").visible = true
