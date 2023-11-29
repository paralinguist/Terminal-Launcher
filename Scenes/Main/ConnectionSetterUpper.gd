extends Node


const PORT : int = 9876

var client = WebSocketClient.new()
var URL: String = "ws://localhost:%s" % PORT

var server_id


func _creating_url():
	var ip = ""
	var port = ""
	var client_settings_location = "res://clients/client_settings.txt"
	
	var client_file = File.new()
	client_file.open(client_settings_location, File.READ)
	
	#var contents = role_file.get_as_text()
	#print(contents)
	while not client_file.eof_reached():
		var line = client_file.get_line()
		var split = line.split(":")
		print(line)
		print(split)
		if split[0] == "addr":
			ip = split[-1]
		if split[0] == "port":
			port = split[-1]
		#name:extension
		
	client_file.close()
	var url = "w://" + str(ip) + ":" + str(port)
	return url
 
func _ready() -> void:
	print("connections")
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "_on_data")
	var url_if_not_local = _creating_url()
	client.connect_to_url(URL)
	#addr+port
	
		#come back to later
	
	#add connection 

func _closed():
	print("closed")

#godot has flexible type
#this creates more risky code
#the void returns a void if the protocol isnt a string
func _connected(protocol: String) -> void:
	print("yay connecty")
	var message = "||:GodotKid"
	
	#first creating the packet as utf
	#sends it off
	
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	
func _process(_delta: float) -> void:
	client.poll()
	
func _on_data() -> void:
	var pkt = client.get_peer(1).get_packet()
	var incoming = pkt.get_string_from_utf8()
	print('Server says : ' + incoming)
	
	var splitted_incomming = incoming.split(":")
	
	print(splitted_incomming)
	
	
	
	match splitted_incomming[0]:
		"test":
			if splitted_incomming[1] == "True" and\
			splitted_incomming[2] == "True" and\
			splitted_incomming[3] < "4":
				get_parent().allowed_to_start = true
				get_parent()._on_Start_pressed()
			else:
				#do if statement and change start button text accordinglt
				var what_needs_to_be_done = ""
				#send_terminal_message(connection_id, "test:" + str(game_available) + ":" + str(name_available) + ":" + str(team_size))
				
				if splitted_incomming[1] == "False":
					what_needs_to_be_done += "A game is currently happening."
				if splitted_incomming[2] == "False":
					what_needs_to_be_done += "Change your name! "
				if splitted_incomming[3] >= "4":
					what_needs_to_be_done += "Change your team! "
				#_changing_start_back_to_normal(text)
				
				get_parent().get_node("MainMenu/HBox/Panel/VBox/MessageLog/MainVBOX/Start").text = what_needs_to_be_done
				var timer = Timer.new()
				timer.autostart = false
				timer.one_shot = true
				timer.wait_time = 3
				
				timer.connect("timeout", get_parent(), "_changing_start_back_to_normal")
				print("timeout")
				get_parent().add_child(timer)
				timer.start()
				
				

func _checking_if_connected_to_host():
	var is_it_connected = client.get_peer(1).is_connected_to_host()
	
	return is_it_connected

func _sending_test():
	var packet_to_send = "test:"
	
	var line_by_line = {}
	var config_file_location = "res://clients/client_settings.txt"
	
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
	
	packet_to_send += line_by_line["team"] + ":" + line_by_line["user"]
	print(packet_to_send)
	
	client.get_peer(1).put_packet(packet_to_send.to_utf8())

func _sending_points(points):
	var message = "score:%s" % points
	
	#first creating the packet as utf
	#sends it off
	
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)

func _yeeting_someone(hacker_ip):
	var message = "yeet:%s" % hacker_ip
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	
func _intel(taking):
	var message = "yeet:%s" % taking
	var packet: PoolByteArray = message.to_utf8()
	client.get_peer(1).put_packet(packet)
	6
