# main.gd
extends Control

@onready var rp_label: Label = $VBoxContainer/RPLabel
@onready var rps_label: Label = $VBoxContainer/RPSLabel
@onready var click_button: Button = $VBoxContainer/ClickButton
@onready var generator_list: VBoxContainer = $ScrollContainer/GeneratorList


const UI_UPDATE_INTERVAL = 0.25 
var ui_update_timer = 0.0

# Preload the scene we'll be instancing.
const GeneratorRowScene = preload("res://generator_row.tscn")

func _ready():
	click_button.pressed.connect(GameManager.manual_research_click)
		
	# Initial UI population
	populate_generator_list()
	update_ui()

func _process(_delta):
	# Update the main RP label every frame.
	rp_label.text = "%.2f" % GameManager.research_points
	
	var total_rps = GameManager.calculate_total_rps()
	rps_label.text = "(%.2f RP/s)" % total_rps
	
	# Increment our timer
	ui_update_timer += _delta
	
	# Check if enough time has passed
	if ui_update_timer >= UI_UPDATE_INTERVAL:
		# If so, update the entire UI and reset the timer
		update_ui()
		ui_update_timer = 0.0

# This function runs once to create the UI rows.
func populate_generator_list():
	# Clear any old rows if we call this again (e.g., after a prestige)
	for child in generator_list.get_children():
		child.queue_free()

	# Loop through the generators defined in the GameManager
	for gen_data in GameManager.all_generators:
		var row = GeneratorRowScene.instantiate()
		generator_list.add_child(row)
		# Connect the row's custom signal to a function in this script.
		row.buy_pressed.connect(_on_generator_buy_pressed)

# This function updates the data in all the UI rows.
func update_ui():
	var i = 0
	for gen_data in GameManager.all_generators:
		var row = generator_list.get_child(i)
		var gen_id = gen_data.id
		
		var count = GameManager.owned_generators.get(gen_id, 0)
		var cost = GameManager.get_generator_cost(gen_id)
		var can_afford = GameManager.research_points >= cost
		
		# NEW: Get the multiplier from the GameManager
		var multiplier = GameManager.calculate_generator_multiplier(gen_id)
		
		# Call the row's own function to update its labels and buttons, now with the multiplier.
		row.set_data(gen_data, count, cost, can_afford, multiplier) # Add multiplier here
		i += 1

func _on_generator_buy_pressed(generator_id: String):
	GameManager.buy_generator(generator_id)
	# After buying, immediately update the whole UI to reflect the new state.
	update_ui()
