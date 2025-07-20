# main.gd
extends Control

@onready var rp_label: Label = $ScreenLayout/GameArea/VBoxContainer/RPLabel
@onready var rps_label: Label = $ScreenLayout/GameArea/VBoxContainer/RPSLabel
@onready var click_button: Button = $ScreenLayout/GameArea/VBoxContainer/ClickButton
@onready var generator_list: VBoxContainer = $ScreenLayout/TabContainer/Generators/GeneratorList
@onready var upgrade_list: VBoxContainer = $ScreenLayout/TabContainer/Upgrades/UpgradeList

const OfflinePopupScene = preload("res://offline_progress_popup.tscn")
var offline_popup

const UI_UPDATE_INTERVAL = 0.25 
var ui_update_timer = 0.0

# Preload the scene we'll be instancing.
const GeneratorRowScene = preload("res://generator_row.tscn")
const UpgradeRowScene = preload("res://upgrade_row.tscn")


func _ready():
	offline_popup = OfflinePopupScene.instantiate()
	add_child(offline_popup)
	offline_popup.hide()
	
	GameManager.offline_progress_calculated.connect(on_offline_progress)
	
	
	
	click_button.pressed.connect(GameManager.manual_research_click)
		
	# Initial UI population
	populate_generator_list()
	populate_upgrades_list()
	update_ui()
	
func on_offline_progress(seconds, rp_earned):
	print("DEBUG: Main UI received signal. Telling popup to show.")
	offline_popup.show_progress(seconds, rp_earned)

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
		update_upgrades_ui()
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

func populate_upgrades_list():
	for upg_data in GameManager.all_upgrades:
		var row = UpgradeRowScene.instantiate()
		upgrade_list.add_child(row)
		row.buy_pressed.connect(_on_upgrade_buy_pressed)

func update_upgrades_ui():
	var i = 0
	for upg_data in GameManager.all_upgrades:
		var row = upgrade_list.get_child(i)
		
		# Hide upgrades that are already purchased
		if GameManager.purchased_upgrades.has(upg_data.id):
			row.hide()
		else:
			row.show()
			var can_afford = GameManager.research_points >= upg_data.cost
			row.set_data(upg_data, can_afford)
		i += 1

func _on_upgrade_buy_pressed(upgrade_id: String):
	GameManager.buy_upgrade(upgrade_id)
