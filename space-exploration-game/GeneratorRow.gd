# GeneratorRow.gd
extends PanelContainer

# A signal that we will emit when the buy button is pressed.
# We send the generator_id so the main scene knows WHICH button was pressed.
signal buy_pressed(generator_id)

@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var rps_label: Label = $HBoxContainer/VBoxContainer/RPSLabel
@onready var count_label: Label = $HBoxContainer/CountLabel
@onready var buy_button: Button = $HBoxContainer/BuyButton

var generator_id: String

# This function will be called from the main scene to set up the row's data.
func set_data(gen_data: GeneratorData, current_count: int, current_cost: float, can_afford: bool):
	self.generator_id = gen_data.id
	
	name_label.text = gen_data.display_name
	count_label.text = "Owned: %d" % current_count
	rps_label.text = "%.2f RP/s each" % gen_data.base_rps
	
	# We can use a custom function for large number formatting later.
	buy_button.text = "Buy (%.1f RP)" % current_cost
	buy_button.disabled = not can_afford

func _on_buy_button_pressed():
	# When the button is pressed, emit our custom signal.
	emit_signal("buy_pressed", generator_id)

func _ready():
	# Connect the button's built-in 'pressed' signal to our function.
	buy_button.pressed.connect(_on_buy_button_pressed)
