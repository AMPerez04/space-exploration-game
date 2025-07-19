# offline_progress_popup.gd
extends PanelContainer

# This signal is optional but good practice if you ever want the
# main game to know when the popup is closed.
signal closed

@onready var info_label: Label = $VBoxContainer/InfoLabel
@onready var ok_button: Button = $VBoxContainer/OkButton

func _ready():
	# Ensure the button is connected.
	ok_button.pressed.connect(on_ok_pressed)
	# Hide on start, just in case it was left visible in the editor.
	self.hide()

# This is the main function called from main.gd
func show_progress(seconds_away: int, rp_earned: float):
	var time_str = format_seconds_to_string(seconds_away)
	
	# Use a formatted string for readability.
	var format_string = "Welcome back!\n\nWhile you were away for\n%s,\nyour research continued, earning:\n\n%.2f RP"
	info_label.text = format_string % [time_str, rp_earned]
	
	# THIS IS THE MOST IMPORTANT LINE IN THIS SCRIPT
	self.show()

func on_ok_pressed():
	self.hide()
	emit_signal("closed")

# Helper function to make time readable
func format_seconds_to_string(total_seconds: int) -> String:
	var days = total_seconds / 86400
	var hours = (total_seconds % 86400) / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	
	if days > 0:
		return "%d days, %d hours" % [days, hours]
	if hours > 0:
		return "%d hours, %d minutes" % [hours, minutes]
	if minutes > 0:
		return "%d minutes, %d seconds" % [minutes, seconds]
		
	return "%d seconds" % seconds
