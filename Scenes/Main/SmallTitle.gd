extends Label


var rng = RandomNumberGenerator.new()

var potentials = ["00000000000000000000",
"WORKS ON MY COMPUTER",
"CHANGING PASSWORDS",
"THANKS GITHUB",
"BABA GANOUSH TIME",
"FIRST GYM BY WEEK 5",
"IT’S EXPLOITING TIME",
"TOO COMPLICATED",
"HOW IS THIS WORKING?",
"GET DOS’D",
"WHO’S RUNNING IP?",
"GROUP UP FOR DPS",
"YOU SHOULD COMMIT NOW",
"FREE CANDY",
"NOW WITH THE HOMIES",
"PAIN AND SUFFERING",
"ALT F4 TO WIN",
"SOMETHING WILL BREAK",
"PAY TO WIN",
"PATEL IS OUR SAVIOR"
]

var current_length = 0
var next_text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	_later()
	
func _later():
	var len_of_titles = len(potentials)
	print("LEN OF TITLES")
	print(len_of_titles)
	var ran_text = potentials[rng.randi_range(0,(len_of_titles-1))]
	current_length = len(ran_text)
	visible_characters = current_length
	self.text = ran_text
	$BigT.start()
	
	#rand_value = my_array[randi() % my_array.size()]


func _on_BigT_timeout():
	print("Big")
	var len_of_titles = len(potentials)
	var ran_text = potentials[rng.randi_range(0,(len_of_titles-1))]
	current_length = len(ran_text)+1
	print("CURRENT LENGTH")
	print(current_length)
	next_text = ran_text
	$SmallT.start()
	$BigT.stop()
	
	
	


func _on_SmallT_timeout():
	#print("Small")
	if self.text != next_text:
		visible_characters -= 1
		if visible_characters <= 0:
			self.text = next_text
	else:
		visible_characters += 1
		if visible_characters >= current_length:
			$SmallT.stop()
			$BigT.start()
			
			

func _on__T_timeout():
	print("timeout")
	print(visible_characters)
	print(len(text))
	if visible_characters == current_length:
		visible_characters -= 1
	else:
		visible_characters += 1
